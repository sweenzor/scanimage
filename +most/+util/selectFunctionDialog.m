function fh = selectFunctionDialog(varargin)
fh = [];
[fileName,pathName] = uigetfile({'*.m','*.p'},varargin{:});
if isnumeric(fileName) && fileName == 0
    return % user cancelled
end

packageName = regexp(pathName,'(?<=\\\+).*$','match','once');
packageName = regexprep(packageName,'\\\+','.');
packageName = regexprep(packageName,'\\','');

fileName = regexprep(fileName,'(\.m|\.p)$','');

if isempty(packageName)
    functionName = fileName;
else
    functionName = strjoin({packageName,fileName},'.');
end

fh = str2func(functionName);
end

%--------------------------------------------------------------------------%
% selectFunctionDialog.m                                                   %
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
