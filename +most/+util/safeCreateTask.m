function hTask = safeCreateTask(taskname, hDaqSys)
    
    if nargin < 2
        hDaqSys = dabs.ni.daqmx.System;
    end
    
    if most.util.checkForTask(taskname, true, hDaqSys)
        warning OFF BACKTRACE
        warning('Task ''%s'' already exists. Scanimage may not have shut down properly last time.\n  Scanimage will attempt to delete the old task and continue.', taskname);
        warning ON BACKTRACE
    end
    
    hTask = dabs.ni.daqmx.Task(taskname);
    
end



%--------------------------------------------------------------------------%
% safeCreateTask.m                                                         %
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
