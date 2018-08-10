classdef EventGenerator < handle
    %EVENTGENERATOR Overrides notify to enable passing of arbitrary event
    %data.
    %
    %Note: Subclasses with events with non-public NotifyAccess should not
    %derive from EventGenerator.
    
    properties
        hEventData;
    end
            
    %% PUBLIC METHODS
    
    methods
        
        function obj = EventGenerator
            obj.hEventData = most.GenericEventData;            
        end
        
    end
    
    methods
        
        % Listeners receive a most.GenericEventData object, with the
        % specified eventData in the UserData field.
        function notify(obj,eventName,eventData)
            edata = obj.hEventData;
            if nargin < 3
                edata.UserData = [];
            else
                edata.UserData = eventData;
            end
            notify@handle(obj,eventName,edata);
        end
    end
    
end



%--------------------------------------------------------------------------%
% EventGenerator.m                                                         %
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
