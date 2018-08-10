function [uuid_uint64,uuid_char] = generateUUIDuint64
    % generates a universally unique identifier
    % example: 0af56da1-0232-440c-b79d-ba88849d3af9 ( ?dB€Í•C±ÿﬁ]?“√ )
    
    uuid_uint64 = typecast([randi(intmax('uint32'),'uint32');randi(intmax('uint32'),'uint32')],'uint64');
    uuid_char = sprintf('%X',uuid_uint64);
end

%--------------------------------------------------------------------------%
% generateUUIDuint64.m                                                     %
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
