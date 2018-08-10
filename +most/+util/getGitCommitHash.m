function [commitHash,branch] = getGitCommitHash(gitRepoPath)
    validateattributes(gitRepoPath,{'char'},{'row'});
    
    assert(logical(exist(gitRepoPath,'dir')),'Invalid gitRepoPath: %s',gitRepoPath);
    gitFolder = fullfile(gitRepoPath,'.git');
    assert(logical(exist(gitFolder,'dir')),'.git folder was not found');

    headFilePath = fullfile(gitFolder,'HEAD');
    assert(logical(exist(headFilePath,'file')),'.git/HEAD file was not found');
    
    fid = fopen(headFilePath);
    try
        line = fgetl(fid);
        fclose(fid);
    catch ME
        fclose(fid);
        rethrow(ME);
    end
    
    [~,tokens] = regexpi(line,'^ref:\s*refs/heads/(.*)$','match','tokens');
    assert(~isempty(tokens) && ~isempty(tokens{1}),'.git/HEAD does not contain the reference to the commit hash file.');
    
    branch = tokens{1}{1};
    commitFilePath = fullfile(gitFolder,'refs','heads',tokens{1}{1});
    assert(logical(exist(commitFilePath,'file')),'Commit file was not found');
    
    fid = fopen(commitFilePath);
    try
        commitHash = fgetl(fid);
        fclose(fid);
    catch ME
        fclose(fid);
        rethrow(ME);
    end
end

%--------------------------------------------------------------------------%
% getGitCommitHash.m                                                       %
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
