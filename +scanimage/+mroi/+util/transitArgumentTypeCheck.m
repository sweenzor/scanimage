function tf = transitArgumentTypeCheck(scanfield_from,scanfield_to)
from = isa(scanfield_from,'scanimage.mroi.scanfield.ScanField') || isnan(scanfield_from);
to   = isa(scanfield_to,'scanimage.mroi.scanfield.ScanField')   || isnan(scanfield_to);
bothempty = isempty(scanfield_from) && isempty(scanfield_to);
%bothnan = isnan(scanfield_from) && isnan(scanfield_to); %both nan is currently allowed
tf = from && to && ~bothempty; %&& ~bothnan;
end


%--------------------------------------------------------------------------%
% transitArgumentTypeCheck.m                                               %
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
