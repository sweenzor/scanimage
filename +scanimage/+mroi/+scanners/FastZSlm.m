classdef FastZSlm < scanimage.mroi.scanners.FastZ
    properties
        hSlm;
        hDevice;
        sampleRateHz; % generally ignored in SLM FastZ scanning
        simulated = false;
        positionUnits = 1;
        name;
    end
    
    properties (Dependent)
        calibrationData;
    end
    
    methods
        function obj=FastZSlm(hSlm)
            obj = obj@scanimage.mroi.scanners.FastZ();
            obj.hSlm = hSlm;
            assert(hSlm.queueAvailable,'Cannot use SLM as a FastZ device because of lack of triggering capabilities');
        end
        
        function path_FOV = scanPathFOV(obj,ss,zPowerReference,actz,dzdt,seconds,slowPathFov)
            path_FOV = actz(:);
        end
        
        function path_FOV = scanStimPathFOV(obj,ss,startz,endz,seconds,maxPoints)
            error('Stimulation with SLM as FastZ device is unsupported');
        end
        
        function path_FOV = interpolateTransits(obj,ss,path_FOV,tune,zWaveformType)
            % No-op
        end
        
        function path_FOV = transitNaN(obj,ss,dt)
            path_FOV =  [];
        end
        
        function path_FOV = zFlybackFrame(obj,ss,frameTime)
            path_FOV = 0;
        end
        
        function path_FOV = padFrameAO(obj, ss, path_FOV, frameTime, flybackTime, zWaveformType)
            % No-op
        end
        
        function samplesPerTrigger = samplesPerTriggerForAO(obj,ss,outputData)
            samplesPerTrigger = 1;
        end
        
        function output = refPosition2Volts(obj,zs)
            numPoints = numel(zs);
            output = zeros(numPoints,3);
            output(:,3) = zs(:);
            
            %Convert from position units to meters
            output = output * obj.positionUnits;
            
            output = obj.zAlignment.compensateScannerZ(output); % apply z alignment, caluclated in meters

            output = obj.hSlm.computeSinglePointPhaseMaskScalarDiffraction(output(:,1),output(:,2),output(:,3));
            output = obj.hSlm.rad2PixelVal(output);
        end
        
        function zs = volts2RefPosition(obj,volts)
            error('Not implemented in FastZSlm');
        end
        
        function zs = feedbackVolts2RefPosition(obj,volts)
            error('Not implemented in FastZSlm');
        end
        
        function [metaData,ao_volts] = getCachedOptimizedWaveform(obj,sampleRateHz,ao_volts)
            metaData = [];
        end
    end
    
    methods
        function val = get.calibrationData(obj)
           val = [];
        end
        
        function set.calibrationData(obj,val)
            %No-op
        end        
    end
    
    %%% Overloaded functions from scanimage.mroi.scanners.FastZ
    methods
        function val = accessZAlignmentPreSet(obj,val)
            obj.hSlm.zAlignment = val;
        end
        
        function val = accessZAlignmentPostGet(obj,~)
            val = obj.hSlm.zAlignment;
        end        
    end
end


%--------------------------------------------------------------------------%
% FastZSlm.m                                                               %
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
