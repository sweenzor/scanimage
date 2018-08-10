function Voltage_Continuous_Input_RegisterCallback()
%% Continuous Voltage Input
% This examples demonstrates a continuous buffered acquisition using the dabs.ni.daqmx adapter

%% Parameters for the acquisition
devName = 'PXI1Slot3'; % the name of the DAQ device as shown in MAX

% Channel configuration
physicalChannels = 0:5; % a scalar or an array with the channel numbers
minVoltage = -10;       % channel input range minimum
maxVoltage = 10;        % channel input range maximum

% Task configuration
sampleClockSource = 'OnboardClock'; % the terminal used for the sample Clock; refer to "Terminal Names" in the DAQmx help for valid values
sampleRate = 1000;                  % sample Rate in Hz
acquisitionTime = 10;               % acquisition time in seconds
everyNSamples = 1000;               % call the callback funcation after N number of samples are acquired

% Trigger configuration
triggerType = 'DigEdgeStartTrig'; % one of {'DigEdgeStartTrig', 'AnlgEdgeStartTrig', 'None'}

% Parameters for digital triggering
dTriggerSource = 'PFI1';           % the terminal used for the digital trigger; refer to "Terminal Names" in the DAQmx help for valid values
dTriggerEdge = 'DAQmx_Val_Rising'; % one of {'DAQmx_Val_Rising', 'DAQmx_Val_Falling'}

% Parameters for analog triggering
aTriggerSource = 'AI1';                  % channel to be monitored for the analog trigger
aTriggerLevel = 5;                       % analog trigger level
aTriggerSlope = 'DAQmx_Val_RisingSlope'; % one of {'DAQmx_Val_RisingSlope', 'DAQmx_Val_FallingSlope'}



import dabs.ni.daqmx.* % import the NI DAQmx adapter

try
    % create and configure the task
    hTask = Task('Task'); 
    hTask.createAIVoltageChan(devName,physicalChannels,[],minVoltage,maxVoltage);
    hTask.cfgSampClkTiming(sampleRate,'DAQmx_Val_ContSamps',[],sampleClockSource);
    
    switch triggerType
        case 'DigEdgeStartTrig'
            hTask.cfgDigEdgeStartTrig(dTriggerSource,dTriggerEdge);
        case 'AnlgEdgeStartTrig'
            hTask.cfgAnlgEdgeStartTrig(aTriggerSource,aTriggerLevel,aTriggerSlope);
        case 'None'
            % do not configure trigger, start acquisition immediately
    end

    % register the callback function
    hTask.registerEveryNSamplesEvent(@callbackFunction,everyNSamples,1,'Scaled');
    
    hTask.start();
    
    % let the acquisition run for acquisitionTime
    pause(acquisitionTime);
    
    % stop and clean up task 
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

end

function callbackFunction(src,evt)
     hTask = src;
     data = evt.data;
     errorMessage = evt.errorMessage;
     
     persistent hFig;
     if isempty(hFig)
         hFig = figure;
     end
     
     % check for errors
     if ~isempty(errorMessage)
         delete(hTask);
         error(errorMessage);
     else
         figure(hFig);
         plot(data);
     end
end


%--------------------------------------------------------------------------%
% Voltage_Continuous_Input_RegisterCallback.m                              %
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
