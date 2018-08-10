function absPos = getAbsolutePixelPositionInFigure(hObj)
assert(isgraphics(hObj),'Input to function getAbsolutePixelPositionInFigure needs to be a valid graphics object');

pos = zeros(0,4);

while ~isa(hObj,'matlab.ui.Figure')
    pos(end+1,:) = getPixelPosition(hObj); %#ok<AGROW>
    hObj = hObj.Parent;
end

absPos = [sum(pos(:,1:2),1),pos(1,3:4)];

    function pos_ = getPixelPosition(hObj_)
        units_ = hObj_.Units;
        hObj_.Units = 'pixel';
        pos_ = hObj_.Position;
        hObj_.Units = units_;
    end
end

%--------------------------------------------------------------------------%
% getAbsolutePixelPositionInFigure.m                                       %
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
