function tf = mouseOnObj(hObj,mousePtPx)

if nargin<2 || isempty(mousePtPx)
    hFig = ancestor(hObj,'figure');
    units_ = hFig.Units;
    hFig.Units = 'pixel';
    mousePtPx = hFig.CurrentPoint(1,1:2);
    hFig.Units = units_;
end

absPixPos = most.util.getAbsolutePixelPositionInFigure(hObj);

tf = mousePtPx(1)>absPixPos(1) && mousePtPx(2)>absPixPos(2) && ...
     mousePtPx(1)<(absPixPos(1)+absPixPos(3)) && mousePtPx(2)<(absPixPos(2)+absPixPos(4));
end

%--------------------------------------------------------------------------%
% mouseOnObj.m                                                             %
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
