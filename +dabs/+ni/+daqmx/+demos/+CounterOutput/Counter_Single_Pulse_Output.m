function Counter_Single_Pulse_Output()
%% Continuous Voltage Input
% This examples demonstrates a continuous buffered acquisition using the dabs.ni.daqmx adapter

%% Parameters for the acquisition
devName = 'Dev1'; % the name of the DAQ device as shown in MAX

% Channel configuration
ctrID = 0; % scalar identifying the counter

% Trigger configuration
triggerType = 'DigEdgeStartTrig'; % one of {'DigEdgeStartTrig', 'None'}

dTriggerSource = 'PFI1';           % the terminal used for the digital trigger; refer to "Terminal Names" in the DAQmx help for valid values
dTriggerEdge = 'DAQmx_Val_Rising'; % one of {'DAQmx_Val_Rising', 'DAQmx_Val_Falling'}

import dabs.ni.daqmx.* % import the NI DAQmx adapter

try
    % create and configure the task
    hTask = Task('Task'); 
    hTask.createAIVoltageChan(devName,physicalChannels,[],minVoltage,maxVoltage);
    hTask.cfgSampClkTiming(sampleRate,'DAQmx_Val_ContSamps',[],sampleClockSource);
    
    switch triggerType
        case 'DigEdgeStartTrig'
            hTask.cfgDigEdgeStartTrig(dTriggerSource,dTriggerEdge);
            hTask.set('SetStartTrigRetriggerable',1);
        case 'None'
            % do not configure trigger, start generation immediately
    end

    
    hTask.start();

    % read and display the acquired data
    hFig = figure;
    for i=0:10
       data = hTask.readAnalogData(numberOfSamplesToRead,'scaled',5);
       figure(hFig);
       plot(data);
       drawnow;
    end
    
    % clean up task 
    hTask.stop();
    delete(hTask);
    clear hTask;
    
    disp('Acquisition Finished');
    
catch err % clean up task if error occurs
    if exist('hTask','var')
        delete(hTask);
        clear hTask;
    end
    rethrow(err);
end


%--------------------------------------------------------------------------%
% Counter_Single_Pulse_Output.m                                            %
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
