function yCenterInRange(roigroup,scannerset,sf)
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
        ySorted = sort(scannerset.fovCornerPoints(:,2));
        ssTop = mean(ySorted(1:2));
        ssBot = mean(ySorted(3:4));
        
        if isa(sc, 'scanimage.mroi.scanfield.fields.StimulusField') && sc.isPoint
            hsz = 0;
        else
            hsz = sc.sizeXY(2)/2;
        end
        
        top = sc.centerXY(2)-hsz;
        bot = sc.centerXY(2)+hsz;
        
        if min([top bot]) < ssTop
            sc.centerXY(2) = ssTop + hsz;
        elseif max([top bot]) > ssBot
            sc.centerXY(2) = ssBot - hsz;
        end
    end
end


%--------------------------------------------------------------------------%
% yCenterInRange.m                                                         %
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
