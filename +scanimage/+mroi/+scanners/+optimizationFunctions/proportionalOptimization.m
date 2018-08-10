function [done,nextOutputWaveform,optimizationData] = proportionalOptimization(linearScanner,iterationNumber,sampleRateHz,desiredWaveform,outputWaveform,feedbackWaveform,optimizationData)

if iterationNumber == 1
    optimizationData = struct();
    
    delay = findDelay(feedbackWaveform,desiredWaveform);
    if isempty(delay)
        delay = 0; % no correlation found. probably because waveform is constant
    end
    
    optimizationData.delay = delay;
    nextOutputWaveform = circshift(outputWaveform,-optimizationData.delay);
else
    err = feedbackWaveform - desiredWaveform;
    err_shift = circshift(err,-optimizationData.delay);

    K = 0.5;
    nextOutputWaveform = outputWaveform - K * err_shift;
end

done = iterationNumber >= 5;
end

function delay = findDelay(waveform1,waveform2)
% calculate waveform autocorrelation
    assert(numel(waveform1)==numel(waveform2));
    len = numel(waveform1);
    r = ifft( fft(waveform1) .* conj(fft(waveform2)) );
    r = [r(end-len+2:end) ; r(1:len)];
    
    peakLoc = scanimage.util.peakFinder(r);
    peakLoc(r(peakLoc)<0.99*max(r(peakLoc))) = []; % filter out peaks to compensate for rounding errors
    delay = min(peakLoc);
end

%--------------------------------------------------------------------------%
% proportionalOptimization.m                                               %
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
