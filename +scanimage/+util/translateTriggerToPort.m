function [digitalLineStr, portNumber, lineNumber] = translateTriggerToPort(triggerLine)
    if ischar(triggerLine)
        assert(~isempty(regexpi(triggerLine,'^PFI[0-9]{1,2}$')),'triggerLine must be in the format ''PFI#''');
        [startIndex,endIndex] = regexp(triggerLine,'[0-9]+$');
        triggerLine = triggerLine(startIndex:endIndex);
        triggerNumber = str2double(triggerLine);
    else
        triggerNumber = triggerLine;
    end

    lineNumber = mod(triggerNumber,8);
    portNumber = floor(triggerNumber/8) + 1;
    digitalLineStr = sprintf('port%d/line%d',portNumber,lineNumber);
end


%--------------------------------------------------------------------------%
% translateTriggerToPort.m                                                 %
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
