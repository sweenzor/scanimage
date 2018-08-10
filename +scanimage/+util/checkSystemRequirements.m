function checkSystemRequirements()
    %64bit Matlab and Windows is required
    assert(strcmp(computer('arch'),'win64'),'Error: ScanImage only supports Matlab 64bit on Windows. This computer architecture is %s.',computer('arch'));
    
    %minimum required SI version is Matlab 2015a
    assert(~verLessThan('matlab','8.5.0'),'Error: ScanImage only supports Matlab 2015a or later. This Matlab version is %s.',regexprep(getfield(ver('matlab'),'Release'),'[\(\)]',''));
    
    %check for multiple scanimage versions on path
    list = what('scanimage');
    mask = cellfun(@(m)any(strcmpi(m,'SI.m')),{list.m});
    numSI = sum(mask);
    
    if numSI > 1
        msgbox('Multiple ScanImage installations were found on the path.','Error','error');
        folders = strjoin({list(mask).path},'\n\t');
        error('Multiple ScanImage installations were found on the path:\n\t%s\nRemove the redundant instances from the path and restart Matlab.',folders);
    end
end



%--------------------------------------------------------------------------%
% checkSystemRequirements.m                                                %
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
