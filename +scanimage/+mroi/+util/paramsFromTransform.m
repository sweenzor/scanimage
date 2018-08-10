function [offsetX,offsetY,scaleX,scaleY,rotation,shear] = paramsFromTransform(T,tolerance)
if scanimage.mroi.util.isTransformPerspective(T)
%     offsetX = NaN;
%     offsetY = NaN;
%     scaleX = NaN;
%     scaleY = NaN;
%     rotation = NaN;
%     shear = NaN;
%     return
    
    T([3,6]) = 0; % ignoring perspective entries for the moment. TODO: find better solution
end

if nargin < 2 || isempty(tolerance)
    tolerance = 1e-10;
end

ctr = scanimage.mroi.util.xformPoints([0 0],T);
offsetX = applyTolerance(ctr(1));
offsetY = applyTolerance(ctr(2));

toOrigin = eye(3);
toOrigin([7,8]) = [-ctr(1),-ctr(2)];

T = toOrigin * T;

[ux,~] = getUnitVectors(T);
rot = atan2(ux(2),ux(1));
rotation = applyTolerance(rot * 180 / pi);

toUnRotated = [cos(rot) sin(rot) 0; ...
              -sin(rot) cos(rot) 0; ...
               0         0         1];

T = toUnRotated * T;

[ux,uy] = getUnitVectors(T);
scaleX = applyTolerance(norm(ux));
scaleY = applyTolerance(dot(uy,[0,1]));

toUnScaled = eye(3);
toUnScaled([1,5]) = [1/scaleX,1/scaleY];
T = toUnScaled * T;

[~,uy] = getUnitVectors(T);
shear = applyTolerance(uy(1));

function [ux,uy] = getUnitVectors(T)
% returns transformed unit vectors
X = [1,0];
Y = [0,1];
O = [0,0];
pts = scanimage.mroi.util.xformPoints([X;Y;O],T);
X = pts(1,:);
Y = pts(2,:);
O = pts(3,:);
ux = X-O;
uy = Y-O;
end

function x = applyTolerance(x)
    if abs(x) < tolerance
        x = 0;
    end
end
end

%--------------------------------------------------------------------------%
% paramsFromTransform.m                                                    %
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
