classdef Galvo < scanimage.mroi.scanners.LinearScanner
    properties
        flytoTimeSeconds;
        flybackTimeSeconds;
        useScannerTimebase = false;
    end
    
    properties (Hidden)
        impulseResponseDuration = 4e-4;
    end

    methods(Static)
        function obj = default
            obj=scanimage.mroi.scanners.Galvo(27,20/27,27/128,1e-3,-27/2,200000);
        end
    end

    methods
        % See Note (1)
        function obj=Galvo(fullAngleDegrees,...
                           voltsPerDegree,...
                           flytoTimeSeconds,...
                           flybackTimeSeconds,...
                           parkAngleDegrees,...
                           sampleRateHz)
            
            obj.name = 'Galvo Scanner';
                       
            if nargin>=1 && ~isempty(fullAngleDegrees)
               obj.travelRange  = [-fullAngleDegrees fullAngleDegrees]./2;
            end

            if nargin>=2 && ~isempty(voltsPerDegree)
               obj.voltsPerDistance = voltsPerDegree;
            end

            if nargin>=3 && ~isempty(flytoTimeSeconds)
               obj.flytoTimeSeconds = flytoTimeSeconds;
            end

            if nargin>=4 && ~isempty(flybackTimeSeconds)
               obj.flybackTimeSeconds = flybackTimeSeconds;
            end
            
            if nargin>=5 && ~isempty(parkAngleDegrees)
               obj.parkPosition = parkAngleDegrees;
            end
            
            if nargin>=6 && ~isempty(sampleRateHz)
               obj.sampleRateHz = sampleRateHz;
            end
            
            obj.bandwidth = 3000;
        end
    end
end

%--------------------------------------------------------------------------%
% Galvo.m                                                                  %
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
