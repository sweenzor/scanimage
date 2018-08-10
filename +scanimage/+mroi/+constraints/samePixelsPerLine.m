function samePixelsPerLine(roigroup,~,scanfield)
if ~isa(scanfield,'scanimage.mroi.scanfield.ImagingField');
    return
end
if nargin < 2 || isempty(scanfield)
    pixelsPerLine = [];
else
    if isprop(scanfield,'pixelResolution')
        pixelsPerLine=scanfield.pixelResolutionXY(1);
    else
        pixelsPerLine = [];
    end
end

for roi=roigroup.rois
    for s=roi.scanfields
        if isprop(s,'pixelResolution')
            if isempty(pixelsPerLine)
                pixelsPerLine = s.pixelResolutionXY(1);
            elseif s.pixelResolutionXY(1)~=pixelsPerLine
                s.pixelResolutionXY(1)=pixelsPerLine;
            end
        end
    end
end

end


%--------------------------------------------------------------------------%
% samePixelsPerLine.m                                                      %
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
