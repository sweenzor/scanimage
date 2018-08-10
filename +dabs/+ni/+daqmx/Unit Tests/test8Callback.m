function test8Callback()
%   Function called at end of each iteration

global callbackStruct8


%Increment iteration counter
callbackStruct8.iterationCounter = callbackStruct8.iterationCounter + 1; %Incremented count reflects the iteration that's about to run

%Prepare the data for the next iteration, and start the tasks
if callbackStruct8.iterationCounter <= callbackStruct8.numIterations
    
    %Read & plot AI data
    [numSamps,inputData] = callbackStruct8.hAI(1).readAnalogData(callbackStruct8.numSamples, callbackStruct8.numSamples, 'scaled',1);
    
    set(callbackStruct8.hlines(1),'YData',inputData(:,1));
    set(callbackStruct8.hlines(2),'YData',inputData(:,2));
    drawnow expose;    
    
    %Stop the tasks -- this is needed so they can be restarted
    callbackStruct8.hCtr(1).stop()
    callbackStruct8.hAI(1).stop();
    callbackStruct8.hAO(1).stop();
    callbackStruct8.hDO(1).stop()
    pause(.5);
end

%Prepare the data for the next iteration, and start the tasks
if callbackStruct8.iterationCounter < callbackStruct8.numIterations       
    
    %Start the tasks so they can await trigger. Note these methods are vectorized.
    callbackStruct8.hAI(1).start();
    callbackStruct8.hAO(1).start();
    callbackStruct8.hDO(1).start();
    callbackStruct8.hCtr(1).start();
end

end





%--------------------------------------------------------------------------%
% test8Callback.m                                                          %
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
