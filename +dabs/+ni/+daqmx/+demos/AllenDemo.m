function [hTask,hAOTask] = AllenDemo()

%%%%EDIT IF NEEDED%%%%
AIDevice = 'PXI1Slot3';
AIChans = 0:1; %Must be 2 channels
AODevice = 'PXI1Slot3';
AOChan = 0; %Must be 1 channel

sampleRate = 2e6; %Hz
updatePeriod = 1; %s
acqPeriod = 5;
%%%%%%%%%%%%%%%%%%%%%%

import dabs.ni.daqmx.*

updatePeriodSamples = round(updatePeriod * sampleRate);

taskNames = {'AllenAI' 'AllenAO'};
taskMap = Task.getTaskMap();
for i=1:length(taskNames)    
   if taskMap.isKey(taskNames{i})
       delete(taskMap(taskNames{i}));
   end
end    
    
hTask = Task('AllenAI');
hAOTask = Task('AllenAO');

hTask.createAIVoltageChan(AIDevice,AIChans,[],-10,10);
hAOTask.createAOVoltageChan(AODevice,AOChan);
hTask.registerDoneEvent(@AllenDoneCallback);

numUpdates = round(round(sampleRate*acqPeriod)/updatePeriodSamples);
acqNumSamples = numUpdates * updatePeriodSamples;
hTask.cfgSampClkTiming(sampleRate,'DAQmx_Val_FiniteSamps', acqNumSamples);

hTask.registerEveryNSamplesEvent(@AllenCallback,updatePeriodSamples,false,'native');

% hTask.everyNSamples = updatePeriodSamples;
% hTask.everyNSamplesEventCallbacks = @AllenCallback;
% 
% hTask.everyNSamplesReadDataEnable = false;
% hTask.everyNSamplesReadDataTypeOption = 'native';


tic;
hAOTask.start();
hTask.start();

    function AllenCallback(src,evnt)        
        
        persistent hFig
        
        if isempty(hFig)
            hFig = figure();
        end
        
        if src.everyNSamplesReadDataEnable
            displayDataInfo(evnt.data);
        
            if isempty(evnt.errorMessage)
                figure(hFig);
                plot(evnt.data);
            end
        else
            %tic;
            inData = readAnalogData(src,src.everyNSamples,'native');   
            %toc;

            displayDataInfo(inData);
            
            figure(hFig);
            plot(inData);      
        end
        
        function displayDataInfo(dataSrc)
            fprintf(1,'Read Data Info -- size: %s\tmean: %.5g\tmax: %g\tmin: %g\tclass: %s\n',mat2str(size(dataSrc)),...
                mean(dataSrc(:)), max(dataSrc(:)), min(dataSrc(:)),class(dataSrc));
        end
    end

    function AllenDoneCallback(src,evnt)
       disp('Acquisition Done!');      
      
       delete([hTask hAOTask]);        
    end
        

end




%--------------------------------------------------------------------------%
% AllenDemo.m                                                              %
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
