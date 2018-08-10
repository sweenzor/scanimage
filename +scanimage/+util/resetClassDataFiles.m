function resetClassDataFiles(dataDir)
if nargin < 1
    dataDir = [];
end

if evalin('base','exist(''hSI'',''var'')')
    hSI = evalin('base','hSI');
    assert(isempty(hSI) || ~isvalid(hSI),'Cannot reset class data files while ScanImage is running');
end

fprintf('Deleting class data files in ScanImage path...\n');
p = fileparts(fileparts(fileparts(mfilename('fullpath'))));
most.util.removeFileTypes(p,'*_classData.mat');
fprintf('Done!\n');

if ~isempty(dataDir)
    assert(exist(dataDir,'dir') == 7,'Directory ''%s'' does not exist',dataDir);
    fprintf('Deleting class data files in data dir path...\n');
    most.util.removeFileTypes(dataDir,'*_classData.mat');
    fprintf('Done!\n');
end

fprintf('Resetting class data files completed successfully\n');
end

%--------------------------------------------------------------------------%
% resetClassDataFiles.m                                                    %
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
