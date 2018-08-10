function processedHex = RevAndParseHex(hex)
        for i = 1:2:length(hex)-1
            positionHexReversed(length(hex)-i) = hex(i);
            positionHexReversed(length(hex)-i+1) = hex(i+1);
        end
        k = 1;
        for i = 1:2:length(positionHexReversed)-1
            parseHex{k} = positionHexReversed(i:i+1);
            k = k+1;
        end
        processedHex = parseHex;
end

%--------------------------------------------------------------------------%
% RevAndParseHex.m                                                         %
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
