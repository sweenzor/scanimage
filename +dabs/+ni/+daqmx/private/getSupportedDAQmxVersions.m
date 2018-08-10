function versions = getSupportedDAQmxVersions
switch computer('arch')
    case 'win32'
        archFolder = 'win32';
    case 'win64'
        archFolder = 'x64';
    otherwise
        error('NI DAQmx: Unknown computer architecture :%s',computer(arch));
end
    folders = dir('NIDAQmx_*');
    folders = {folders.name};
    
    versions = {};
    for i = 1:length(folders)
        folder = folders{i};
        supported = 0 < exist(fullfile(pwd,folder,archFolder,'NIDAQmx_proto.m'),'file') ...
                 || 0 < exist(fullfile(pwd,folder,archFolder,'NIDAQmx_proto.p'),'file');
        if strcmp(archFolder,'x64')
            supported = supported && 0 < exist(fullfile(pwd,folder,archFolder,'nicaiu_thunk_pcwin64.dll'),'file');
        end
        
        if supported
           versions{end+1} = strrep(strrep(folder,'NIDAQmx_',''),'_','.'); %#ok<AGROW>
        end
    end
end


%--------------------------------------------------------------------------%
% getSupportedDAQmxVersions.m                                              %
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
