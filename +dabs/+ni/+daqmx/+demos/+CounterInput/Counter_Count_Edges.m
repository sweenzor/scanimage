function Counter_Count_Edges()
%% Software Timed Edge Counter
% This examples demonstrates a software timed counter acquisition
% using the dabs.ni.daqmx adapter

%% Parameters for the acquisition
devName = 'Dev1'; % the name of the DAQ device as shown in MAX

% Channel configuration
ctrID = 0;                   % a scalar or an array with the channel numbers
countDirection = 'DAQmx_Val_CountUp';    % one of {'DAQmx_Val_CountUp', 'DAQmx_Val_CountDown', 'DAQmx_Val_ExtControlled'}
sampleInterval = 1;                      % sample interval in seconds
edge = 'DAQmx_Val_Rising';               % one of {'DAQmx_Val_Rising', 'DAQmx_Val_Falling'}
initialCount = 0;

% Arm start trigger configuration
armStartTrigType = 'DAQmx_Val_None';  % one of {'DAQmx_Val_DigEdge', 'DAQmx_Val_None'}
digEdgeArmStartTrigSrc = 'PFI1';         % the terminal used for the digital arm trigger; refer to "Terminal Names" in the DAQmx help for valid values
digEdgeArmStartTrigEdge = 'DAQmx_Val_Rising'; %one of {'DAQmx_Val_Rising', 'DAQmx_Val_Falling'}

% Pause trigger configuration
pauseTrigType = 'DAQmx_Val_DigLvl';     % one of {'DAQmx_Val_None', 'DAQmx_Val_DigLvl'}; for more options refer to "List of Trigger Properties" in the DAQmx help
digLvlPauseTrigSrc = 'PFI1';            % the terminal used for the digital arm trigger; refer to "Terminal Names" in the DAQmx help for valid values
digLvlPauseTrigWhen = 'DAQmx_Val_High'; % one of {'DAQmx_Val_Low', 'DAQmx_Val_High'}


%% Perform the acquisition

import dabs.ni.daqmx.* % import the NI DAQmx adapter
try
    % create and configure the task
    hTask = Task('Task');
    hTask.createCICountEdgesChan(devName,ctrID,[],countDirection,edge,initialCount);
    
    % optional: configure arm start trigger
    hTask.set('armStartTrigType', armStartTrigType);
    hTask.set('digEdgeArmStartTrigSrc', digEdgeArmStartTrigSrc);
    hTask.set('digEdgeArmStartTrigEdge', digEdgeArmStartTrigEdge);
    
    % optional: configure pause trigger
    hTask.set('pauseTrigType', pauseTrigType);
    hTask.set('digLvlPauseTrigSrc', digLvlPauseTrigSrc);
    hTask.set('digLvlPauseTrigWhen', digLvlPauseTrigWhen);
    
    hTask.start();
    
    % read and display the counter value
    for i = 0:10
       data = hTask.readCounterDataScalar(10);
       disp(['Counter Value: ' num2str(data)]);
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


%--------------------------------------------------------------------------%
% Counter_Count_Edges.m                                                    %
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
