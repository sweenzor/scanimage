function out = isenum(value)
%ISENUM Returns true if the class contains an enumeration.
%
%   OUT = isenum(OBJ) returns true if the object, OBJ, is a class containing
%   enumeration values.
%
%   OBJ may be a meta.class object for the class of interest, or an instance of
%   the class.
%
%   OUT = isenum(CLASSNAME) treats the string, CLASSNAME, as the name of the
%   class.

if ischar(value)
    value = eval(['?' value]);
end

if ~isa(value, 'meta.class')
    value = metaclass(value);
end

out = ~isempty(value) && ~isempty(value.EnumerationMemberList);


%--------------------------------------------------------------------------%
% isenum.m                                                                 %
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
