classdef AIChan < dabs.ni.daqmx.private.AnalogChan
    %AICHAN A DAQmx Analog Input Channel
    
    properties (Constant)
        type = 'AnalogInput';
    end
    
    properties (Constant, Hidden)
        typeCode = 'AI';
    end
    
    %% CONSTRUCTOR/DESTRUCTOR
    methods
        function obj = AIChan(varargin)
            %Constructor required, as this is a concrete subclass of abstract lineage
            obj = obj@dabs.ni.daqmx.private.AnalogChan(varargin{:});
            
        end
    end
    
    %% METHODS
    
    methods (Hidden)
        
        function postCreationListener(obj)
            %Handle input data type
            errorCond = false;
            for i=1:length(obj)
                rawSampSize = obj(i).getQuiet('rawSampSize');
                switch rawSampSize
                    case 8
                        rawSampClass = 'int8';
                    case 16
                        rawSampClass = 'int16';
                    case 32
                        rawSampClass = 'int32';
                    otherwise
                        errMessage = ['Unsupported sample size (' num2str(rawSampSize) '). Task deleted.'];
                        errorCond = true;
                        break;
                end
                if isempty(obj(i).task.rawDataArrayAI)
                    obj(1).task.rawDataArrayAI = feval(rawSampClass,0); %Creates a scalar array of rawSampClass
                elseif ~strcmpi(class(obj(i).task.rawDataArrayAI), rawSampClass);
                    errMessage = ['All ' obj(i).type ' channels in a given Task must have the same raw data type. Task deleted.'];
                    errorCond = true;
                    break;
                end
            end
            
            if errorCond
                delete(obj(1).task); %All created objects presumed (known) to belong to same class
                error(errMessage);
            end
        end
        
        
    end
    
    
end





%--------------------------------------------------------------------------%
% AIChan.m                                                                 %
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
