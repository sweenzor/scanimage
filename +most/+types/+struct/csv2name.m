
function name = csv2name(varargin)
%CSV2NAME Convert comma seperated string values into dot-separated structure name

assert(iscellstr(varargin));

if nargin == 1
    name = varargin{1};
    return;
end

name = '';
for i=1:(nargin-1)
    name = [name varargin{i} '.'];
end

name = [name varargin{end}];

end



%--------------------------------------------------------------------------%
% csv2name.m                                                               %
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
