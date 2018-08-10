function result = xcorr2(A, B)
%   IMPORTANT: Currently only real inputs are supported
%
    result = xcorr2_matlab(single(A),single(B));
end

function res = xcorr2_matlab(A,B)
%   NOTE: Removing conj, since its unnecessary for our current use-case
    [M, N] = size(A);
    [P, Q] = size(B);
    %conjB = conj(B);
    resultXElements = M + N - 1;
    resultYElements = M + N - 1;
    res = zeros(resultXElements, resultYElements);
    for l = -(Q - 1):(N - 1)
        for k = -(P - 1):(M - 1)
            val = 0;
            for m = 1:M
                for n = 1:N
                    indexX = m - k;
                    indexY = n - l;
                    if (indexX > 0) && (indexY > 0) && (indexX <= P) && (indexY <= Q)
                        %val = val + A(m,n) * conjB(indexX, indexY);
                        val = val + A(m,n) * B(indexX, indexY);
                    end
                end
            end
            res(P + k,Q + l) = val;
        end
    end
end


%--------------------------------------------------------------------------%
% xcorr2.m                                                                 %
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
