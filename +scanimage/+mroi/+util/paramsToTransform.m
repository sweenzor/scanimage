function T = paramsToTransform(offsetX,offsetY,scaleX,scaleY,rotation,shear)
toOrig = eye(3);
fromOrig = eye(3);

S = eye(3);
S([1,5]) = [scaleX,scaleY];

rot = -rotation * pi / 180;
R = [cos(rot) sin(rot) 0;...
    -sin(rot) cos(rot) 0;...
     0        0        1];

SH = eye(3);
SH(4) = shear;

O = eye(3);
O([7,8]) = [offsetX,offsetY];

T = O * fromOrig * R * S * SH * toOrig;
end

%--------------------------------------------------------------------------%
% paramsToTransform.m                                                      %
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
