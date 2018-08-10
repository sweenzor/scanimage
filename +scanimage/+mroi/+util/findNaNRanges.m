function nanRanges = findNaNRanges(data)
% finds the start and end indices of nan ranges in a data stream
% input: data - needs to be a vector of data
% outputs:
%   nanRanges- nx2 matrix, column 1 is start indices column 2 is end indices
%   
% example
%      findNaNRanges([1 2 3 NaN NaN 4 NaN])
%
%             ans =
% 
%                  4     5
%                  7     7
%
nans = any(isnan(data),2);

%find positive edges
nansshiftright = [false;nans(1:end-1)];
posedge = find(nans > nansshiftright);

nansshiftleft = [nans(2:end);false];
negedge = find(nans > nansshiftleft);

nanRanges = [posedge, negedge];
end


%--------------------------------------------------------------------------%
% findNaNRanges.m                                                          %
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
