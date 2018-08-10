function maxWidth(roigroup,scannerset,sf)
    if isempty(sf)
        for roi=roigroup.rois
            for s=roi.scanfields
                constr(s);
            end
        end
    else
        constr(sf);
    end

    function constr(sc)
        if isa(scannerset, 'scanimage.mroi.scannerset.ResonantGalvoGalvo') && ~scannerset.resonantLimitedFovMode
            resW = scannerset.scanners{1}.fullAngleDegrees * scannerset.fillFractionSpatial;
            if (sc.sizeXY(1) - resW) > 0.00000001;
                sc.sizeXY(1) = resW;
            end
        else
            mW = scannerset.fillFractionSpatial * scannerset.angularRange(1);
            if sc.sizeXY(1) > (1.00000001 * mW)
                sc.sizeXY(1) = mW;
            end
        end
    end
end


%--------------------------------------------------------------------------%
% maxWidth.m                                                               %
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
