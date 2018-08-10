classdef DataStream < matlab.mixin.SetGet
    %DATASTREAM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = immutable)
        streamMode = 'fpga';
    end
    
    properties
        % fpga settings
        pxiSampClkTrig = 'PXI_Trig7';
        
        % daq settings
        hTask;
        hTaskOnDemand;
        daqName;
        
        % common settings
        bufferSize = uint32(10000);
        callbackSamples = uint32(1000);
        totalSamples = uint64(0);
        nSampleCallback;
        doneCallback;
        sampClkSrc;
        sampClkPolarity = 'rising';
        sampClkRate;
        sampClkMaxRate = 25e6;
        validSampleRates = 5e5;
        sampClkTimebaseRate = 10e6;
        
        secondaryFifo = false;
        simulated = false;
        
        fpgaInvertChannels = false(4,1);
    end
    
    properties (SetAccess = private)
        % fpga props
        fpgaSession;
        hFifo;
        hFpga;
        fpgaFifoNum;
        hSE = uint64(0);
        fpgaBaseRate;
        digitizerType;
        inputRanges;
        
        % r series props
        hFpgaDaq;
        
        % common props
        hRouteRegistry;
        numChannels;
        running;
        availInputRanges;
        adcResolution = 14;
    end
    
    properties (Hidden, Constant)
        ADAPTER_MODULE_CHANNEL_COUNT = containers.Map({'NI5732','NI5733','NI5734','NI5751','NI517x','NI5771'},{2,2,4,4,4,4});
        ADAPTER_MODULE_SAMPLING_RATE_MAP = containers.Map({'NI5732','NI5733','NI5734','NI5751','NI517x','NI5771'},{80e6,120e6,120e6,50e6,125e6,100e6});
        ADAPTER_MODULE_AVAIL_INPUT_RANGES = containers.Map({'NI5732','NI5733','NI5734','NI5751','NI517x','NI5771'},{[1,0.5,0.25],[1,0.5,0.25],[1,0.5,0.25],[1,0.5,0.25],[2.5,1,0.5,0.1],[1]});
        ADAPTER_MODULE_ADC_BIT_DEPTH = containers.Map({'NI5732','NI5733','NI5734','NI5751','NI517x','NI5771'},{14,16,16,14,14,16});
        CHANNEL_INPUT_RANGE_FPGA_COMMAND_DATA_MAP = containers.Map({1,0.5,0.25},{0,1,2});
    end
    
    %% Life Cycle
    methods
        function obj = DataStream(type,hObj)
            obj.streamMode = type;
            obj.hRouteRegistry = dabs.ni.daqmx.util.triggerRouteRegistry;
            
            if strcmp(obj.streamMode, 'rseries')
                obj.hFpgaDaq = hObj;
                obj.sampClkTimebaseRate = 40e6;
                obj.validSampleRates = 40e6./(40:160);
                obj.hFpga = obj.hFpgaDaq.hFpga;
                
                r = [10 5 2 1];
                m = [-r' r'];
                obj.availInputRanges = mat2cell(m,ones(numel(r),1),2)';
                obj.adcResolution = 16;
            end
        end
        
        function delete(obj)
            if strcmp(obj.streamMode, 'fpga')
                obj.fpgaAsyncDataStream(0);
            end
            most.idioms.safeDeleteObj(obj.hTask);
            most.idioms.safeDeleteObj(obj.hTaskOnDemand);
        end
    end
    
    %% User Methods
    methods
        function setFpgaAndFifo(obj,digitizerType,fifo,secondaryFifo)
            if nargin < 4 || isempty(secondaryFifo)
                secondaryFifo = false;
            end
                
            obj.hFifo = fifo;
            obj.digitizerType = digitizerType;
            obj.fpgaBaseRate = obj.ADAPTER_MODULE_SAMPLING_RATE_MAP(digitizerType);
            obj.numChannels = uint32(obj.ADAPTER_MODULE_CHANNEL_COUNT(digitizerType));
            obj.adcResolution = obj.ADAPTER_MODULE_ADC_BIT_DEPTH(digitizerType);
            obj.secondaryFifo = secondaryFifo;
            
            r = obj.ADAPTER_MODULE_AVAIL_INPUT_RANGES(digitizerType);
            m = [-r' r'];
            obj.availInputRanges = mat2cell(m,ones(numel(r),1),2)';
        end
        
        function err = configureStream(obj,registerCallback)
            if nargin < 2 || isempty(registerCallback)
                registerCallback = true;
            end
            
            switch obj.streamMode
                case 'fpga'
                    if ~obj.secondaryFifo
                        obj.hFpga.AcqEngineDoReset = true;
                        obj.hFpga.InterlaceNumChannels = 4;
                    end
                    obj.hFpga.LinearSamplingN = obj.totalSamples;
                    obj.hFpga.NI5771SecondaryLinScanPathEnable = obj.secondaryFifo;
                    obj.hFpga.LinearSamplingEnable = false;
                    obj.hFpga.LinearSamplingResetCounts = true;
                    obj.hFpga.LinearSamplingResetCounts = false;
                    obj.hFpga.LinearSamplingClkTerminalIn = obj.pxiSampClkTrig;
                    
                    switch obj.sampClkPolarity
                        case 'rising'
                            onFallingEdge = false;
                        case 'falling'
                            onFallingEdge = true;
                        otherwise
                            assert(false);
                    end
                    
                    if isprop(obj.hFpga,'LinearSamplingClkOnFallingEdge')
                        obj.hFpga.LinearSamplingClkOnFallingEdge = onFallingEdge;
                    elseif onFallingEdge
                        most.idioms.warn('DataStream: FPGA does not support property LinearSamplingClkOnFallingEdge. Recompile FPGA!!!');
                    end
                    
                    try
                        obj.hFpga.LinearSamplingBinSize = ceil(obj.fpgaBaseRate / obj.sampClkRate);
                    catch
                        %workaround until all targets built
                    end
                    obj.applyFpgaInvertChannels();
                    
                    obj.hFpga = obj.hFpga;
                    
                    if registerCallback
                        err = obj.fpgaAsyncDataStream(1);
                        assert(err == 1, 'Failed to initialze FPGA interface. Error = %d.',err);
                    end
                    
                    try
                        obj.hFifo.configure(min(2^28,obj.bufferSize*5));
                    catch ME
                        error('Failed to configure FPGA FIFO. Error message:\n%s', ME.message);
                    end
                    obj.hFifo.start();
                    try
                        [~] = obj.hFifo.readAll();
                    catch ME
                        if isempty(strfind(ME.message,'-50400')); % filter timeout error
                            ME.rethrow();
                        end
                    end
                    
                    obj.hRouteRegistry.reinitRoutes();
                    
                case 'daq'
                    if obj.totalSamples
                        obj.hTask.sampQuantSampMode = 'DAQmx_Val_FiniteSamps';
                        obj.hTask.sampQuantSampPerChan = obj.totalSamples;
                    else
                        obj.hTask.sampQuantSampPerChan = 16777212; %useful for simulated mode
                        obj.hTask.sampQuantSampMode = 'DAQmx_Val_ContSamps';
                    end
                    
                    %Apply everyNSamples & buffer values
                    obj.hTask.everyNSamples = []; %unregisters callback
                    obj.hTask.cfgInputBufferVerify(obj.bufferSize,2*obj.callbackSamples);
                    
                    switch obj.sampClkPolarity
                        case 'rising'
                            obj.hTask.set('sampClkActiveEdge','DAQmx_Val_Rising');
                        case 'falling'
                            obj.hTask.set('sampClkActiveEdge','DAQmx_Val_Falling');
                        otherwise
                            assert(false);
                    end
                    
                    if registerCallback
                        obj.hTask.everyNSamples = obj.callbackSamples; %registers callback
                    end
                    
                case 'rseries'
                    obj.hFpgaDaq.aiConfigureSampleMode(obj.totalSamples > 0, obj.totalSamples, [0 1 2 3], obj.bufferSize);
                    if registerCallback
                        obj.hFpgaDaq.aiConfigureCallbacks(obj.callbackSamples, @ncb, @dcb);
                    end
                    obj.hFpgaDaq.aiConfigureTrigger(true,4,true);
            end
            
            function ncb()
                try
                    data = obj.hFpgaDaq.aiReadBuffer(obj.callbackSamples,0,true);
                    obj.nSampleCallback(data);
                catch ME
                    disp(['Error reading input data: ' ME.message]);
                end
            end
            
            function dcb()
                availableSamps = obj.hFpgaDaq.aiGetAvailSamps();
                data = obj.hFpgaDaq.read(availableSamps,0,true);
                obj.doneCallback(data);
            end
        end
        
        
        function start(obj)
            assert(~obj.running, 'Task is already running.');
            
            switch obj.streamMode
                case 'fpga'
                    obj.hFpga.LinearSamplingResetCounts = true;
                    obj.hFpga.LinearSamplingResetCounts = false;
                    obj.fpgaAsyncDataStream(3);
                    obj.hFpga.NI5771SecondaryLinScanPathEnable = obj.secondaryFifo;
                    obj.hFpga.LinearSamplingEnable = true;
                    
                case 'daq'
                    obj.hTask.start();
                    
                case 'rseries'
                    obj.hFpgaDaq.aiStart();
            end
        end
        
        function abort(obj)
            switch obj.streamMode
                case 'fpga'
                    obj.hFpga.LinearSamplingEnable = false;
                    
                case 'daq'
                    obj.hTask.abort();
                    
                case 'rseries'
                    obj.hFpgaDaq.aiAbort();
            end
        end
        
        function err = unreserve(obj)
            switch obj.streamMode
                case 'fpga'
                    obj.hFpga.LinearSamplingEnable = false;
                    err = obj.fpgaAsyncDataStream(0);
                    obj.hRouteRegistry.deinitRoutes();
                    [~] = obj.hFifo.readAll();                    
                case 'daq'
                    obj.hTask.control('DAQmx_Val_Task_Unreserve');
                    
                case 'rseries'
            end
        end
        
        function data = acquireSamples(obj,numSamples)
            switch obj.streamMode
                case 'fpga'
                    data = zeros(numSamples,obj.numChannels,'int16');
                    obj.applyFpgaInvertChannels();
                    if obj.simulated
                        data = int16(10*rand(numSamples,obj.numChannels));
                    else
                        for i = 1:numSamples
                            data(i,1:obj.numChannels) = int16(obj.hFpga.DebugRawAdcOutput(1:obj.numChannels));
                        end
                    end
                    
                case 'daq'
                    %fix
                    obj.hTask.control('DAQmx_Val_Task_Unreserve');
                    
                    obj.hTaskOnDemand.abort(); % workaround for issue with PCI-6110, see SCIM-1951674
                    obj.hTaskOnDemand.start(); % workaround
                    data = obj.hTaskOnDemand.readAnalogData(numSamples, 'native', 10);
                    obj.hTaskOnDemand.abort(); % workaround
                    
                case 'rseries'
                    data = zeros(numSamples,obj.numChannels,'int16');
                    %obj.applyFpgaInvertChannels();
                    if obj.simulated
                        data = int16(10*rand(numSamples,obj.numChannels));
                    else
                        for i = 1:numSamples
                            data(i,1:obj.numChannels) = int16(obj.hFpga.AIValues(1:obj.numChannels));
                        end
                    end
            end
        end
        
        function data = read(obj,numSamples)
            switch obj.streamMode
                case 'fpga'
                    data = obj.hFifo.read(numSamples);
                    % unpack data
                    data = typecast(data,'int16');
                    data = reshape(data,4,[]);
                    data = data';
                    
                case 'daq'
                    data = obj.hTask.readAnalogData(numSamples,'native',1);
                    
                case 'rseries'
                    data = hDaq.aiReadBuffer(numSamples,0);
            end
        end
        
        function val = setInputRanges(obj,val)
            switch obj.streamMode
                case 'fpga'
                    switch obj.digitizerType
                        case {'NI5732','NI5733','NI5734'}
                            for channelNumber = 1:obj.numChannels
                                channelRange = val{channelNumber};
                                validateattributes(channelRange,{'numeric'},{'numel', 2});
                                channelUpperLimit = channelRange(2);
                                
                                % Execute user command
                                userCommand = 2; % User command for gain settings (Refer to FlexRIO help)
                                userData0 = channelNumber - 1; %channel Number on FPGA is zero-based
                                userData1 = obj.CHANNEL_INPUT_RANGE_FPGA_COMMAND_DATA_MAP(channelUpperLimit);
                                
                                obj.sendNonBlockingAdapterModuleUserCommand(userCommand,userData0,userData1);
                                
                                val{channelNumber} = channelRange;
                            end
                        case 'NI5751'
                            % the input range of the 5751 is fixed at 2Vpp
                            channelRanges = {};
                            for channelNumber = 1:obj.numChannels
                                channelRanges{channelNumber} = [-1,1];
                            end
                            val = channelRanges;
                        case 'NI517x'
                            obj.configOscopeChannels(val);
                        case 'NI5771'
                            % NOop
                        otherwise
                            assert(false);
                    end
                    obj.inputRanges = val;
                    
                case 'daq'
                    for i = 1:numel(val)
                        inputRange = val{i};
                        validateattributes(inputRange,{'numeric'},{'vector','numel',2});
                        
                        hAIchan = obj.hTask.channels(i);
                        set(hAIchan,'min',inputRange(1));
                        set(hAIchan,'max',inputRange(2));
                    end
                    
                case 'rseries'
                    for i = 1:4
                        inputRange = val{i};
                        validateattributes(inputRange,{'numeric'},{'vector','numel',2});
                        
                        prop = ['AI' num2str(i-1) 'VoltageRange'];
                        v = ['+/- ' num2str(inputRange(2)) ' V'];
                        
                        obj.hFpga.(prop) = v;
                    end
                    obj.inputRanges = val;
            end
        end
        
        function configOscopeChannels(~,rgs)
            coupling = false; % false = DC coupling; true = AC coupling
            
            for ch = 0:3
                r = rgs{ch+1};
                r = r(2) - r(1);
                err = dabs.ni.oscope.configureChannel(ch, r, true, coupling);
                assert(err == 0, 'Error when attempting to configure NI 517x device. Code = %d', err);
            end
        end
        
        function sendNonBlockingAdapterModuleUserCommand(obj,userCommand,userData0,userData1)
            if isempty(strfind(obj.digitizerType,'NI573'))
                obj.dispDbgMsg('Adapter module %s does not support user commands',obj.digitizerType);
                return
            end
            
            % Wait for module to be ready to accept user command input
            assert(obj.waitModuleUserCommandIdle,'Module is not idle - failed to send command');
            
            % Execute user command
            obj.hFpga.AdapterModuleUserCommand = userCommand;
            obj.hFpga.AdapterModuleUserData0 = userData0;
            obj.hFpga.AdapterModuleUserData1 = userData1;
            obj.hFpga.AdapterModuleDoUserCommandCommit = true;
        end
		
        function idle = waitModuleUserCommandIdle(obj)
            % Wait for FPGA to be ready to accept user command inputs
            idle = true;
            start = tic();
            while obj.hFpga.AdapterModuleUserCommandIdle == 0
                if toc(start) > 0.5
                    idle = false;
                    return;
                else
                    pause(0.01);
                end
            end
        end
        
        function val = getInputRanges(obj)
            switch obj.streamMode
                case {'fpga' 'rseries'}
                    val = obj.inputRanges;
                    
                case 'daq'
                    numChans = numel(obj.hTask.channels);
                    val = cell(1,numChans);
                    for i = 1:numChans
                        hAIChan = obj.hTask.channels(i);
                        min = get(hAIChan,'min');
                        max = get(hAIChan,'max');
                        val{i} = [min, max];
                    end
            end
        end
        
        function val = getAvailInputRanges(obj)
            if isempty(obj.availInputRanges)
                switch obj.streamMode
                    case 'fpga'
                        % set when fpga type is set
                        
                    case 'daq'
                        %Retrieve AI voltage ranges directly - DAQmx interface does not currently 'get' vector-valued numeric properties correctly
                        maxArrayLength = 100;
                        [~, voltageRangeArray] = obj.hTask.apiCall('DAQmxGetDevAIVoltageRngs', obj.hTask.deviceNames{1}, zeros(maxArrayLength,1), maxArrayLength);
                        
                        voltageRangeArray(voltageRangeArray == 0) = []; %Remove trailing zeros
                        val = reshape(voltageRangeArray,2,[])';
                        obj.availInputRanges = mat2cell(val,ones(1,size(val,1)))'; % repack each line of the 2D array into a cell array
                    
                    case 'rseries'
                        % set during construction
                end
            end
            
            val = obj.availInputRanges;
        end
        
        function val = getNumAvailChans(obj,maxn,dev,limitMultiplexedDevices)
            if nargin < 4 || isempty(limitMultiplexedDevices)
                limitMultiplexedDevices = true;
            end
            
            % maxn and dev are required for daq type
            if isempty(obj.numChannels)
                switch obj.streamMode
                    case 'fpga'
                        % set when fpga type is set
                        
                    case 'daq'
                        % fix
                        hDaqDeviceAcq = dabs.ni.daqmx.Device(dev);
                        simultaneousSampling = get(hDaqDeviceAcq,'AISimultaneousSamplingSupported');
                        if simultaneousSampling || ~limitMultiplexedDevices
                            channelNames = hDaqDeviceAcq.get('AIPhysicalChans');
                            channelNames = strsplit(channelNames, ', ');
                            obj.numChannels = length(channelNames);
                            obj.numChannels = min([obj.numChannels maxn]);
                        else
                            obj.numChannels = 1; % on multiplexed boards only one channel is available
                        end
                    
                    case 'rseries'
                        obj.numChannels = 4;
                end
            end
            val = obj.numChannels;
        end
        
        function disableStartTrig(obj)
            switch obj.streamMode
                case 'fpga'
                    %no op
                    
                case 'daq'
                    obj.hTask.disableStartTrig();
                    
                case 'rseries'
                    %no op
            end
        end
        
        function configureStartTrigger(obj,terminal,edge)
            switch obj.streamMode
                case 'fpga'
                    error('Start tigger not suppored!');
                    
                case 'daq'
                    obj.hTask.cfgDigEdgeStartTrig(terminal,edge);
                    
                case 'rseries'
                    % AI always triggers off AO
            end
        end
    end
    
    methods (Hidden)
        function applyFpgaInvertChannels(obj)
            currentVal = obj.hFpga.AcqParamLiveInvertChannels;
            newVal = [obj.fpgaInvertChannels , currentVal(numel(obj.fpgaInvertChannels)+1:end)];
            obj.hFpga.AcqParamLiveInvertChannels = newVal;
        end
    end
    
    %% Prop Access
    methods
        function val = get.adcResolution(obj)
            switch obj.streamMode
                case {'fpga' 'rseries'}
                    val = obj.adcResolution;
                    
                case 'daq'
                    channel = obj.hTask.channels(1);
                    val = get(channel,'resolution');
            end
        end
        
        function set.hFifo(obj,v)
            obj.hFifo = v;
            obj.fpgaFifoNum = v.fifoNumber;
            
            obj.hFpga = v.hFpga;
        end
        
        function set.hFpga(obj,v)
            obj.hFpga = v;
            obj.fpgaSession = v.session;
        end
        
        function set.sampClkSrc(obj,v)
            switch obj.streamMode
                case 'fpga'
                    obj.hRouteRegistry.clearRoutes();
                    obj.sampClkSrc = [];
                    
                    if ~isempty(v)
                        slashes = strfind(v,'/');
                        dst = [v(1:slashes(end)) obj.pxiSampClkTrig];
                        obj.hRouteRegistry.connectTerms(v,dst);
                        obj.sampClkSrc = v;
                        obj.hRouteRegistry.deinitRoutes();
                    end
                    
                case 'daq'
                    obj.hTask.set('sampClkSrc',v);
                    
                case 'rseries'
                    error('External sample clock not supported with R-Series.')
            end
        end
        
        function v = get.sampClkSrc(obj)
            switch obj.streamMode
                case 'fpga'
                    v = obj.sampClkSrc;
                    
                case 'daq'
                    v = obj.hTask.get('sampClkSrc');
                    
                case 'rseries'
                    v = 'internal';
            end
        end
        
        function set.sampClkRate(obj,v)
            diffs = abs(v - obj.validSampleRates);
            [~,i] = min(diffs);
            v = obj.validSampleRates(i);
            
            switch obj.streamMode
                case 'fpga'
                    obj.sampClkRate = v;
                    
                case 'daq'
                    obj.hTask.set('sampClkRate',v);
                    
                case 'rseries'
                    obj.hFpga.LoopPeriodControlticks = 40e6 / v;
            end
        end
        
        function v = get.sampClkRate(obj)
            switch obj.streamMode
                case 'fpga'
                    v = obj.sampClkRate;
                    
                case 'daq'
                    v = obj.hTask.get('sampClkRate');
                    
                case 'rseries'
                    v = 40e6 / double(obj.hFpga.LoopPeriodControlticks);
            end
        end
        
        function set.bufferSize(obj,v)
            obj.bufferSize = uint32(v);
        end
        
        function set.callbackSamples(obj,v)
            obj.callbackSamples = uint32(v);
        end
        
        function set.totalSamples(obj,v)
            obj.totalSamples = uint64(v);
        end
        
        function v = get.running(obj)
            switch obj.streamMode
                case 'fpga'
                    v = (obj.hSE > 0) && obj.hFpga.LinearSamplingEnable && (obj.hFpga.LinearSamplingSamplesDone < obj.hFpga.LinearSamplingN);
                    
                case 'daq'
                    v = ~obj.hTask.isTaskDoneQuiet();
                    
                case 'rseries'
                    v = ~strcmp(obj.hFpgaDaq.aiTaskState,'Idle');
            end
        end
        
        function v = get.sampClkMaxRate(obj)
            switch obj.streamMode
                case 'fpga'
                    v = obj.sampClkMaxRate;
                    
                case 'daq'
                    v = obj.hTask.get('sampClkMaxRate');
                    
                case 'rseries'
                    v = 1e6;
            end
        end
        
        function set.sampClkTimebaseRate(obj,v)
            obj.sampClkTimebaseRate = v;
            
            switch obj.streamMode
                case 'fpga'
                    vals = intersect(obj.fpgaBaseRate./(4:65500),v./(4:65500));
                    obj.validSampleRates = vals(end:-1:1);
                    obj.sampClkMaxRate = vals(end);
                    
                case 'daq'
                    vals = v./(4:65500);
                    vals(vals > obj.sampClkMaxRate) = [];
                    obj.validSampleRates = vals(end:-1:1);
                    
                case 'rseries'
                    obj.sampClkTimebaseRate = 40e6;
                    assert(v == obj.sampClkTimebaseRate, 'Cannot change the timebase rate when using an R-Series FPGA.');
            end
        end
    end
    
    %% Mex methods
    methods
        err = fpgaAsyncDataStream(obj,op);
        % op: 0=deinit
        % op: 1=configure
        % op: 2=read data
        % op: 3=clear data
    end
    
end



%--------------------------------------------------------------------------%
% DataStream.m                                                             %
% Copyright © 2018 Vidrio Technologies, LLC                                %
%                                                                          %
% ScanImage is licensed under the Apache License, Version 2.0              %
% (the "License"); you may not use any files contained within the          %
% ScanImage release  except in compliance with the License.                %
% You may obtain a copy of the License at                                  %
% http://www.apache.org/licenses/LICENSE-2.0                               %
%                                                                          %
% Unless required by applicable law or agreed to in writing, software      %
% distributed under the License is distributed on an "AS IS" BASIS,        %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. %
% See the License for the specific language governing permissions and      %
% limitations under the License.                                           %
%--------------------------------------------------------------------------%
