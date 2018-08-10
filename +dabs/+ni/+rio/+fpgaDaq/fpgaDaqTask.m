classdef fpgaDaqTask < hgsetget
    %FPGADAQAOTASK Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name;
        hFpgaDaq;
        chans;
        deviceNames;
        
        buffered = false;
        
        sampClkSrc;
        sampClkTimebaseSrc;
        sampClkTimebaseRate;
        sampClkRate;
        sampClkMaxRate;
        
        writeRegenMode;
        
        sampQuantSampMode;
        sampQuantSampPerChan;
        writeRelativeTo;
        writeOffset;
    end
    
    methods
        function obj = fpgaDaqTask(hDaq)
            obj.hFpgaDaq = hDaq;
            obj.deviceNames = {hDaq.deviceID};
        end
    end
    
    methods
        function control(~,cmd)
            assert(strcmp(cmd,'DAQmx_Val_Task_Unreserve'), 'Don''t know this cmd!');
        end
        
        function stop(obj)
            obj.abort();
        end
    end
    
    methods
        function set.sampClkSrc(~,v)
            assert(isempty(v), 'Cannot set sampClkSrc');
        end
        
        function set.sampClkTimebaseSrc(~,~)
            error('Cannot set sampClkTimebaseSrc');
        end
        
        function set.sampClkTimebaseRate(~,~)
            error('Cannot set sampClkTimebaseRate');
        end
        
        function set.sampClkRate(obj,v)
            obj.hFpgaDaq.hFpga.LoopPeriodControlticks = 40e6 / v;
        end
        
        function v = get.sampClkRate(obj)
            v = 40e6 / double(obj.hFpgaDaq.hFpga.LoopPeriodControlticks);
        end
        
        function v = get.sampClkMaxRate(~)
            v = 1e6;
        end
    end
    
end



%--------------------------------------------------------------------------%
% fpgaDaqTask.m                                                            %
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
