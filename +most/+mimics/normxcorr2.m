function res = normxcorr2(A, B)
  disp('most.mimics.normxcorr2: WARNING, naive normalization. Different from toolbox version');
  if nargin == 2
    res = most.mimics.xcorr2(A,B);
    maxVal = max(max(res));
    minVal = min(min(res));

    if maxVal > 0 && minVal < 0
      normVal = max(maxVal,-minVal);
    elseif maxVal > 0 
      normVal = maxVal;
    elseif minVal < 0 
      normVal = minVal;
    else
      disp('most.mimics.normxcorr2: Error, zero matrix');
    end
    normVal
    res = res./normVal;


  else
    disp('most.mimics.normxcorr2: Unexpected number of arguments');
  end
end


%--------------------------------------------------------------------------%
% normxcorr2.m                                                             %
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
