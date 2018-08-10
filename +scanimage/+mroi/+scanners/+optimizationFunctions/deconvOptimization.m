function [done,nextOutputWaveform,optimizationData] = deconvOptimization(linearScanner,iterationNumber,sampleRateHz,desiredWaveform,outputWaveform,feedbackWaveform,optimizationData)
err = feedbackWaveform - desiredWaveform;

if numel(unique(desiredWaveform))==1
    % Handle Constant Output
    nextOutputWaveform = desiredWaveform - mean(err);
    done = true;
    return
end

H = fft(feedbackWaveform)./fft(outputWaveform);
H(abs(H)<0.05) = Inf; % avoid division by zero + primitive low pass filter
err_i = ifft(fft(err)./H);
err_i = err_i-mean(err_i);
nextOutputWaveform = outputWaveform - err_i - mean(err);
done = iterationNumber >= 6; 
end

%--------------------------------------------------------------------------%
% deconvOptimization.m                                                     %
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
