function tf = isvalidated(val,classes,attributes)
%ISVALIDATED Provides a logical output to Matlab's 'validateattributes' function/functionality
%   validateattributes() is designeed to throw an error if validation fails. 
%   In some cases, it's useful to return a 
%
%   isvalidated() can be used as an alternative to complex compound binary validations, 
%   e.g. isscalar(x) && isnumeric(x) && x>=0 && round(x)==x can be replaced with
%   isvalidated(x,{'numeric'},{'positive' 'integer' 'scalar'})

try 
    validateattributes(val,classes,attributes);
    tf = true;
catch ME
    if strcmpi(strtok(ME.message),'Expected')
        tf = false;
    else
        ME.rethrow();
    end
end



%--------------------------------------------------------------------------%
% isvalidated.m                                                            %
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
