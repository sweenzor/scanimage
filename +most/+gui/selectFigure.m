function h = selectFigure(figHandles)
%Allows user a few seconds to select a valid ScanImage image figure to interact with

%Create dummy figure/axes to divert gcf/gca
hf = figure('Visible','off');
axes('Parent',hf);

selTimer = timer('Name','selectFigure','TimerFcn',@nstTimerFcn,'StartDelay',5);
start(selTimer);

aborted = false;
while ~aborted      
	drawnow
    currFig = get(0,'CurrentFigure');
    [tf,loc] = ismember(currFig,figHandles);
    if tf
%         hAx = get(currFig,'CurrentAxes');
%         if loc <= state.init.maximumNumberOfInputChannels
%             chan = loc;
%         end
%         hIm = findobj(hAx,'Type','image'); %VI051310A
        h = currFig;
        break;
    end     
    pause(0.2);
end

if aborted
    h = [];
end

%Clean up
delete(hf);
stop(selTimer);
delete(selTimer);

    function nstTimerFcn(~,~)
        disp('aborting');
        aborted = true;        
    end            

end


%--------------------------------------------------------------------------%
% selectFigure.m                                                           %
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
