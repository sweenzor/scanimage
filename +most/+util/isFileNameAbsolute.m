function retval=isFileNameAbsolute(fileName)

% If you do x=fileparts(x) until you reach steady-state,
% the steady-state x will be empty if and only if the initial x is relative.
% If absolute, the steady-state x will be "/" on Unix-like OSes, and 
% something like "C:\" on Windows.
%
% Note that this will return true for the empty string.  This may be
% convoversial.  But, you know: garbage in, garbage out.

path=fileName;
parent=fileparts(path);
while ~strcmp(path,parent)
  path=parent;
  parent=fileparts(path);
end
% at this point path==parent
retval=~isempty(path);

end


%--------------------------------------------------------------------------%
% isFileNameAbsolute.m                                                     %
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
