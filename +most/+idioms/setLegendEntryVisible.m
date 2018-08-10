function setLegendEntryVisible(handles,status)
% array of graphics objects in a figure
% status = 'off' or 'on'
%
% Note: after calling this function, the legend must be updated to reflect
% the change
% 
% for more details, see matlab doc:
% http://www.mathworks.com/help/releases/R2012a/techdoc/creating_plots/braliom.html#bram7nu
if ~ischar(status)
    if status
        status = 'on';
    else
        status = 'off';
    end
end

for h = handles
    hAnnotation = get(h,'Annotation');
    hLegendEntry = get(hAnnotation','LegendInformation');
    set(hLegendEntry,'IconDisplayStyle',status);
end
end



%--------------------------------------------------------------------------%
% setLegendEntryVisible.m                                                  %
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
