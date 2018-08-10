classdef DelayedEventListener < handle    
    properties
        delay;
        enabled = true;
    end
    
    properties (Access = private)
       hDelayTimer;
       delayTimerRunning = false;
       lastDelayFunctionCall;
       functionHandle;
       hListener;
    end
    
    methods
        function obj = DelayedEventListener(delay,varargin)            
            obj.hDelayTimer = timer(...
                'TimerFcn',@obj.doNothing,...
                'StopFcn',@obj.timerCallback,...
                'BusyMode','drop',...
                'ExecutionMode','singleShot',...
                'StartDelay',1,... % overwritten later
                'ObjectVisibility','off');
            
            obj.delay = delay;
            
            if ischar(varargin{end}) && strcmpi(varargin{end},'weak')
                obj.hListener = most.idioms.addweaklistener(varargin{1:end-1});
            else
                obj.hListener = addlistener(varargin{:});
            end
            obj.functionHandle = obj.hListener.Callback;
            obj.hListener.Callback = @(varargin)obj.delayFunction(varargin);
            
            listenerSourceNames = strjoin(cellfun(@(src)class(src),obj.hListener.Source,'UniformOutput',false));
            set(obj.hDelayTimer,'Name',sprintf('Delayed Event Listener Timer %s:%s',listenerSourceNames,obj.hListener.EventName));
        end
        
        function delete(obj)
            obj.hDelayTimer.StopFcn = []; % stop will be called when deleting the timer. Avoid the stop function
            most.idioms.safeDeleteObj(obj.hListener);
            most.idioms.safeDeleteObj(obj.hDelayTimer);
        end
    end
    
    methods
        function delayFunction(obj,varargin)
            if obj.enabled
                % restart timer
                obj.lastDelayFunctionCall = tic();
                if ~obj.delayTimerRunning
                    obj.hDelayTimer.StartDelay = obj.delay;
                    obj.delayTimerRunning = true;
                    start(obj.hDelayTimer);
                end 
            end
        end
        
        function doNothing(obj,varargin)
        end
        
        function timerCallback(obj,varargin)
            dt = toc(obj.lastDelayFunctionCall);
            newDelay = obj.delay-dt;
            
            if newDelay > 0
                % rearm timer
                newDelay = (ceil(newDelay*1000)) / 1000; % timer delay is limited to 1ms precision
                obj.hDelayTimer.StartDelay = newDelay;
                start(obj.hDelayTimer);
            else
                % execute delayed callback
                obj.delayTimerRunning = false;
                obj.executeFunctionHandle(varargin);
            end
        end
        
        function executeFunctionHandle(obj,varargin)
            obj.functionHandle(varargin);
        end
    end
    
    methods
        function set.delay(obj,val)
            validateattributes(val,{'numeric'},{'scalar','positive','nonnan','finite'});
            val = (ceil(val*1000)) / 1000; % timer delay is limited to 1ms precision
            obj.delay = val;
        end
    end
end


%--------------------------------------------------------------------------%
% DelayedEventListener.m                                                   %
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
