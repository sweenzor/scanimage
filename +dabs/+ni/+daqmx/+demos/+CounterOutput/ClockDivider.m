function hTask = ClockDivider()
deviceName = 'PXI1Slot3';
ctrNumber = 3;
clockSource = '/PXI1Slot3/PXI_CLK10';
outputTerminal = 'PFI14';
clkDivisor = 4;

assert(mod(clkDivisor,1)==0 && clkDivisor>=4,'Divisor must be an integer >= 4'); % lowTicks and highTicks must be >= 2

lowTicks = ceil(clkDivisor/2);
highTicks = floor(clkDivisor/2);

hTask = most.util.safeCreateTask('Clock Divider');
hTask.createCOPulseChanTicks(deviceName, ctrNumber, '', clockSource, lowTicks, highTicks);
hTask.channels(1).set('pulseTerm',outputTerminal);
hTask.channels(1).set('pulseTicksInitialDelay',2); % minimum of 2
hTask.cfgImplicitTiming('DAQmx_Val_ContSamps');

hTask.start();
end

%--------------------------------------------------------------------------%
% ClockDivider.m                                                           %
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
