classdef GenericServoController < handle 
    properties (SetObservable)
        minAngle = 0;
        maxAngle = 1.75*360;
        minPulseDuration = 1.5e-3;
        maxPulseDuration = 1.9e-3;
        pulseRepeatPeriod = 20e-3;
        
        angle = 0;
        outputTerminal = 'PFI13';
    end
    
    properties (SetAccess = private,SetObservable)
        started = false;
    end
    
    properties (Hidden)
        hTask;
    end
    
    %% Lifecycle
    methods
        function obj = GenericServoController(devName,ctrChannel)
            try
                name = sprintf('ServoController-%s-Ctr%d',devName,ctrChannel);
                obj.hTask = most.util.safeCreateTask(name);
                lowTime = 1;  % preliminary, changed later
                highTime = 1; % preliminary, changed later
                obj.hTask.createCOPulseChanTime(devName,ctrChannel,'Servo PWM channel',lowTime,highTime);
                obj.hTask.cfgImplicitTiming('DAQmx_Val_ContSamps');
            catch ME
                obj.delete();
                rethrow(ME);
            end
        end
        
        function delete(obj)
            most.idioms.safeDeleteObj(obj.hTask);
        end
    end
    
    %% Class methods
    methods
        function start(obj)
            if ~obj.started
                obj.stop();
                obj.configure(true);
                obj.hTask.start();
                obj.started = true;
            end
        end
        
        function abort(obj)
            obj.stop();
        end
        
        function stop(obj)
            obj.hTask.abort();
            obj.started = false;
        end
    end
    
    methods (Hidden)
        function [lowTime,highTime] = angleToPulseTime(obj,angle)
            assert(obj.minPulseDuration < obj.maxPulseDuration);
            assert(obj.minAngle <= angle <= obj.maxAngle);
            
            highTime = obj.minPulseDuration + (obj.maxPulseDuration-obj.minPulseDuration)/(obj.maxAngle-obj.minAngle) * (angle-obj.minAngle);
            lowTime = obj.pulseRepeatPeriod - highTime;
            
            assert(highTime > 0); %Sanity check
        end
    end
    
    %% Property Getter/Setter
    methods
        function set.angle(obj,val)
            obj.angle = val;
            
            if obj.started
                [lowTime,highTime] = obj.angleToPulseTime(obj.angle);
                obj.hTask.writeCounterTimeScalar(highTime,lowTime,1);
            end
        end
        
        function set.outputTerminal(obj,val)
            obj.outputTerminal = val;
            obj.configure();
        end
        
        function set.maxAngle(obj,val)
            obj.maxAngle = val;
            obj.angle = obj.angle;
        end
        
        function set.minAngle(obj,val)
            obj.minAngle = val;
            obj.angle = obj.angle;
        end
        
        function set.maxPulseDuration(obj,val)
            obj.maxPulseDuration = val;
            obj.angle = obj.angle;
        end
        
        function set.minPulseDuration(obj,val)
            obj.minPulseDuration = val;
            obj.angle = obj.angle;
        end
        
        function configure(obj,force)
            if nargin < 2 || isempty(force)
                force = false;
            end
            
            if ~obj.started && ~force
                return
            end
            
            wasStarted = obj.started;
            obj.stop();
            
            [lowTime,highTime] = obj.angleToPulseTime(obj.angle);
            obj.hTask.channels(1).set('pulseHighTime',highTime);
            obj.hTask.channels(1).set('pulseLowTime',lowTime);
            obj.hTask.channels(1).set('pulseTerm',obj.outputTerminal);
            
            if wasStarted
                obj.start();
            end
        end
    end
end

%--------------------------------------------------------------------------%
% GenericServoController.m                                                 %
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
