function tf = isMatlabVerByString(queryString)
% ISMATLABVERBYSTRING  Returns true if the current matlab version is the one specified by the string. Returns false otherwise.
%   The main purpose of this function is to evaluate a specific matlab version instead of relying
%   on Matlab's native isVerLessThan method so we can add some specific optimizations and later 
%   aid us in isolating sections to remove when support for older versions is deprecated
%   NOTE: The query string must be in the same format as the following examples:
%       '(R2013a)'
%       '(R2015a)'
%       '(R2015b)'
%
    tf = false;

    matlabVer = ver('MATLAB');

    if strcmp(matlabVer.Release, queryString)
        tf = true;
    end
end



%--------------------------------------------------------------------------%
% isMatlabVerByString.m                                                    %
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
