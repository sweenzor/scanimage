classdef Stage < dabs.interfaces.LinearStageController
    
    %% ABSTRACT PROPERTY REALIZATION (dabs.interfaces.LinearStageController)
    properties (Constant,Hidden)
        nonblockingMoveCompletedDetectionStrategy = 'poll'; % Either 'callback' or 'poll'
    end
    
    properties (SetAccess=protected,Dependent)
        isMoving;
    end
    
    properties (SetAccess=protected,Dependent,Hidden)
        invertCoordinatesRaw;
        positionAbsoluteRaw; 
        velocityRaw;
        accelerationRaw;
		maxVelocityRaw;        
    end
    
    properties (SetAccess=protected,Hidden)
        resolutionRaw = 1;
    end

    properties (SetAccess=protected)
        infoHardware = 'I am a simulated stage'; %String providing information about the hardware, e.g. firmware version, manufacture date, etc. Information provided is specific to each device type.
    end
    
    properties (SetAccess=protected,Hidden)
        positionDeviceUnits = .04e-6; %Units, in meters, in which the device's position values (as reported by positionAbsoluteRaw) are given
        velocityDeviceUnits = nan; %Units, in meters/sec, in which the device's velocity values (as reported by its hardware interface) are given. Value of NaN implies arbitrary units.
        accelerationDeviceUnits = nan; %Units, in meters/sec^2, in which the device's acceleration values (as reported by its hardware interface) are given. Value of NaN implies arbitrary units.         
    end
    
    %% DEVELOPER PROPERTIES
    properties (Hidden,SetAccess=protected)
        simulatedPosition;
        moveStartTime;
    end
    
    %% CTOR/DTOR
    methods
        function obj = Stage(varargin)
            pvArgs = most.util.filterPVArgs(varargin,{'numDeviceDimensions'});
            if isempty(pvArgs)
                pvArgs = {'numDeviceDimensions' 3};
            end
            
            obj = obj@dabs.interfaces.LinearStageController(pvArgs{:});  
            obj.simulatedPosition = zeros(1,obj.numDeviceDimensions);
            
            disp('Simulated stage initialized.');
        end
    end
    
    %% PROPERTY ACCESS
    methods
        
        function val = get.positionAbsoluteRaw(obj)
            val = obj.simulatedPosition;            
        end
        
        function val = get.resolutionRaw(obj)
            val = 1;
        end
        
        function val = get.isMoving(obj)
            val = ~isempty(obj.moveStartTime) && (toc(obj.moveStartTime) < 0.5);
        end        
        
    end
    
    %% ABSTRACT METHOD IMPLEMENTATIONS
    methods (Access=protected,Hidden)

%         function moveCompleteHook(obj,targetPosn)            
%             obj.simulatedPosition = targetPosn;
%             pause(0.01);
%         end   
        
        function moveStartHook(obj,targetPosn)                                                              
            obj.simulatedPosition = targetPosn;
            obj.moveStartTime = tic;
%             pause(0.01);
%             obj.moveDone();
        end    
        
        function interruptMoveHook(obj)
            return;
        end           
        
        function recoverHook(obj)
            return;
        end
        
        function resetHook(obj)
            return;
        end
        
        function zeroHardHook(obj,coords)
            assert(all(coords),'Cannot hard-zero individual coordinates.');
            obj.simulatedPosition = zeros(size(obj.simulatedPosition));
        end    
    
    end    
end


%--------------------------------------------------------------------------%
% Stage.m                                                                  %
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
