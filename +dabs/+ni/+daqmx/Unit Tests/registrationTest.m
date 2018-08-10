function hTask = registrationTest(AIDevice,AIChans)
%REGISTRATIONTEST Test of register/unregister functionality with DAQmx package

import Devices.NI.DAQmx.*

taskName = 'Registration Test Task';
taskMap = Task.getTaskMap();
if taskMap.isKey(taskName)
    delete(taskMap(taskName));
end
hTask = Task(taskName);


sampRate = 10e3;
numChunks = 4;
numIterations = 30;
chunkTime = 0.2; %Time in seconds

hTask.createAIVoltageChan(AIDevice,AIChans);
hTask.cfgSampClkTiming(sampRate,'DAQmx_Val_FiniteSamps',numChunks*round(sampRate*chunkTime));
hTask.registerDoneEvent(@nextIterationFcn);

iterationCounter = 0;
chunkCounter = 0;
nextIterationFcn();

return;

    function iterationReportFcn(~,~)
        chunkCounter = chunkCounter + 1;
        fprintf(1,'Received Chunk # %d of Iteration # %d\n',chunkCounter,iterationCounter);               
    end

    function nextIterationFcn(~,~)

        hTask.stop();
        if iterationCounter
            fprintf(1,'Completed Iteration # %d\n',iterationCounter);
        end       
                        
        if ~mod(iterationCounter,2)
            hTask.registerEveryNSamplesEvent(@iterationReportFcn,round(sampRate*chunkTime));
        else
            hTask.registerEveryNSamplesEvent();
        end
        
        chunkCounter = 0;
        
        if iterationCounter < numIterations
            iterationCounter = iterationCounter + 1;        
            hTask.start();
        end
        
    end

end



%--------------------------------------------------------------------------%
% registrationTest.m                                                       %
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
