function structpv = cellPV2structPV(cellpv)

if iscell(cellpv) && isempty(cellpv)
    structpv = struct();
    return;
end
   
assert(iscell(cellpv) && isvector(cellpv) && ~rem(numel(cellpv),2),'Invalid PV cell array');


flds = cellpv(1:2:end);
vals = cellpv(2:2:end);

assert(iscellstr(flds),'Invalid PV cell array');

structpv = struct();
for i=1:length(flds)
    structpv.(flds{i}) = vals{i};
end

end


%--------------------------------------------------------------------------%
% cellPV2structPV.m                                                        %
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
