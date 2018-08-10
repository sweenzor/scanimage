function BartDemo()

%%%%EDIT IF NEEDED%%%%
devName = 'PXI1Slot3';
aiChans = 0:2;
sampRate = 1000;
everyNSamples = 2000;
acqTime=10; %seconds
%%%%%%%%%%%%%%%%%%%%%%

import dabs.ni.daqmx.*

hTask = Task('Bart Task1');
hTask.createAIVoltageChan(devName,aiChans);

hTask.cfgSampClkTiming(sampRate,'DAQmx_Val_ContSamps');

hTask.registerEveryNSamplesEvent(@BartCallback,everyNSamples);

hTimer = timer('StartDelay',acqTime,'TimerFcn',@timerFcn);

hTask.start();
start(hTimer);

    function BartCallback(~,~)
        persistent hFig
        
        if isempty(hFig)
            hFig = figure;
        end       
        
        d = hTask.readAnalogData(everyNSamples);
        figure(hFig);
        plot(d);
        drawnow expose;                
    end

    function timerFcn(~,~)
        hTask.stop();
        delete(hTask); 
        delete(hTimer);
        disp('All done!');
    end
end




%--------------------------------------------------------------------------%
% BartDemo.m                                                               %
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
