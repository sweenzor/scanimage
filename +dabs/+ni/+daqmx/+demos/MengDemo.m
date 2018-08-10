%Demo of digital output non-buffered operation

numShutters = 3;
shutterDevice = 'dev1';

hShutter = dabs.ni.daqmx.Task.empty();
for i=1:numShutters
    hShutter(i) = dabs.ni.daqmx.Task(sprintf('Shutter %d Control',i));
    hShutter(i).createDOChan(shutterDevice,sprintf('line%d',i-1));
end

%Turn on shutter 1, turn off others
hShutter(1).writeDigitalData(1);
hShutter(2:3).writeDigitalData(0);

%Turn on shutter 2, turn off others
pause(5);
hShutter(2).writeDigitalData(1);
hShutter([1 3]).writeDigitalData(0);

%Turn on shutter 3, turn off others
pause(5);
hShutter(3).writeDigitalData(1);
hShutter(1:2).writeDigitalData(0);








    



%--------------------------------------------------------------------------%
% MengDemo.m                                                               %
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
