classdef LinearScanner < handle
    properties
        name = '';
        travelRange;
        parkPosition = -9;
        daqOutputRange;
    end
    
    properties
        simulated = false;
        
        hFpga;
        hFpgaDaq;
        
        positionDeviceName;
        positionChannelID;
        
        feedbackDeviceName;
        feedbackChannelID;
        feedbackTermCfg = 'Differential';
        
        offsetDeviceName;
        offsetChannelID;
        
        position2VoltFcn = [];
        volt2PositionFcn = [];
        voltsPerDistance = 0.5;
        distanceVoltsOffset = 0;
        
        feedbackVoltInterpolant = [];
        feedbackVoltFcn = [];
        
        positionMaxSampleRate = [];
        
        offsetVoltScaling = NaN;
    end
    
    properties (Hidden, SetAccess = private)
        positionTaskOnDemand;
        positionTask;
        feedbackTaskOnDemand;
        feedbackTask;
        offsetTaskOnDemand;
        offsetTask;
        
        parkPositionVolts;
    end
    
    properties (Dependent)
        positionAvailable;
        feedbackAvailable;
        offsetAvailable;
        feedbackCalibrated;
        offsetCalibrated;
        calibrationData;
    end

    methods
        function obj=LinearScanner()
            [~,uuid] = most.util.generateUUIDuint64();
            obj.name = sprintf('Linear Scanner %s',uuid); % ensure unique Task names
        end
        
        function delete(obj)
            most.idioms.safeDeleteObj(obj.positionTaskOnDemand);
            most.idioms.safeDeleteObj(obj.positionTask);
            most.idioms.safeDeleteObj(obj.feedbackTaskOnDemand);
            most.idioms.safeDeleteObj(obj.feedbackTask);
            most.idioms.safeDeleteObj(obj.offsetTaskOnDemand);
            most.idioms.safeDeleteObj(obj.offsetTask);
        end
    end
    
    %% Setter / Getter methods
    methods
        function set.travelRange(obj,val)
            validateattributes(val,{'numeric'},{'finite','size',[1,2]});
            val = sort(val);
            obj.travelRange = val;
            obj.parkPosition = max(min(obj.parkPosition,obj.travelRange(2)),obj.travelRange(1));
        end
        
        function v = get.travelRange(obj)
            if isempty(obj.travelRange)
                if obj.positionAvailable
                    v = obj.volts2Position(obj.daqOutputRange);
                    v = sort(v);
                else
                    v = [-10 10]; %default
                end
            else
                v = obj.travelRange;
            end
        end
        
        function set.voltsPerDistance(obj,val)
            validateattributes(val,{'numeric'},{'finite','scalar'});
            obj.voltsPerDistance = val;
        end
        
        function set.distanceVoltsOffset(obj,val)
            validateattributes(val,{'numeric'},{'finite','scalar'});
            obj.distanceVoltsOffset = val;
        end
        
        function set.parkPosition(obj,val)
            validateattributes(val,{'numeric'},{'finite','scalar'});
            obj.parkPosition = val;
        end
        
        function set.feedbackVoltInterpolant(obj,val)
            if isa(val,'struct')
                val = structToGriddedInterpolant(val);
            end
            
            if ~isempty(val)
                assert(isa(val,'griddedInterpolant'));
            end
            obj.feedbackVoltInterpolant = val;
        end
        
        function set.offsetVoltScaling(obj,val)
            validateattributes(val,{'numeric'},{'scalar'});
            obj.offsetVoltScaling = val;
        end
        
        function set.positionDeviceName(obj,val)
           if isempty(val)
               val = '';
           else
               validateattributes(val,{'char'},{'row'});
           end
           
           obj.positionDeviceName = val;
           obj.createPositionTask();
        end
        
        function set.positionChannelID(obj,val)
            if isempty(val)
                val = [];
            else
                if ischar(val)
                    val = str2double(val);
                end
                validateattributes(val,{'numeric'},{});
            end
            
            obj.positionChannelID = val;
            obj.createPositionTask();
        end
        
        function set.feedbackDeviceName(obj,val)
            if isempty(val)
                val = '';
            else
                validateattributes(val,{'char'},{'row'});
            end
            
            obj.feedbackDeviceName = val;
            obj.createFeedbackTask();
        end
        
        function set.feedbackChannelID(obj,val)
            if isempty(val)
                val = [];
            else
                if ischar(val)
                    val = str2double(val);
                end
                validateattributes(val,{'numeric'},{'scalar'});
            end
            
            obj.feedbackChannelID = val;
            obj.createFeedbackTask();
        end
        
        function set.feedbackTermCfg(obj,val)
            if isempty(val)
                val = 'Differential';
            else
                assert(ismember(val,{'Differential','RSE','NRSE'}),'Invalid terminal configuration ''%s''.',val);
            end
            
            obj.feedbackTermCfg = val;
            obj.createFeedbackTask();
        end
        
        function set.offsetDeviceName(obj,val)
            if isempty(val)
                val = '';
            else
                validateattributes(val,{'char'},{'row'});
            end
            
            obj.offsetDeviceName = val;
            obj.createOffsetTask();
        end
        
        function set.offsetChannelID(obj,val)
            if isempty(val)
                val = [];
            else
                if ischar(val)
                    val = str2double(val);
                end
                validateattributes(val,{'numeric'},{'scalar'});
            end
            
            obj.offsetChannelID = val;
            obj.createOffsetTask();
        end
        
        function val = get.positionAvailable(obj)
            val = ~isempty(obj.positionTaskOnDemand) && isvalid(obj.positionTaskOnDemand);
        end
        
        function val = get.feedbackAvailable(obj)
            val = ~isempty(obj.feedbackTaskOnDemand) && isvalid(obj.feedbackTaskOnDemand);
        end
        
        function val = get.offsetAvailable(obj)
            val = ~isempty(obj.offsetTaskOnDemand) && isvalid(obj.offsetTaskOnDemand);
        end
        
        function val = get.feedbackCalibrated(obj)
            val = ~isempty(obj.feedbackVoltInterpolant) || ~isempty(obj.feedbackVoltFcn);
        end
        
        function val = get.offsetCalibrated(obj)
            val = ~isempty(obj.offsetVoltScaling) && ~isnan(obj.offsetVoltScaling);
        end
        
        function val = get.calibrationData(obj)
            val = struct(...
                 'feedbackVoltInterpolant',griddedInterpolantToStruct(obj.feedbackVoltInterpolant)...
                ,'offsetVoltScaling'      ,obj.offsetVoltScaling...
                );
        end
        
        function set.calibrationData(obj,val)
            assert(isstruct(val));
            props = fieldnames(val);
            
            for idx = 1:length(props)
                prop = props{idx};
                if isprop(obj,prop)
                   obj.(prop) = val.(prop); 
                else
                    most.idioms.warn('%s: Unknown calibration property: %s. You might have to recalibrate the scanner feedback and offset.',obj.name,prop);
                end
            end
        end
        
        function v = get.parkPositionVolts(obj)
            v = obj.position2Volts(obj.parkPosition);
        end
        
        function set.hFpga(obj,v)
            obj.hFpga = v;
            obj.hFpgaDaq = dabs.ni.rio.fpgaDaq.fpgaDaq(v, 'NI7855');
        end
    end
    
    %% Public methods
    methods        
        function val = volts2Position(obj,val)
            if isempty(obj.volt2PositionFcn)
                val = (val - obj.distanceVoltsOffset) ./ obj.voltsPerDistance;
            else
                val = obj.volt2PositionFcn(val);
            end
        end
        
        function val = position2Volts(obj,val)
            if isempty(obj.position2VoltFcn)
                val = val .* obj.voltsPerDistance + obj.distanceVoltsOffset;
            else
                val = obj.position2VoltFcn(val);
            end
            
            % support more than one output channel
            if size(val,2) ~= numel(obj.positionChannelID)
                val = repmat(val,1,numel(obj.positionChannelID));
            end
        end
        
        function val = feedbackVolts2PositionVolts(obj,val)
            if ~isempty(obj.feedbackVoltFcn)
                val = obj.feedbackVoltFcn(val);
            elseif ~isempty(obj.feedbackVoltInterpolant)
                val = obj.feedbackVoltInterpolant(val);
            else
                error('%s: Feedback not calibrated', obj.name);
            end
        end
        
        function unreserveResource(obj)
            obj.positionTaskOnDemand.control('DAQmx_Val_Task_Unreserve');
        end
        
        function val = feedbackVolts2Position(obj,val)
            val = obj.feedbackVolts2PositionVolts(val);
            val = obj.volts2Position(val);
        end
        
        function val = position2OffsetVolts(obj,val)
            val = obj.position2Volts(val);
            val = val.* obj.offsetVoltScaling;
        end
        
        function park(obj)
            obj.pointPosition(obj.parkPosition);
        end
        
        function center(obj)
            obj.pointPosition(sum(obj.travelRange)./2);
        end
        
        function pointPosition(obj,position)
            assert(obj.positionAvailable,'%s: Position output not initialized', obj.name);
            volt = obj.position2Volts(position);
            obj.positionTaskOnDemand.writeAnalogData(volt);
            
            if obj.offsetAvailable
                obj.pointOffsetPosition(0);
            end
        end
        
        function pointOffsetPosition(obj,position)
            assert(obj.offsetAvailable,'%s: Offset output not initialized', obj.name);
            volt = obj.position2OffsetVolts(position);
            obj.offsetTaskOnDemand.writeAnalogData(volt);
        end
        
        function [positionMean, positionSamples] = readFeedbackPosition(obj,n)
            if nargin < 2 || isempty(n)
                n = 100;
            end
            
            assert(obj.feedbackAvailable,'%s: feedback not configured - Cannot read feedback channel.\n',obj.name);
            
            obj.feedbackTaskOnDemand.control('DAQmx_Val_Task_Unreserve');
            volt = obj.feedbackTaskOnDemand.readAnalogData(n,[],1);
            positionSamples = obj.feedbackVolts2Position(volt);
            positionMean = mean(positionSamples);
        end
        
        function calibrate(obj,hWb)
            if nargin<2 || isempty(hWb)
                hWb = [];
            end
            
            if obj.positionAvailable && obj.feedbackAvailable
                fprintf('%s: calibrating feedback',obj.name);
                obj.calibrateFeedback(true,hWb);
                if obj.offsetAvailable
                    fprintf(', offset');
                    obj.calibrateOffset(true,hWb);
                end
                fprintf(' ...done!\n');
            else
                error('%s: feedback not configured - nothing to calibrate\n',obj.name);
            end
        end
        
        function calibrateFeedback(obj,preventTrip,hWb)
            if nargin < 2 || isempty(preventTrip)
                preventTrip = true;
            end
            
            if nargin < 3 || isempty(hWb)
                hWb = [];
            end
            
            if ~isempty(hWb)
                if ~isvalid(hWb)
                    return
                else
                    msg = sprintf('%s: calibrating feedback',obj.name);
                    waitbar(0,hWb,msg);
                end
            end
            
            assert(obj.positionAvailable,'Position output not initialized');
            assert(obj.feedbackAvailable,'Feedback input not initialized');
            
            if obj.offsetAvailable
                obj.offsetTaskOnDemand.writeAnalogData(0);
            end
            
            numTestPoints = 10;
            rangeFraction = 0.8;
            
            travelRangeMidPoint = sum(obj.travelRange)/2;
            travelRangeCompressed = diff(obj.travelRange)*rangeFraction;
            
            outputPositions = linspace(travelRangeMidPoint-travelRangeCompressed/2,travelRangeMidPoint+travelRangeCompressed/2,numTestPoints)';
            
            % move to first position
            obj.smoothTransitionPosition(obj.parkPosition,outputPositions(1));
            if preventTrip
                pause(3); % we assume we were at the park position initially, but we cannot know for sure. If galvo trips, wait to make sure they recover
            end
            
            feedbackVolts = zeros(length(outputPositions),1);
            
            cancelled = false;
            for idx = 1:length(outputPositions)
                if idx > 1
                    obj.smoothTransitionPosition(outputPositions(idx-1),outputPositions(idx));
                    pause(0.5); %settle
                end
                averageNSamples = 100;
                samples = obj.feedbackTaskOnDemand.readAnalogData(averageNSamples,[],10);
                feedbackVolts(idx) = mean(samples);
                
                if ~isempty(hWb)
                    if ~isvalid(hWb)
                        cancelled = true;
                        break
                    else
                        waitbar(idx/length(outputPositions),hWb,msg);
                    end
                end
            end
            
            % park the galvo
            obj.smoothTransitionPosition(outputPositions(end),obj.parkPosition);
            
            if cancelled
                return
            end
            
            [feedbackVolts,sortIdx] = sort(feedbackVolts); % grid vectors of griddedInterpolant have to be strictly monotonic increasing
            outputPositions = outputPositions(sortIdx);
            
            outputVolts = obj.position2Volts(outputPositions);
            
            feedbackVoltInterpolant_old = obj.feedbackVoltInterpolant;
            try
                feedbackVoltInterpolant_new = griddedInterpolant(feedbackVolts,outputVolts,'linear','linear');
            catch ME
                plotCalibrationCurveUnsuccessful();
                rethrow(ME);
            end
            
            obj.feedbackVoltInterpolant = feedbackVoltInterpolant_new;
            obj.feedbackVoltFcn = [];
            
            % validation
            feedbackPosition = obj.feedbackVolts2Position(feedbackVolts(:,1));
            err = outputPositions - feedbackPosition;
            if std(err) < 0.1
                % success
                plotCalibrationCurve();
            else
                % failure
                obj.feedbackVoltInterpolant = feedbackVoltInterpolant_old;
                plotCalibrationCurveUnsuccessful();
                fprintf(2,'Feedback calibration for scanner ''%s'' unsuccessful. SD: %f\n',obj.name,std(err));
            end
            
            %%% local functions
            function plotCalibrationCurve()
                hFig = figure('NumberTitle','off','Name','Scanner Calibration');
                hAx = axes('Parent',hFig,'box','on');
                plot(hAx,obj.feedbackVoltInterpolant.Values,obj.feedbackVoltInterpolant.GridVectors{1},'o-');
                title(hAx,sprintf('%s Feedback calibration',obj.name));
                xlabel(hAx,'Position Output Volt');
                ylabel(hAx,'Position Feedback Volt');
                grid(hAx,'on');
                drawnow();
            end
            
            function plotCalibrationCurveUnsuccessful()
                hFig = figure('NumberTitle','off','Name','Scanner Calibration');
                hAx = axes('Parent',hFig,'box','on');
                plot(hAx,[outputVolts(:,1),feedbackVolts(:,1)],'o-');
                legend(hAx,'Command Voltage','Feedback Voltage');
                title(hAx,sprintf('%s Feedback calibration\nunsuccessful',obj.name));
                xlabel(hAx,'Sample');
                ylabel(hAx,'Voltage');
                grid(hAx,'on');
                drawnow();
            end
        end
        
        function calibrateOffset(obj,preventTrip,hWb)
            if nargin < 2 || isempty(preventTrip)
                preventTrip = true;
            end
            
            if nargin < 3 || isempty(hWb)
                hWb = [];
            end
            
            assert(obj.positionAvailable,'Position output not initialized');
            assert(obj.feedbackAvailable,'Feedback input not initialized');
            assert(obj.offsetAvailable,'Offset output not initialized');
            
            if ~isempty(hWb)
                if ~isvalid(hWb)
                    return
                else
                    msg = sprintf('%s: calibrating offset',obj.name);
                    waitbar(0,hWb,msg);
                end
            end
            
            % center the galvo
            obj.smoothTransitionPosition(obj.parkPosition,0);
            
            numTestPoints = 10;
            rangeFraction = 0.25;
            
            outputPositions = linspace(obj.travelRange(1),obj.travelRange(2),numTestPoints)';
            outputPositions = outputPositions .* rangeFraction;
            
            % move to first position
            obj.smoothTransitionPosition(0,outputPositions(1),'offset');
            if preventTrip
                pause(3); % we assume we were at the park position initially, but we cannot know for sure. If galvo trips, wait to make sure they recover
            end
            
            feedbackVolts = zeros(length(outputPositions),1);
            
            cancelled = false;
            for idx = 1:length(outputPositions)
                if idx > 1
                    obj.smoothTransitionPosition(outputPositions(idx-1),outputPositions(idx),'offset');
                    pause(0.5); %settle
                end
                averageNSamples = 100;
                samples = obj.feedbackTaskOnDemand.readAnalogData(averageNSamples,[],10);
                feedbackVolts(idx) = mean(samples);
                
                if ~isempty(hWb)
                    if ~isvalid(hWb)
                        cancelled = true;
                        break
                    else
                        waitbar(idx/length(outputPositions),hWb,msg);
                    end
                end
            end
            
            % park the galvo
            obj.smoothTransitionPosition(outputPositions(end),0,'offset');
            obj.smoothTransitionPosition(0,obj.parkPosition);
            
            obj.park();
            
            if cancelled
                return
            end
            
            outputVolts = obj.position2Volts(outputPositions);
            outputVolts(:,2) = 1;
            
            feedbackVolts = obj.feedbackVolts2PositionVolts(feedbackVolts); % pre-scale the feedback
            feedbackVolts(:,2) = 1;
            
            offsetTransform = outputVolts' * pinv(feedbackVolts'); % solve in the least square sense
            
            offsetVoltOffset = offsetTransform(1,2);
            assert(offsetVoltOffset < 10e-3,'Offset Calibration failed because Zero Position and Zero Offset are misaligned.');  % this should ALWAYS be in the noise floor
            obj.offsetVoltScaling = offsetTransform(1,1);
        end
        
        function feedback = testWaveformVolts(obj,waveformVolts,sampleRate,preventTrip,startVolts,goToPark,hWb)
            assert(obj.positionAvailable,'Position output not initialized');
            assert(obj.feedbackAvailable,'Feedback input not configured');
            assert(obj.feedbackCalibrated,'Feedback input not calibrated');
            
            if nargin < 4 || isempty(preventTrip)
                preventTrip = true;
            end
            
            if nargin < 5 || isempty(startVolts)
                startVolts = waveformVolts(1);
            end
            
            if nargin < 6 || isempty(goToPark)
                goToPark = true;
            end
            
            if nargin < 7 || isempty(hWb)
                hWb = waitbar(0,'Preparing Waveform and DAQs...','CreateCancelBtn',@(src,evt)delete(ancestor(src,'figure')));
                deletewb = true;
            else
                deletewb = false;
            end
            
            try
                if ~isempty(obj.offsetTaskOnDemand) && isvalid(obj.offsetTaskOnDemand)
                    obj.offsetTaskOnDemand.writeAnalogData(0);
                end
                
                %move to first position
                if preventTrip
                    obj.smoothTransitionVolts(obj.position2Volts(obj.parkPosition),startVolts);
                    pause(2); % we assume we were at the park position initially, but we cannot know for sure. If galvo trips, wait to make sure they recover
                else
                    obj.positionTaskOnDemand.writeAnalogData(startVolts);
                end
                
                obj.positionTask.cfgSampClkTiming(sampleRate,'DAQmx_Val_FiniteSamps',length(waveformVolts));
                % get('sampClkTerm') might not work with 6110. instead use explicit name
                sampClkTerm = sprintf('/%s/ao/SampleClock',obj.positionTask.deviceNames{1});
                obj.feedbackTask.cfgSampClkTiming(sampleRate,'DAQmx_Val_FiniteSamps',length(waveformVolts),sampClkTerm);
                assert(isequal(obj.feedbackTask.sampClkRate,obj.positionTask.sampClkRate,sampleRate),'Sample Rate %fHz is not achievable.',sampleRate);
                
                obj.positionTask.disableStartTrig();
                %get('startTrigTerm') returns an empty string for 6110. Need to explicitly specify ao/StartTrigger for compatibility
                %obj.feedbackTask.cfgDigEdgeStartTrig(sprintf('/%s/ao/StartTrigger',obj.positionTask.deviceNames{1}));
                obj.feedbackTask.disableStartTrig(); % now shares the sample clock with positionTask - no triggering required
                
                if ~isempty(obj.hFpgaDaq)
                    obj.feedbackTask.hFpgaDaq.aiConfigureTrigger(true,4,false);
                    obj.positionTask.hFpgaDaq.aoConfigureTrigger(true,5,false);
                end
                
                obj.positionTask.writeAnalogData(waveformVolts(:));
                
                obj.feedbackTask.start();
                obj.positionTask.start();
                
                duration = length(waveformVolts)/sampleRate;
                if duration > 1
                    start = tic();
                    while toc(start) < duration
                        pause(0.1);
                        if ~updateCheckWb(hWb, toc(start)./duration, sprintf('%s: executing waveform test...',obj.name))
                            abort();
                            error('Waveform test cancelled by user');
                        end
                    end
                end
                
                if deletewb
                    most.idioms.safeDeleteObj(hWb);
                end
                
                obj.feedbackTask.waitUntilTaskDone(3);
                feedbackVolts = obj.feedbackTask.readAnalogData(length(waveformVolts));
                
                abort();

                if goToPark
                    % park the galvo
                    obj.smoothTransitionVolts(waveformVolts(end),obj.position2Volts(obj.parkPosition));
                end
                
                % scale the feedback
                feedback = obj.feedbackVolts2PositionVolts(feedbackVolts);
            catch ME
                abort();
                obj.park();
                if deletewb
                    most.idioms.safeDeleteObj(hWb);
                end
                rethrow(ME);
            end
            
            function abort()
                obj.feedbackTask.abort();
                obj.positionTask.abort();
                obj.feedbackTask.control('DAQmx_Val_Task_Unreserve');
                obj.positionTask.control('DAQmx_Val_Task_Unreserve');
                obj.feedbackTask.sampClkSrc = '';
            end
            
            function continuetf = updateCheckWb(wb,prog,msg)
                if isa(wb,'function_handle')
                    continuetf = wb(prog,msg);
                else
                    continuetf = isvalid(hWb);
                    if continuetf
                        waitbar(toc(start)./duration,hWb,sprintf('%s: executing waveform test...',obj.name));
                    end
                end
            end
        end
        
        function smoothTransitionPosition(obj,old,new,varargin)
            obj.smoothTransitionVolts(obj.position2Volts(old),obj.position2Volts(new),varargin{:});
        end
        
        function smoothTransitionVolts(obj,old,new,type)
            if nargin < 4 || isempty(type)
                type = 'position';
            end
            
            duration = 0.1;
            numsteps = 100;
            
            switch lower(type)
                case 'position'
                    hTask = obj.positionTask;
                case 'offset'
                    hTask = obj.offsetTask;
                otherwise
                    error('Unknown task type: %s',type);
            end
            
            assert(~isempty(hTask) && isvalid(hTask));
            
            try
                aoData = linspace(old,new,numsteps)';
                hTask.abort();
                hTask.cfgSampClkTiming(numsteps/duration,'DAQmx_Val_FiniteSamps',numsteps);
                hTask.disableStartTrig();
                hTask.writeAnalogData(aoData);
                hTask.start()
                hTask.waitUntilTaskDone(duration+3);
                hTask.abort();
                hTask.control('DAQmx_Val_Task_Unreserve');
            catch ME
                hTask.abort();
                hTask.control('DAQmx_Val_Task_Unreserve');
                rethrow(ME);
            end
        end
    end
    
    methods (Access = private)
        function createPositionTask(obj)
            most.idioms.safeDeleteObj(obj.positionTaskOnDemand);
            most.idioms.safeDeleteObj(obj.positionTask);
            
            obj.positionTaskOnDemand = [];
            obj.positionTask = [];
            
            if isempty(obj.positionDeviceName) || isempty(obj.positionChannelID)
                return
            end
            
            taskName = sprintf('%s LS Position On Demand',obj.name);
            obj.positionTaskOnDemand = dabs.ni.rio.fpgaDaq.fpgaDaqAOTask.createTaskObj(taskName, obj.hFpgaDaq);
            obj.positionTaskOnDemand.createAOVoltageChan(obj.positionDeviceName, obj.positionChannelID, 'Galvo position channel');
            
            taskName = sprintf('%s LS Position',obj.name);
            obj.positionTask = dabs.ni.rio.fpgaDaq.fpgaDaqAOTask.createTaskObj(taskName, obj.hFpgaDaq);
            obj.positionTask.createAOVoltageChan(obj.positionDeviceName, obj.positionChannelID, 'Galvo position channel');
            obj.positionTask.cfgSampClkTiming(1000,'DAQmx_Val_FiniteSamps',1000);
            obj.positionMaxSampleRate = obj.positionTask.get('sampClkMaxRate');
            obj.daqOutputRange = [obj.positionTask.channels(1).get('min') obj.positionTask.channels(1).get('max')];
        end
        
        function createFeedbackTask(obj)
            most.idioms.safeDeleteObj(obj.feedbackTaskOnDemand);
            most.idioms.safeDeleteObj(obj.feedbackTask);
            
            obj.feedbackTaskOnDemand = [];
            obj.feedbackTask = [];
            
            if isempty(obj.feedbackDeviceName) || isempty(obj.feedbackChannelID)
                return
            end
            
            taskName = sprintf('%s LS Feedback On Demand',obj.name);
            obj.feedbackTaskOnDemand = dabs.ni.rio.fpgaDaq.fpgaDaqAITask.createTaskObj(taskName, obj.hFpgaDaq);
            obj.feedbackTaskOnDemand.createAIVoltageChan(obj.feedbackDeviceName, obj.feedbackChannelID, 'Galvo feedback channel',[],[],[],[],daqMxTermCfgString(obj.feedbackTermCfg));
            
            taskName = sprintf('%s LS Feedback',obj.name);
            obj.feedbackTask = dabs.ni.rio.fpgaDaq.fpgaDaqAITask.createTaskObj(taskName, obj.hFpgaDaq);
            obj.feedbackTask.createAIVoltageChan(obj.feedbackDeviceName, obj.feedbackChannelID, 'Galvo feedback channel',[],[],[],[],daqMxTermCfgString(obj.feedbackTermCfg));
            obj.feedbackTask.cfgSampClkTiming(1000,'DAQmx_Val_FiniteSamps',1000);
            
            % workaround for Kaspar's rig
            obj.feedbackTask.registerEveryNSamplesEvent(@doNothing,10000,false);
            
            function cfg = daqMxTermCfgString(str)
                if length(str) > 4
                    str = str(1:4);
                end
                cfg = ['DAQmx_Val_' str];
            end
            
            function doNothing(varargin)
                % do Nothing
            end
        end
        
        function createOffsetTask(obj)
            most.idioms.safeDeleteObj(obj.offsetTaskOnDemand);
            most.idioms.safeDeleteObj(obj.offsetTask);
            
            obj.offsetTaskOnDemand = [];
            obj.offsetTask = [];
            
            if isempty(obj.offsetDeviceName) || isempty(obj.offsetChannelID)
                return
            end
            
            obj.offsetTaskOnDemand = most.util.safeCreateTask(sprintf('%s LS Offset On Demand',obj.name));
            obj.offsetTaskOnDemand.createAOVoltageChan(obj.offsetDeviceName, obj.offsetChannelID, 'Galvo offset channel');
            
            obj.offsetTask = most.util.safeCreateTask(sprintf('%s LS Offset',obj.name));
            obj.offsetTask.createAOVoltageChan(obj.offsetDeviceName, obj.offsetChannelID, 'Galvo offset channel');
            obj.offsetTask.cfgSampClkTiming(1000,'DAQmx_Val_FiniteSamps',1000);
        end
    end
end


function gistruct = griddedInterpolantToStruct(hGI)
if isempty(hGI)
    gistruct = [];
else
    gistruct = struct();
    gistruct.GridVectors = hGI.GridVectors;
    gistruct.Values = hGI.Values;
    gistruct.Method = hGI.Method;
    gistruct.ExtrapolationMethod = hGI.ExtrapolationMethod;
end
end

function hGI = structToGriddedInterpolant(gistruct)
if isempty(gistruct)
    hGI = [];
else
   hGI = griddedInterpolant (...
       gistruct.GridVectors,...
       gistruct.Values,...
       gistruct.Method,...
       gistruct.ExtrapolationMethod...
       );       
end
end

%--------------------------------------------------------------------------%
% LinearScanner.m                                                          %
% Copyright � 2018 Vidrio Technologies, LLC                                %
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
