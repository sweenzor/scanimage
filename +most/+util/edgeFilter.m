function edge = edgeFilter(img, tf)
    gFilt = most.util.gaussianFilter();
    
    if nargin < 2 || isempty(tf)
       tf = false; 
    end
    
    if tf
        im = single(gpuArray(img));
    else
        im = single((img));
    end
    
    gFilteredImage = conv2(gFilt, im);
    gFilteredImage = gFilteredImage(5:end-4, 5:end-4);
    edge = im-gFilteredImage;
end

%--------------------------------------------------------------------------%
% edgeFilter.m                                                             %
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
