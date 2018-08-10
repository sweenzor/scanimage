classdef LinearScanner < handle
    
    properties
        waveformCacheBasePath = '';
        
        bandwidth = 1000;
        optimizationFcn = @scanimage.mroi.scanners.optimizationFunctions.deconvOptimization;
    end
    
    properties
        hDevice;
        deviceSelfInit = false;
        sampleRateHz = 500e3;
    end
    
    properties (Dependent)
        optimizationAvailable;
        waveformCacheScannerPath;
        
        % the following are all passed to/from hDevice. here for convenience
        name;
        simulated;
        calibrationData;
        travelRange;
        voltsPerDistance;
        distanceVoltsOffset;
        parkPosition;
        parkPositionVolts;
        positionAvailable;
        feedbackAvailable;
        offsetAvailable;
        feedbackCalibrated;
        offsetCalibrated;
        positionDeviceName;
        positionChannelID;
        feedbackDeviceName;
        feedbackChannelID;
        feedbackTermCfg;
        offsetDeviceName;
        offsetChannelID;
        feedbackVoltInterpolant;
        offsetVoltScaling;
        feedbackVoltFcn = [];
        position2VoltFcn = [];
        volt2PositionFcn = [];
    end
    
    %% Lifecycle
    methods
        function obj = LinearScanner(hDevice)
            if nargin < 1
                obj.hDevice = dabs.interfaces.LinearScanner();
                obj.deviceSelfInit = true;
            else
                assert(isa(hDevice,'dabs.interfaces.LinearScanner'));
                obj.hDevice = hDevice;
            end
        end
        
        function delete(obj)
            if obj.deviceSelfInit
                most.idioms.safeDeleteObj(obj.hDevice);
            end
        end
    end
    
    %% Setter / Getter methods
    methods
        
        function val = get.optimizationAvailable(obj)
            val = ~isempty(obj.impulseResponse) && ~isempty(obj.impulseResponseSampleRate);
        end
        
        function val = get.waveformCacheScannerPath(obj)
            if isempty(obj.waveformCacheBasePath) || isempty(obj.hDevice.name)
                val = [];
            else
                val = fullfile(obj.waveformCacheBasePath, obj.hDevice.name);
            end
        end
        
        function val = get.calibrationData(obj)
            val = obj.hDevice.calibrationData;
        end
        
        function set.calibrationData(obj,val)
            obj.hDevice.calibrationData = val;
        end
    end
    
    % Pass through
    methods
        function v = get.name(obj)
            v = obj.hDevice.name;
        end
        
        function v = get.simulated(obj)
            v = obj.hDevice.simulated;
        end
        
        function v = get.travelRange(obj)
            v = obj.hDevice.travelRange;
        end
        
        function v = get.voltsPerDistance(obj)
            v = obj.hDevice.voltsPerDistance;
        end
        
        function v = get.distanceVoltsOffset(obj)
            v = obj.hDevice.distanceVoltsOffset;
        end
        
        function v = get.parkPosition(obj)
            v = obj.hDevice.parkPosition;
        end
        
        function v = get.parkPositionVolts(obj)
            v = obj.hDevice.parkPositionVolts;
        end
        
        function v = get.positionAvailable(obj)
            v = obj.hDevice.positionAvailable;
        end
        
        function v = get.feedbackAvailable(obj)
            v = obj.hDevice.feedbackAvailable;
        end
        
        function v = get.offsetAvailable(obj)
            v = obj.hDevice.offsetAvailable;
        end
        
        function v = get.feedbackCalibrated(obj)
            v = obj.hDevice.feedbackCalibrated;
        end
        
        function v = get.offsetCalibrated(obj)
            v = obj.hDevice.offsetCalibrated;
        end
        
        function v = get.positionDeviceName(obj)
            v = obj.hDevice.positionDeviceName;
        end
        
        function v = get.positionChannelID(obj)
            v = obj.hDevice.positionChannelID;
        end
        
        function v = get.feedbackDeviceName(obj)
            v = obj.hDevice.feedbackDeviceName;
        end
        
        function v = get.feedbackChannelID(obj)
            v = obj.hDevice.feedbackChannelID;
        end
        
        function v = get.feedbackTermCfg(obj)
            v = obj.hDevice.feedbackTermCfg;
        end
        
        function v = get.offsetDeviceName(obj)
            v = obj.hDevice.offsetDeviceName;
        end
        
        function v = get.offsetChannelID(obj)
            v = obj.hDevice.offsetChannelID;
        end
        
        function v = get.feedbackVoltInterpolant(obj)
            v = obj.hDevice.feedbackVoltInterpolant;
        end
        
        function v = get.offsetVoltScaling(obj)
            v = obj.hDevice.offsetVoltScaling;
        end
        
        function v = get.feedbackVoltFcn(obj)
            v = obj.hDevice.feedbackVoltFcn;
        end
        
        function v = get.position2VoltFcn(obj)
            v = obj.hDevice.position2VoltFcn;
        end
        
        function v = get.volt2PositionFcn(obj)
            v = obj.hDevice.volt2PositionFcn;
        end
        
        function set.name(obj,v)
            obj.hDevice.name = v;
        end
        
        function set.simulated(obj,v)
            obj.hDevice.simulated = v;
        end
        
        function set.travelRange(obj,v)
            obj.hDevice.travelRange = v;
        end
        
        function set.voltsPerDistance(obj,v)
            obj.hDevice.voltsPerDistance = v;
        end
        
        function set.distanceVoltsOffset(obj,v)
            obj.hDevice.distanceVoltsOffset = v;
        end
        
        function set.parkPosition(obj,v)
            obj.hDevice.parkPosition = v;
        end
        
        function set.positionAvailable(obj,v)
            obj.hDevice.positionAvailable = v;
        end
        
        function set.feedbackAvailable(obj,v)
            obj.hDevice.feedbackAvailable = v;
        end
        
        function set.offsetAvailable(obj,v)
            obj.hDevice.offsetAvailable = v;
        end
        
        function set.feedbackCalibrated(obj,v)
            obj.hDevice.feedbackCalibrated = v;
        end
        
        function set.offsetCalibrated(obj,v)
            obj.hDevice.offsetCalibrated = v;
        end
        
        function set.positionDeviceName(obj,v)
            obj.hDevice.positionDeviceName = v;
        end
        
        function set.positionChannelID(obj,v)
            obj.hDevice.positionChannelID = v;
        end
        
        function set.feedbackDeviceName(obj,v)
            obj.hDevice.feedbackDeviceName = v;
        end
        
        function set.feedbackChannelID(obj,v)
            obj.hDevice.feedbackChannelID = v;
        end
        
        function set.feedbackTermCfg(obj,v)
            obj.hDevice.feedbackTermCfg = v;
        end
        
        function set.offsetDeviceName(obj,v)
            obj.hDevice.offsetDeviceName = v;
        end
        
        function set.offsetChannelID(obj,v)
            obj.hDevice.offsetChannelID = v;
        end
        
        function set.feedbackVoltInterpolant(obj,v)
            obj.hDevice.feedbackVoltInterpolant = v;
        end
        
        function set.offsetVoltScaling(obj,v)
            obj.hDevice.offsetVoltScaling = v;
        end
        
        function set.feedbackVoltFcn(obj,v)
            obj.hDevice.feedbackVoltFcn = v;
        end
        
        function set.position2VoltFcn(obj,v)
            obj.hDevice.position2VoltFcn = v;
        end
        
        function set.volt2PositionFcn(obj,v)
            obj.hDevice.volt2PositionFcn = v;
        end
    end
    
    %% Public methods
    methods
    end
    
    % pass thru
    methods
        function varargout = feedbackVolts2Position(obj,varargin)
            [varargout{1:nargout}] = obj.hDevice.feedbackVolts2Position(varargin{:});
        end
        
        function v = position2Volts(obj,v)
            v = obj.hDevice.position2Volts(v);
        end
        
        function v = volts2Position(obj,v)
            v = obj.hDevice.volts2Position(v);
        end
    end
end

function hash = computeWaveformHash(sampleRateHz,originalWaveform)
    originalWaveform = round(originalWaveform * 1e6); % round to a precision of 1uV to eliminate rounding errors
    hash = most.util.dataHash({originalWaveform,sampleRateHz});
end


%--------------------------------------------------------------------------%
% LinearScanner.m                                                          %
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
