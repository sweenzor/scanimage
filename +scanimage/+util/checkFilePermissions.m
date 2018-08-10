function checkFilePermissions()
    siPath = scanimage.util.siRootDir();
    fileName = fullfile(siPath,[most.util.generateUUID '.si']);
    
    if ~makeTestFile(fileName)
        button = questdlg(sprintf('ScanImage does not have write permissions in its installation folder.\nDo you want to fix the file permissions automatically?'));
        switch lower(button)
            case 'yes'
                scanimage.util.setSIFilePermissions();
                if ~makeTestFile(fileName);
                    msgbox('ScanImage could not set the folder permissions automatically.','Warning','warn');
                end
            otherwise
                msgbox('Without write access in the installation folder ScnaImage might not function correctly.','Warning','warn');
                return
        end
    end
end

function success = makeTestFile(fileName)
    success = false;
    try
        hFile = fopen(fileName,'w+');
        if hFile < 0
            return
        end
        fprintf(hFile,'my test string');
        fclose(hFile);
        success = true;
    catch
        success = false;
    end
    
    if exist(fileName,'file');
        delete(fileName);
    end
end

%--------------------------------------------------------------------------%
% checkFilePermissions.m                                                   %
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
