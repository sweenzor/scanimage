classdef MotorRegistry < scanimage.interfaces.Class
    
    properties (Constant, Hidden)
        controllerMap = zlclInitControllerMap();
    end
    
    methods (Static)
        function info = getControllerInfo(type)
            assert(ischar(type),'''type'' must be a stage controller type.');
            m = scanimage.components.motors.MotorRegistry.controllerMap;
            
            keys = m.keys();
            idx = find(strcmpi(type,keys)); % case independent key lookup
           
            if ~isempty(idx)
                key = keys{idx(1)};
                info = m(key);
            else
                info = [];
            end
        end
    end
end

function m = zlclInitControllerMap
    m = containers.Map();
    
    s = struct();
    s.Names = {'analog'};
    s.Class = 'dabs.generic.LSCPureAnalog';
    s.ListName = 'Generic Analog Controller';
    s.SupportFastZ = true;
    s.SubType = '';
    s.TwoStep.Enable = false;
    s.SafeReset = true;
    s.NumDimensionsPreset = false;
    zlclAddMotor(m,s);
    
    s = struct();
    s.Names = {'simulated.stage'};
    s.Class = 'dabs.simulated.Stage';
    s.ListName = 'Simulated Stage';
    s.SupportFastZ = false;
    s.SubType = '';
    s.TwoStep.Enable = false;
    s.SafeReset = true;
    s.NumDimensionsPreset = false;
    zlclAddMotor(m,s);
    
    s = struct();
    s.Names = {'simulated.piezo'};
    s.Class = 'dabs.simulated.Piezo';
    s.ListName = 'Simulated Piezo';
    s.SupportFastZ = true;
    s.SubType = '';
    s.TwoStep.Enable = false;
    s.SafeReset = true;
    s.NumDimensionsPreset = true;
    zlclAddMotor(m,s);
    
    s = struct();
    s.Names = {'slm'};
    s.Class = 'dabs.generic.LSCSlm';
    s.ListName = 'SLM FastZ Actuator';
    s.SupportFastZ = true;
    s.SubType = '';
    s.TwoStep.Enable = false;
    s.SafeReset = true;
    s.NumDimensionsPreset = true;
    zlclAddMotor(m,s);
    
    list = what('scanimage/components/motors/MotorRegistry');
    if numel(list)
        assert(numel(list)<2,'Multiple motor registries found on path. Make sure only one scanimage installation is on the path.');
        
        [~,list] = cellfun(@fileparts,list.m,'UniformOutput',false);
        list = strcat('scanimage.components.motors.MotorRegistry.',list);
        for i = 1:numel(list)
            mtr = eval(list{i});
            zlclAddMotor(m,mtr);
        end
    else
        most.idioms.warn('Motor registry not found.');
    end
end

function zlclAddMotor(m,s)
    names = s.Names;
    for c = 1:length(names)
        m(names{c}) = s;
    end
end


%--------------------------------------------------------------------------%
% MotorRegistry.m                                                          %
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
