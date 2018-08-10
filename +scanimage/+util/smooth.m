% Source: http://stackoverflow.com/questions/12987905/how-to-make-a-curve-smoothing-in-matlab

function yy = smooth(y, span)
    yy = y;
    l = length(y);

    for i = 1 : l
        if i < span
            d = i;
        else
            d = span;
        end

        w = d - 1;
        p2 = floor(w / 2);

        if i > (l - p2)
           p2 = l - i; 
        end

        p1 = w - p2;

        yy(i) = sum(y(i - p1 : i + p2)) / d;
    end
end


%--------------------------------------------------------------------------%
% smooth.m                                                                 %
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
