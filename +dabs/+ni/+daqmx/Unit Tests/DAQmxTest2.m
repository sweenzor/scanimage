%Test demonstrating ability to bind independent callbacks to independent Tasks

import Devices.NI.DAQmx.*
global CBDATA

sampleRate = 50000;
everyNSamples = 50000;
acqTime = 5;
task2Multiplier = 10;

hTasks = Task('a task');
hTasks2 = Task('anotherTask');
try
    %hChans = hTask.addAnalogInputChannels('Dev1',0:2);    
    hChans = hTasks.createAIVoltageChan('Dev1',0:2);
    hChans2 = hTasks2.createAIVoltageChan('Dev3',0:1);
    
    %%%Unforutnately, the following doesn't suffice to correctly configure the timing.
    %Basically, I can't figure out how to replicate the DAQmxCfgSampClkTiming macro
%     set(hTask,'sampClkSrc','ai/SampleClockTimebase');
%     set(hTask,'sampClkTimebaseDiv',round(get(hTask,'sampClkTimebaseRate')/sampleRate));
%     set(hTask,'sampClkRate',sampleRate);
%     set(hTask,'sampQuantSampMode','DAQmx_Val_FiniteSamps');    
%     set(hTask,'sampQuantSampPerChan',round(acqTime*sampleRate));
%     %hTask.control('DAQmx_Val_Task_Verify');
    
    %Use the DAQmx 'macro' to configure the timing properties en masse
    hTasks.cfgSampClkTiming(sampleRate,'DAQmx_Val_FiniteSamps',round(sampleRate*acqTime)); 
    hTasks2.cfgSampClkTiming(sampleRate*task2Multiplier,'DAQmx_Val_FiniteSamps',round(sampleRate*acqTime*task2Multiplier));
   
    %Set voltage range explicitly, ensuring same range for all product categories
    set(hTasks.channels,'min',-10);set(hTasks.channels,'max',10);
    set(hTasks2.channels,'min',-10);set(hTasks2.channels,'max',10);    
    
    hTasks.registerEveryNSamplesCallback('test2Callback_1',everyNSamples)
    hTasks2.registerEveryNSamplesCallback('test2Callback_1',everyNSamples*task2Multiplier)
    
    %Start the task
    CBDATA.task = [hTasks hTasks2];
    CBDATA.everyNSamples = [everyNSamples everyNSamples*task2Multiplier];
    CBDATA.count = 0;
    hTasks.start();
    hTasks2.start();
    'Started tasks!'
    
    %Wait till completion
    while true
        tf =  and(hTasks.isDone(),hTasks2.isDone());
        if tf
            'Finished!'
            break;
        else
            'Still Acquiring'
            pause(1);
        end
    end
    
    %Clean up
    hTasks.clear(); %Avoids deleting the System object
    hTasks2.clear(); %Avoids deleting the System object
catch ME
    hTasks.clear();
    hTasks2.clear(); 
    ME.rethrow();
end






%--------------------------------------------------------------------------%
% DAQmxTest2.m                                                             %
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
