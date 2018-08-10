function mask = computeresscanmask(scanFreq, sampleRate, fillFractionSpatial, pixelsPerLine)
%COMPUTERESSCANMASK Computes the line mask for resonant scanning
%   The mask indicates the number of samples acquired per pixel in a line
%   based on the given parameters    

    assert(fillFractionSpatial>0 && fillFractionSpatial<1,'fillFractionSpatial needs to be smaller than 1');

    pixelBoundaries = linspace(-fillFractionSpatial,fillFractionSpatial,pixelsPerLine+1)';
    pixelBoundariesTime = asin(pixelBoundaries) / (2*pi*scanFreq);
    pixelBoundariesSamples = pixelBoundariesTime * sampleRate;
    pixelBoundariesSamples = round(pixelBoundariesSamples); % quantize
    mask = diff(pixelBoundariesSamples);

%     assert(all(mask>0),'Mask contains zero values, which will result in incorrect FPGA behavior');
end


%--------------------------------------------------------------------------%
% computeresscanmask.m                                                     %
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
