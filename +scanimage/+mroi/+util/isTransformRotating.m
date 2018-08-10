function tf = isTransformRotating(A,v,tolerance)
if nargin < 2 || isempty(v)
    v = [1,0];
end

if nargin < 3 || isempty(tolerance)
    tolerance = eps;
end


origint = scanimage.mroi.util.xformPoints([0,0],A);
vt = scanimage.mroi.util.xformPoints(v,A) - origint;

tf = ~all( (v/norm(v) - vt/norm(vt)) <= tolerance);
end


%--------------------------------------------------------------------------%
% isTransformRotating.m                                                    %
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
