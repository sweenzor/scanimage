function [xs,ys] = xformPointsXY(xs,ys,T,varargin)
    % T is a 2D affine
    % x is [m x n] array of x points
    % y is [m x n] array of y points
    
    r=[xs(:),ys(:)];
    r = scanimage.mroi.util.xformPoints(r,T,varargin{:});
    xs=reshape(r(:,1),size(xs));
    ys=reshape(r(:,2),size(ys));
end


%--------------------------------------------------------------------------%
% xformPointsXY.m                                                          %
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
