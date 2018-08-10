function X = intersectLines(pt1,v1,pt2,v2)
assert(length(pt1)==2);
assert(length(v1)==2);
assert(length(pt2)==2);
assert(length(v2)==2);
% line 1: pt1, v1
% line 2: pt2, v2

pt11 = pt1 + v1;
pt22 = pt2 + v2;

n1 = [pt11(2)-pt1(2),pt1(1)-pt11(1)];
n2 = [pt22(2)-pt2(2),pt2(1)-pt22(1)];

r1 = dot(n1,[pt1(1),pt1(2)]);
r2 = dot(n2,[pt2(1),pt2(2)]);

r = [r1;r2];
l = [n1;n2];

X = mldivide(l,r)';
end

%--------------------------------------------------------------------------%
% intersectLines.m                                                         %
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
