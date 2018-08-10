function loadnisyscfg()
    if libisloaded('nisyscfg');return;end
    
    if strcmp(computer('arch'),'win32')
        % for some reason this function crashes Matlab on Windows 32 bit
        error('generateNIMaxReport currently unsupported on Windows 32 bit');
    end
    
    binarypath = fullfile(fileparts(mfilename('fullpath')),computer('arch'));
    
    oldpath = pwd();
    cd(binarypath);
    
    s = warning();
    warning off MATLAB:loadlibrary:TypeNotFound
    warning off MATLAB:loadlibrary:TypeNotFoundForStructure
    try
        [notfound,warnings] = loadlibrary('nisyscfg', @nisyscfg_proto);
    catch ME
        warning(s);
        cd(oldpath);
        rethrow(ME);
    end
    warning(s);
    cd(oldpath);
end


%--------------------------------------------------------------------------%
% loadnisyscfg.m                                                           %
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
