function result = ismemberOfCellArray(A,B)
    % Like ismember(A,B), but assumes that A and B are cell arrays, and
    % that their elements should be compared after being accessed with {}.
    result=false(size(A));
    for i=1:numel(A) ,
        result(i)=isSingletonMemberOfCellArray(A{i},B);
    end
end

function result = isSingletonMemberOfCellArray(a,B)
    isMatch=cellfun(@(element)(element==a),B);
    result=any(isMatch);
end


%--------------------------------------------------------------------------%
% ismemberOfCellArray.m                                                    %
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
