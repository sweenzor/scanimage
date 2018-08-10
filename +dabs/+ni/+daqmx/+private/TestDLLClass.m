classdef TestDLLClass < handle
    %TEST Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        dllHeaderFile= 'C:\Program Files\National Instruments\NI-DAQ\DAQmx ANSI C Dev\include\NIDAQmx.h';
        libName = 'nicaiu';
    end
    
    methods
        function obj = TestDLLClass()
            if ~libisloaded(obj.libName)
                %disp([obj.driverPrettyName ': Initializing...']);
                warning('off','MATLAB:loadlibrary:parsewarnings');
                loadlibrary([obj.libName '.dll'],obj.dllHeaderFile);
                warning('on','MATLAB:loadlibrary:parsewarnings');
            end           
        end
        
        function delete(obj)
            if libisloaded(obj.libName)
                unloadlibrary(obj.libName);
            end
        end
    end
    
end



%--------------------------------------------------------------------------%
% TestDLLClass.m                                                           %
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
