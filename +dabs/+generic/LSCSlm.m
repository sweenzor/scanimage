classdef LSCSlm < dabs.interfaces.LinearStageController
    %MPC200 Class encapsulating MPC-200 device from Sutter Instruments    
     
    %% ABSTRACT PROPERTY REALIZATIONS (Devices.Interfaces.LinearStageController)    
    properties (Constant,Hidden)
        nonblockingMoveCompletedDetectionStrategy = 'poll';
    end
  
    properties (SetAccess=protected,Dependent)
        isMoving;
        infoHardware;
    end
    
    properties (SetAccess=protected,Dependent,Hidden)
        positionAbsoluteRaw;
        velocityRaw;
        accelerationRaw;
        invertCoordinatesRaw;
        maxVelocityRaw;
        
        resolutionRaw; %Resolution, in um, in the current resolutionMode
    end    

    properties (SetAccess=protected,Hidden)
        positionDeviceUnits = 1;
        velocityDeviceUnits = nan;
        accelerationDeviceUnits = nan;
    end
    
    %% CLASS Specific Properties
    properties (SetAccess=protected) 
        hSlm;
    end

    methods
        function obj = LSCSlm(varargin)
            pvArgs = varargin(1:2:end);
            pvVals = varargin(2:2:end);
            
            [tf,idx] = ismember('hSlm',pvArgs);
            assert(tf,'Could not find the input parameter ''hSLM''');
            varargin(idx:idx+1) = [];
            
            lscArgs = {'numDeviceDimensions',1};
            obj = obj@dabs.interfaces.LinearStageController(lscArgs{:},varargin{:});
            
            obj.hSlm = pvVals{idx};
        end
    end
    
    %% PROPERTY ACCESS METHODS
    methods

        % throws
        function tf = get.isMoving(obj)
            tf = false;
        end

        % throws
        function v = get.positionAbsoluteRaw(obj)
            v = obj.hSlm.lastWrittenPoint;
            if isempty(v)
                v = NaN;
            else
                v = v(3);
            end
        end

        function v = get.invertCoordinatesRaw(obj)
            v = false(1,obj.numDeviceDimensions);
        end
        
        function set.velocityRaw(obj,val)
            obj.val = NaN;
        end
        
        function v = get.velocityRaw(obj)
            v = NaN;
        end        
        
        function v = get.accelerationRaw(obj)
            v = NaN;
        end
        
        function v = get.resolutionRaw(obj)            
            v = NaN;
        end
            
        function v = get.maxVelocityRaw(obj)
             v =NaN;
        end            
        
    end
        
    %% ABSTRACT METHOD IMPLEMENTATIONS
    methods (Access=protected,Hidden)

        function moveStartHook(obj,absTargetPosn)
            assert(length(absTargetPosn)==1)            
            obj.hSlm.pointScanner([0,0,absTargetPosn]);
        end
        

        function interruptMoveHook(obj)
        end

        function recoverHook(obj)
        end      
    end 
end



%--------------------------------------------------------------------------%
% LSCSlm.m                                                                 %
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
