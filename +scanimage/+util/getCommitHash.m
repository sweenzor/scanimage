function commitHash = getCommitHash()
    commitHash = '';
    
    try
        commithashPath = fullfile(scanimage.util.siRootDir(),'+scanimage','private','REF');
        
        if exist(commithashPath,'file')
            fid = fopen(commithashPath);
            try
                commitHash = fgetl(fid);
                fclose(fid);
            catch ME
                fclose(fid);
                rethrow(ME);
            end
        else
            commitHash = most.util.getGitCommitHash(scanimage.util.siRootDir());
        end
    catch
        % this function should never throw!
    end
end

%--------------------------------------------------------------------------%
% getCommitHash.m                                                          %
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
