function out = laplacianFilter(image)
    kernelSize = 9;
    sigma = 4;
    
    lin = round(linspace(-floor(kernelSize/2),floor(kernelSize/2),kernelSize));
    [X,Y] = meshgrid(lin,lin);
    hg = exp(-(X.^2 + Y.^2)/(2*(sigma^2)));
    kernel_t = hg.*(X.^2 + Y.^2-2*sigma^2)/(sigma^4*sum(hg(:)));
    % make the filter sum to zero
    kernel = kernel_t - sum(kernel_t(:))/kernelSize^2;
    
%     I = im2double(image);
%     out = conv2(I, kernel);
    out = kernel;

end


%--------------------------------------------------------------------------%
% laplacianFilter.m                                                        %
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
