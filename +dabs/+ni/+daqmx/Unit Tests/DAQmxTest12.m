
import Devices.NI.DAQmx.*

deviceName = 'Dev1';
sampleRate = 10000;
duration = 8;







if exist('hAI','var') && isvalid(hAI);
    delete(hAI);
end

hAI = Task('An AI Task');
hAI.createAIVoltageChan(deviceName,[0:1]);
hAI.cfgSampClkTiming(10000,'DAQmx_Val_FiniteSamps',50000);
hAI.everyNSamples = 10000;
hAI.everyNSamplesEvtCallbacks = 'test12Callback';

hAI.start();

while ~hAI.isTaskDone()
    pause(1);
end

hAI.stop();




%--------------------------------------------------------------------------%
% DAQmxTest12.m                                                            %
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
