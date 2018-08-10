
%Demo of using CTR Input as means of signalling that a trigger input 
%NOTE: It does not seem possible to have DO Task (hTrigger) signal Done Event on its own. 
%If AutoStart=True, then error -200985 results if a DAQmx event is registered. 
%On other hand, if AutoStart=False, Task does not complete until user specifies StopTask().

import Devices.NI.DAQmx.*

hSys = Devices.NI.DAQmx.System.getHandle();
delete(hSys.tasks);

deviceName = 'Dev1';
sampleRate = 1.25e6;

if ~exist('hDevice') || ~isvalid(hDevice)
    hDevice = Device(deviceName);
end

hTrigger = Task('Trigger Task');
hTrigger.createDOChan(deviceName,'line0');

hAI = Task('AI Task');
hAI.createAIVoltageChan(deviceName,0);
hAI.cfgSampClkTiming(sampleRate,'DAQmx_Val_ContSamps');
hAI.cfgDigEdgeStartTrig('PFI0');

hCtr = Task('Counter Task');
hCtr.createCOPulseChanFreq(deviceName,0,[],hDevice.get('COMaxTimebase')/4); %Not sure best way to directly query the Max CO Frequency
hCtr.cfgImplicitTiming('DAQmx_Val_FiniteSamps',2);
hCtr.cfgDigEdgeStartTrig('PFI0');
hCtr.registerDoneEvent('test10Callback');

while true    
    reply = input('Press any key to start or ''q'' to quit: ', 's');
    if strcmpi(reply,'q')
        break;
    else
        disp('Starting...');
        hAI.start(); 
        hCtr.start();
        hTrigger.writeDigitalData(logical([0;1;0]),inf,true);        
        pause(.1);
        hAI.stop();
        hCtr.stop();
    end       
end



%--------------------------------------------------------------------------%
% DAQmxTest10.m                                                            %
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
