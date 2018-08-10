function setPixelLocation(hObj,newLocation)
%SETPIXELLOCATION Set new location of HG object in pixel units, without resizing it
%
%   hObj: A handle-graphics object with 'position' property
%   newLocation: 1x2 array specifying new [left bottom] values for 'position', in pixel units

validateattributes(newLocation,{'numeric'},{'size' [1 2]});
assert(ishandle(hObj),'Supplied hObj is not a valid HG handle');

setpixelposition(hObj,getpixelposition(hObj) .* [0 0 1 1] + [newLocation 0 0]);


end



%--------------------------------------------------------------------------%
% setPixelLocation.m                                                       %
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
