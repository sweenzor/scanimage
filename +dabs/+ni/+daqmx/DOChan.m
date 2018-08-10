classdef DOChan < dabs.ni.daqmx.private.DigitalChan
    %DOCHAN  A DAQmx Digital Output Channel
    %   Detailed explanation goes here
    
    properties (Constant)
        type = 'DigitalOutput';
    end
    
    properties (Constant, Hidden)
        typeCode = 'DO';
    end
    
    %%TMW: Should we really have to create a constructor when a simple pass-through to superclass would do?
    methods 
        function obj = DOChan(varargin)
            obj = obj@dabs.ni.daqmx.private.DigitalChan(varargin{:});            
        end        
    end
    
end



%--------------------------------------------------------------------------%
% DOChan.m                                                                 %
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
