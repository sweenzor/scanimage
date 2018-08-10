function tf = isValidObj(obj)
    %ISVALIDOBJ Determines is the argument is an object handle and if the handle acutually
    % points to a valid object (isobject does not actually tell you this)
    tfObj = ~isempty(obj) && isobject(obj) && all(isvalid(obj));
    tfHdl = ~isempty(obj) && all(ishandle(obj));
    
    tf = tfObj || tfHdl;
end



%--------------------------------------------------------------------------%
% isValidObj.m                                                             %
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
