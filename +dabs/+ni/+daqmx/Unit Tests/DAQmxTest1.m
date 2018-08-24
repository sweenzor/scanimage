import Devices.NI.DAQmx.*
global CBDATA

sampleRate = 50000;
everyNSamples = 50000;
acqTime = 5;

hTask = Task('a task');
try
    hChans = hTask.addAnalogInputChannels('Dev1',0:2);
    
    %%%Unfortunately, the following doesn't suffice to correctly configure the timing.
    %Basically, I can't figure out how to replicate the DAQmxCfgSampClkTiming macro
%     set(hTask,'sampClkSrc','ai/SampleClockTimebase');
%     set(hTask,'sampClkTimebaseDiv',round(get(hTask,'sampClkTimebaseRate')/sampleRate));
%     set(hTask,'sampClkRate',sampleRate);
%     set(hTask,'sampQuantSampMode','DAQmx_Val_FiniteSamps');    
%     set(hTask,'sampQuantSampPerChan',round(acqTime*sampleRate));
%     %hTask.control('DAQmx_Val_Task_Verify');
    
    %Use the DAQmx 'macro' to configure the timing properties en masse
    hTask.cfgSampClkTiming('',sampleRate,'','DAQmx_Val_FiniteSamps',round(sampleRate*acqTime));    
   
    %Set voltage range explicitly, ensuring same range for all product categories
    set(hTask.channels,'min',-10);
    set(hTask.channels,'max',10);
    
    status1 = hTask.registerEveryNSamplesCallback(everyNSamples,'test1Callback_1')
    %status2 = hTask.registerEveryNSamplesCallback(everyNSamples,'test1Callback_2')
    
    %Start the task
    %keyboard;
    CBDATA.task = hTask;
    CBDATA.everyNSamples = everyNSamples;
    CBDATA.count = 0;
    hTask.start();
    'Started task!'
           
    %Wait till completion
    while true
        tf =  hTask.isDone();
        if tf
            'Finished!'
            break;
        else
            'Still Acquiring'
            pause(1);
        end
    end
    
    %Clean up
    hTask.clear(); %Avoids deleting the System object
catch
    hTask.clear();
    rethrow(lasterror);
end






%--------------------------------------------------------------------------%
% DAQmxTest1.m                                                             %
% Copyright � 2018 Vidrio Technologies, LLC                                %
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
