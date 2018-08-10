function coeff = getAITaskScalingCoefficients(hTask)
% Outputs a 4xN array with scalingcoefficients for each of the N Tasks
% such that f(X) = coeff(1,N)*X^0 + coeff(2,N)*X^1 + coeff(3,N)*X^2 + coeff(4,N)*X^3

% More information:
% Is NI-DAQmx Read Raw Data Calibrated and/or Scaled in LabVIEW?
% http://digital.ni.com/public.nsf/allkb/0FAD8D1DC10142FB482570DE00334AFB?OpenDocument

assert(isa(hTask.channels,'dabs.ni.daqmx.AIChan'),'hTask does not contain AI channels');
channelNames = arrayfun(@(ch)ch.chanName,hTask.channels,'UniformOutput',false);

numCoeff = 4;

coeff = zeros(numCoeff,numel(channelNames));
for idx = 1:length(channelNames)
    chName = channelNames{idx};
    a = zeros(numCoeff,1);
    ptr = libpointer('voidPtr',a);
    hTask.apiCallRaw('DAQmxGetAIDevScalingCoeff',hTask.taskID,chName,ptr,numCoeff);
    coeff(:,idx) = ptr.Value;
    ptr.delete();
end

end

%--------------------------------------------------------------------------%
% getAITaskScalingCoefficients.m                                           %
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
