classdef InputParser < inputParser
% Cause I like to live on the edge.

    properties (Constant)
        fDummyVal = '___ThIs will never be duplicated';
    end

    properties (Hidden)
        fRequiredParams = cell(0,1);
    end
    
    methods
        
        function obj = InputParser
            obj = obj@inputParser;
            obj.KeepUnmatched = true;            
        end
        
    end
    
    methods
        
        function addRequiredParam(obj,pname,validator)
            if nargin < 3
                validator = @(x)true;
            end
            obj.addParamValue(pname,obj.fDummyVal,validator);
            obj.fRequiredParams{end+1,1} = pname;
        end
        
        function parse(obj,varargin)
            parse@inputParser(obj,varargin{:});
            s = obj.Results;
            
            for c = 1:numel(obj.fRequiredParams);
                fld = obj.fRequiredParams{c};
                assert(isfield(s,fld));
                if isequal(s.(fld),obj.fDummyVal);
                    error('Dabs:InputParser','Required property ''%s'' unspecified.',fld);
                end
            end
        end
                
        function createCopy(obj) %#ok<MANU>
            assert(false);
        end
        
    end
        
    
end


%--------------------------------------------------------------------------%
% InputParser.m                                                            %
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
