function moved = moveOntoScreen(hGui)
%MOVEONTOSCREEN move entire gui/figure onto screen so that no parts of
%  the window is outside the monitor boundaries
%
%   hGui: A handle-graphics figure object handle
%
% NOTES
%  only supports moving guis onto primary monitor
%  Todo: implement support for multiple monitors for Matlab 2014b or later using get(0,'MonitorPositions')

oldUnits = get(0,'Units');
set(0,'Units','pixels');
screenSizePx = get(0,'ScreenSize');
set(0,'Units',oldUnits);

oldUnits = get(hGui,'Units');
set(hGui,'Units','pixels');
guiPositionPxOld = get(hGui,'OuterPosition');

guiPositionPxNew = guiPositionPxOld;

%check horizontal position
if guiPositionPxNew(1) < 1
    guiPositionPxNew(1) = 1;
elseif sum(guiPositionPxNew([1,3])) > screenSizePx(3)
    guiPositionPxNew(1) = screenSizePx(3) - guiPositionPxNew(3) + 1;
end

%check vertical position
if sum(guiPositionPxNew([2,4])) > screenSizePx(4)
    guiPositionPxNew(2) = screenSizePx(4) - guiPositionPxNew(4) + 1;
elseif guiPositionPxNew(2) < 1
    guiPositionPxNew(2) = 1;
end

% move the gui
if isequal(guiPositionPxOld,guiPositionPxNew)
    moved = false;
else
    set(hGui,'OuterPosition',guiPositionPxNew);
    moved = true;
end

set(hGui,'Units',oldUnits);
end


%--------------------------------------------------------------------------%
% moveOntoScreen.m                                                         %
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
