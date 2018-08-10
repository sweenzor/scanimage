function str = val2str(val)
    if iscell(val)
        str = most.util.cell2str(val);
    elseif ischar(val)
        str = ['''' val ''''];
    elseif isnumeric(val)
        str = mat2str(val);
    else
        str = sprintf('''Unknown class %s''',class(val));
        most.idioms.warn('Cannot convert class %s to string',class(val));
    end
end


%--------------------------------------------------------------------------%
% val2str.m                                                                %
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
