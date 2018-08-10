function DaqmxAsyncWriteDemo
    global hTask;
    global taskReadyForNewWrite;
    taskReadyForNewWrite = true;
    hTask = dabs.ni.daqmx.Task();
    hTask.createAOVoltageChan('Dev1',0);
    hTask.cfgSampClkTiming(1000,'DAQmx_Val_ContSamps');
    hTask.writeAnalogData(rand(10000,1),[],[],[]);
    hTask.start();
    
    hTimer = timer();
    hTimer.TimerFcn = @writeNewData;
    hTimer.Period = 0.5;
    hTimer.ExecutionMode = 'fixedSpacing';
    
    start(hTimer);
    assignin('base','hTimer',hTimer);
    assignin('base','hTask',hTask);
end

function writeNewData(src,evt)
    global taskReadyForNewWrite
    global hTask
    if taskReadyForNewWrite
       taskReadyForNewWrite = false;
       start = tic;
       hTask.writeAnalogDataAsync(rand(5000,1),[],[],[],@callback);
       fprintf('Timer is sending new data: (took %fs)\n',toc(start));
    end
end


function callback(src,evt)
    global taskReadyForNewWrite
    sampsWritten = evt.sampsWritten;
    status = evt.status;
    errorString = evt.errorString;
    extendedErrorInfo = evt.extendedErrorInfo;
    
    fprintf('Task %d refreshed %d samples\n',src.taskID,sampsWritten);
    if status
        fprintf(2,'writeAnalogData encountered an error: %d\n%s\n=============================\n%s\n',status,errorString,extendedErrorInfo);
    else
        taskReadyForNewWrite = true;
    end
end

%--------------------------------------------------------------------------%
% DaqmxAsyncWriteDemo.m                                                    %
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
