function test1Callback_1()
global CBDATA

'yo'
CBDATA.count = CBDATA.count + 1;


idx = 1;
%%%Put this section in, if using 2 tasks...need this for demo purposes, until we implement passing the task handle as an argument to callback
if ~mod(CBDATA.count,2)
    idx = 2;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
task = CBDATA.task(idx);
everyNSamples = CBDATA.everyNSamples(idx);

disp(['Visit #' num2str(CBDATA.count) ' to callback']);

[sampsRead, outputData] = readAnalogData(task, everyNSamples, everyNSamples, 'native', 2);
disp(['Read ' num2str(sampsRead) ' samples into a ' num2str(size(outputData,1)) ' X ' num2str(size(outputData,2)) ' matrix of CLASS ''' class(outputData) '''']);
% sampsRead = readAnalogData(CBDATA.task, CBDATA.everyNSamples, CBDATA.everyNSamples, 'scaled', 2);
% disp(['Read ' num2str(sampsRead) ' samples']);

assignin('base','outputData',outputData);




end



%--------------------------------------------------------------------------%
% test2Callback_1.m                                                        %
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
