function [str,prefix,exponent] = engineersStyle(x,unit,format)
    % based on http://www.mathworks.com/matlabcentral/answers/892-engineering-notation-printed-into-files
    % credits to Jan Simon
    
    if nargin < 2 || isempty(unit)
        unit = '';
    end
    
    if nargin < 3 || isempty(format)
        format = '%.1f';
    end
    
    if isempty(x)
        str = '';
        return
    end
    
    if x==0
        str = sprintf('%d%s',x,unit);
        return
    end
    
    exponent = 3 * floor(log10(x) / 3);
    y = x / (10 ^ exponent);
    expValue = [24,21,18,15,12,9,6,3,0,-3,-6,-9,-12,-15,-18,-21,-24];
    expName = {'Y','Z','E','P','T','G','M','k','','m','u','n','p','f','a','z','y'};
    expIndex = (exponent == expValue);
    if any(expIndex)  % Found in the list:
        str = sprintf([format '%s%s'],y,expName{expIndex},unit);
        prefix = expName{expIndex};
    else
        str = sprintf('%fe%+04d%s',y,exponent,unit);
        prefix = '';
        exponent = 0;
    end
end


%--------------------------------------------------------------------------%
% engineersStyle.m                                                         %
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
