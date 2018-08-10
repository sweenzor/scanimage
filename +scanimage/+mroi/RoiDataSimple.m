classdef RoiDataSimple < handle & matlab.mixin.Copyable
    % class defining image data for one roi at multiple z depths
    properties
        hRoi;                          % handle to roi
        zs;                            % [numeric] array of zs
        channels;                      % [numeric] array of channelnumbers in imageData
        imageData;                     % cell of cell arrays of image data for
                                       %      channels (1st index) 
                                       %      volume (2nd index) 
                                       %      zs (3rd index)
    end
    
    methods
        %+++Test me
        function obj = castImageData(obj,newType)
            for iterChannels = 1:length(obj.imageData)
                for iterVolumes = 1:length(obj.imageData{iterChannels})
                    for iterZs = 1:length(obj.imageData{iterChannels}{iterVolumes})
                        obj.imageData{iterChannels}{iterVolumes}{iterZs} = cast(obj.imageData{iterChannels}{iterVolumes}{iterZs},newType);
                    end
                end
            end
        end
        
        %+++Test me
        function obj = multiplyImageData(obj,factor)
            for iterChannels = 1:length(obj.imageData)
                for iterVolumes = 1:length(obj.imageData{iterChannels})
                    for iterZs = 1:length(obj.imageData{iterChannels}{iterVolumes})
                        obj.imageData{iterChannels}{iterVolumes}{iterZs} = obj.imageData{iterChannels}{iterVolumes}{iterZs} .* cast(factor,'like',obj.imageData{iterChannels}{iterVolumes}{iterZs});
                    end
                end
            end
        end
    end
end


%--------------------------------------------------------------------------%
% RoiDataSimple.m                                                          %
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
