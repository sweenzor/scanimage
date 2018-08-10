function ctr = centroidQuadrilateral(pt1,pt2,pt3,pt4)

if nargin < 2
    pt2 = pt1(2,:);
    pt3 = pt1(3,:);
    pt4 = pt1(4,:);
    pt1 = pt1(1,:);
end

validateattributes(pt1,{'numeric'},{'size',[1,2]});
validateattributes(pt2,{'numeric'},{'size',[1,2]});
validateattributes(pt3,{'numeric'},{'size',[1,2]});
validateattributes(pt4,{'numeric'},{'size',[1,2]});

ctr1 = centroidTriangle(pt1,pt2,pt3);
ctr2 = centroidTriangle(pt1,pt3,pt4);
ctr3 = centroidTriangle(pt1,pt2,pt4);
ctr4 = centroidTriangle(pt2,pt3,pt4);

ctr = scanimage.mroi.util.intersectLines(ctr1,ctr2-ctr1,ctr3,ctr4-ctr3);
end

function ctr = centroidTriangle(pt1,pt2,pt3)
pt1_2 = pt1 + (pt2-pt1)./2;
pt2_3 = pt2 + (pt3-pt2)./2;

v1 = pt3-pt1_2;
v2 = pt1-pt2_3;

ctr = scanimage.mroi.util.intersectLines(pt1_2,v1,pt2_3,v2);
end

%--------------------------------------------------------------------------%
% centroidQuadrilateral.m                                                  %
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
