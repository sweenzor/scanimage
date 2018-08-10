function pts = xformPoints(pts,T,inverse)
% T is a 2D or 3D affine
% pts is [N x 2] or [N x 3] array of xy or xyz points
    
    if nargin<3 || isempty(inverse)
        inverse = false;
    end
    
    if size(T,1) == 3
        pts(:,3) = 1;
        
        if inverse
            pts = pts / T';
        else
            pts = pts * T';
        end
            
        
        if ~isequal(T(3,:),[0 0 1])
            pts(:,1) = pts(:,1) ./ pts(:,3);
            pts(:,2) = pts(:,2) ./ pts(:,3);
        end
        
        pts(:,3) = [];
    else
        pts(:,4) = 1;
        
        if inverse
            pts = pts / T';
        else
            pts = pts * T';
        end
        
        if ~isequal(T(4,:),[0 0 0 1])
            pts(:,1) = pts(:,1) ./ pts(:,4);
            pts(:,2) = pts(:,2) ./ pts(:,4);
            pts(:,3) = pts(:,3) ./ pts(:,4);
        end
        
        pts(:,4) = [];
    end
end


%--------------------------------------------------------------------------%
% xformPoints.m                                                            %
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
