import dabs.ni.daqmx.*

ctrValues = [];

hNext = nextTrigInit();

hCtr = Task('Period counter');
hCtr.createCIPeriodChan('Dev3',0);
hCtr.cfgImplicitTiming('DAQmx_Val_ContSamps');


hCtr.start();
hNext.go(); %first pulse


periodValues = [1:10 30];

for i=1:length(periodValues);
    pause(periodValues(i));
    hNext.go();
    ctrValues(end+1) = hCtr.readCounterDataScalar();
    fprintf(1,'Read period value: %g\n',ctrValues(end));
end

delete(hCtr);
delete(hNext);


%--------------------------------------------------------------------------%
% periodCounterTest.m                                                      %
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
