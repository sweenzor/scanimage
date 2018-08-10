import dabs.ni.daqmx.*
import dabs.ni.daqmx.demos.*

ctrValues = [];

hEdge1 = PulseGenerator('Dev3',3); %PO.3 -- connected to PFI7
hEdge2 = PulseGenerator('Dev3',4); %P0.4 -- connected to PFI6


hCtr = Task('Two-edge Sep counter');
hCtr.createCITwoEdgeSepChan('Dev3',3); %Ctr3 uses PFI7/6 by default for two-edge separation measurements
hCtr.cfgImplicitTiming('DAQmx_Val_ContSamps');

hCtr.start();

edgeSepValues = [1:10 30];

for i=1:length(edgeSepValues);
    hEdge1.go();
    pause(edgeSepValues(i));
    hEdge2.go();
    ctrValues(end+1) = hCtr.readCounterDataScalar();
    fprintf(1,'Read edge-separation value: %g\n',ctrValues(end));
end

delete(hCtr);
delete(hEdge1);
delete(hEdge2);


%--------------------------------------------------------------------------%
% twoEdgeSepTest.m                                                         %
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
