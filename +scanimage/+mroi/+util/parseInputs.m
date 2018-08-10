function inputstruct = parseInputs(inputs)
% takes an input of form {'argument1',value1,'argument2',value2, ...}
% and creates a struct of the form
%   inputstruct.argument1 = value1
%   inputstruct.argument2 = value2
%       ...

assert(mod(length(inputs),2)==0,...
    'Error parsing inputs: inputs must be ''argument'',value pairs.');

inputs = reshape(inputs,2,[]);
%assert(all(cellfun(@(a)isa(a,'char'),inputs(1,:))));

inputstruct = struct();
for iter = 1:size(inputs,2)
    inputstruct.(inputs{1,iter}) = inputs{2,iter};
end
end


%--------------------------------------------------------------------------%
% parseInputs.m                                                            %
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
