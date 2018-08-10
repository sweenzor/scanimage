classdef Nonvalue < double
    %most.app.Nonvalue  This is an enumeration with only one value.  If you
    %set a model property to this value, the convention is that the property will not be set
    %to this "nonvalue", but will retain its original value.  Thus the only affect of the set
    %will be to fire the PreSet and PostSet events.  This is often a useful
    %thing to do, especially in the context of property bindings, and
    %particularly for dependent properties.
    
    enumeration
        The (nan) % The only possible value
    end    
end


%--------------------------------------------------------------------------%
% Nonvalue.m                                                               %
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
