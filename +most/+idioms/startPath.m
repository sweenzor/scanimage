function startPath = startPath()
%STARTPATH Gives path simply of drive on which Matlab is installed
%   This can be useful as input to uiputfile,uigetfile,uigetdir, rather than using the Matlab current directory

mlroot = matlabroot();
startPath = mlroot(1:3); %e.g. c:\

end



%--------------------------------------------------------------------------%
% startPath.m                                                              %
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
