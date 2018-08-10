function result = cellifyIfNeeded(thing)
    % If thing is a cell array, returns thing.  Otherwise, returns {thing}.
    % Useful for function args where generally the argument is a cell
    % array, but sometimes the caller wants to call it with a single
    % element.
    if iscell(thing) ,
        result=thing;
    else
        result={thing};
    end
end


%--------------------------------------------------------------------------%
% cellifyIfNeeded.m                                                        %
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
