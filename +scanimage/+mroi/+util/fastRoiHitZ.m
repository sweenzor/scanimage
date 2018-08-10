function mask = fastRoiHitZ(rois,z)
    % returns tf array indicating if each roi is involved in the imaging of plane z
    mask = false(1,length(rois));
    if numel(rois)
        rois_discretePlanes_ = {rois.discretePlaneMode};
        rois_zs_ = {rois.zs};
        for i = 1:length(rois)
            if(isempty(rois_zs_{i})),   mask(i) = false; continue; end
            if rois_discretePlanes_{i}, mask(i) = any(rois_zs_{i} == z); continue; end
            if(length(rois_zs_{i})==1), mask(i) = true;  continue; end
            mask(i) = min(rois_zs_{i}(:))<=z && z<=max(rois_zs_{i}(:));
        end
    end
end



%--------------------------------------------------------------------------%
% fastRoiHitZ.m                                                            %
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
