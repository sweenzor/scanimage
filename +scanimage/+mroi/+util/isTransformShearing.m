function tf = isTransformShearing(A,v1,v2)
if nargin < 2 || isempty(v1)
    v1 = [0,1];
end

if nargin < 3 || isempty(v2)
    v2 = [1,0];
end

assert(dot(v1,v2) == 0);

v1t = scanimage.mroi.util.xformPoints(v1,A);
v2t = scanimage.mroi.util.xformPoints(v2,A);
origint = scanimage.mroi.util.xformPoints([0,0],A);

dotprod = dot(v1t-origint,v2t-origint);
tf = abs(dotprod) > eps; % ~= 0 with tolerance
end


%--------------------------------------------------------------------------%
% isTransformShearing.m                                                    %
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
