function pattern = checkerPattern(resolutionXY,checkerSize)
if nargin < 2 || isempty(checkerSize)
   checkerSize = 2; 
end

unit = zeros(2*checkerSize);
unit(1:checkerSize,1:checkerSize) = 1;
unit((checkerSize+1):(2*checkerSize),(checkerSize+1):(2*checkerSize)) = 1;

repsXY = ceil(resolutionXY/(checkerSize*2));
pattern = repmat(unit,repsXY(2),repsXY(1));
pattern((resolutionXY(2)+1):end,:) = [];
pattern(:,(resolutionXY(1)+1):end) = [];
end

%--------------------------------------------------------------------------%
% checkerPattern.m                                                         %
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
