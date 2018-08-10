function setSIFilePermissions()
    siPath = scanimage.util.siRootDir();

    %% set user permissions to full access
     fprintf('Setting user permissions for folder %s ...\n',siPath);
%     [~,currentUser] = system('whoami');
%     currentUser = regexprep(currentUser,'\n','');
%     cmd = ['icacls "' siPath '" /grant "' currentUser '":(OI)(CI)F /T'];

    cmd = ['icacls "' siPath '" /grant "Users":(OI)(CI)F /T'];
    [status,cmdout] = system(cmd);
    if status == 0
        statusLine = regexpi(cmdout,'^.*(Successfully|Failed).*$','lineanchors','dotexceptnewline','match','once');
        if isempty(statusLine)
            disp(cmdOut)
        else
            disp(statusLine)
        end
    else
        fprintf(2,'Setting user file permissions failed with error code %d\n',status);
    end

    %% remove file attributes 'hidden' and 'read-only'
    fprintf('Setting file attributes for folder %s ...\n',siPath);
    cmd = ['attrib -H -R /S "' fullfile(siPath,'*') '"'];
    [status,cmdout] = system(cmd);
    if status == 0
        if ~isempty(cmdout)
            disp(cmdout);
        end
    else
        fprintf(2,'Setting file attributes failed with error code %d\n',status);
    end
    
    fprintf('Done\n');
end

%--------------------------------------------------------------------------%
% setSIFilePermissions.m                                                   %
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
