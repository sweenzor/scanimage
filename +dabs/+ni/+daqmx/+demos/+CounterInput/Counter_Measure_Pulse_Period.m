function Counter_Measure_Pulse_Period()
%% On Demand Pulse Period Measurement
% This examples demonstrates an on demand pulse period measurement
% using the dabs.ni.daqmx adapter

%% Parameters for the acquisition
devName = 'Dev1'; % the name of the DAQ device as shown in MAX

% Channel configuration
ctrID = 0;                   % a scalar identifying the counter
sampleInterval = 1;          % sample interval in seconds

units = 'DAQmx_Val_Seconds'; % one of {'DAQmx_Val_Seconds' 'DAQmx_Val_Ticks' 'DAQmx_Val_FromCustomScale'}

minPeriod = 0.000001;   % The minimum value, in units, that you expect to measure.
maxPeriod = 0.100000;   % The maximum value, in units, that you expect to measure.

polarityEdge = 'DAQmx_Val_Rising';     % one of {'DAQmx_Val_Rising', 'DAQmx_Val_Falling'}

periodTerm = 'PFI1';   % the terminal used for the input of the first pulse; refer to "Terminal Names" in the DAQmx help for valid values


%% Perform the acquisition

import dabs.ni.daqmx.* % import the NI DAQmx adapter
try
    % create and configure the task
    hTask = Task('Task');
    hChannel = hTask.createCIPeriodChan(devName,ctrID,[],polarityEdge,minPeriod,maxPeriod,units);
    
    % define the terminals for the two pulses to measure
    hChannel.set('periodTerm',periodTerm);
        
    hTask.start();
    
    % read and display the edge separation time
    for i = 0:10
       data = hTask.readCounterDataScalar(10);
       disp(['Edge Separation: ' num2str(data)]);
       pause(sampleInterval);  % the read interval is determined by software
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
end


%--------------------------------------------------------------------------%
% Counter_Measure_Pulse_Period.m                                           %
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
