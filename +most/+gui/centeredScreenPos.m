function pos = centeredScreenPos(sz,units)
%CENTEREDSCREENPOS calculates a position (x y width height) for a screen
%centered figure with the desired width and height.
    if nargin < 2
        units = 'pixels';
    end

    u = get(0,'units');
    set(0,'units',units);
    scrsz = get(0,'ScreenSize');
    set(0,'units',u);
    pos = [(scrsz(3)-sz(1))/2 (scrsz(4)-sz(2))/2 sz(1) sz(2)];
end



%--------------------------------------------------------------------------%
% centeredScreenPos.m                                                      %
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
