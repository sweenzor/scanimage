classdef Resonant < handle
    properties
        sampleRateHz;
        fullAngleDegrees;
        fov2VoltageFunc;
        bidirectionalScan;
        scannerPeriod;
        fillFractionSpatial;
    end
    
    properties (Dependent, SetAccess = private)
        fillFractionTemporal;
    end
    
    properties (Hidden)
        fillFractionTemporal_ = [];
    end

    methods(Static)
        function obj = default
            obj=scanimage.mroi.scanners.Resonant(15,5/15,true,7910,0.7,1e5);
        end
    end

    methods
        function obj=Resonant(fullAngleDegrees,fov2VoltageFunc,bidirectionalScan,scannerPeriod,fillFractionSpatial,sampleRateHz)
            obj.fullAngleDegrees = fullAngleDegrees;
            obj.fov2VoltageFunc   = fov2VoltageFunc;
            obj.bidirectionalScan = bidirectionalScan;
            obj.scannerPeriod  = scannerPeriod;
            obj.fillFractionSpatial = fillFractionSpatial;
            obj.sampleRateHz = sampleRateHz;
        end
        
        function val = get.fillFractionTemporal(obj)
            if isempty(obj.fillFractionTemporal_)
                obj.fillFractionTemporal_ = 2/pi * asin(obj.fillFractionSpatial);
            end
            val = obj.fillFractionTemporal_;
        end
        
        function set.fillFractionSpatial(obj,val)
            obj.fillFractionSpatial = val;
            obj.fillFractionTemporal_ = [];
        end
    end
end


%--------------------------------------------------------------------------%
% Resonant.m                                                               %
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
