function data = expInterpolateCircularNaNRanges(data,expCnst)
nanRanges = scanimage.mroi.util.findNaNRanges(data);
if isempty(nanRanges);return;end % Nothing to interpolate

if isnan(data(1)) && isnan(data(end))
    shifted = nanRanges(end,2)-nanRanges(end,1)+1;
    data = circshift(data,shifted);
    nanRanges = scanimage.mroi.util.findNaNRanges(data);
else
    shifted = 0;
end

for i = 1:size(nanRanges,1)
    istrt = nanRanges(i,1);
    iend = nanRanges(i,2);
    
    if istrt == 1
        ystrt = data(end);
    else
        ystrt = data(istrt-1);
    end
    
    if iend == numel(data)
        yend = data(1);
    else
        yend = data(iend+1);
    end
    
    if ystrt == yend
        data(istrt:iend) = ystrt;
    else
        npts = iend-istrt+1;
        if isinf(expCnst)
            data(istrt:iend) = linspace(ystrt,yend,npts);
        else
            dz = expCnst*log(yend/ystrt);
            zs = linspace(dz/npts,dz*(1-1/npts),npts);
            data(istrt:iend) = ystrt * exp(zs/expCnst);
        end
    end
end


if shifted ~= 0
    data = circshift(data,-shifted); % shift data back
end
end


%--------------------------------------------------------------------------%
% expInterpolateCircularNaNRanges.m                                        %
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
