function result=cellArrayPropertyAsArray(cellArray,propertyName)
    % If you have a cell array of objects, cellArray, get a property from each
    % element, and return them in a non-cell array of the same size as
    % cellArray.  This only works if the property values are thie kind of
    % thing you can stick into a regular array.
    result=cellfun(@(element)(element.(propertyName)),cellArray);
end


%--------------------------------------------------------------------------%
% cellArrayPropertyAsArray.m                                               %
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
