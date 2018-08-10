function data = loadjsonobj(fname,varargin)
data = most.json.loadjson(fname,varargin{:});

data = fieldToObj(data);
end

function data = fieldToObj(data,currentfieldnames)
    if nargin < 2 || isempty(currentfieldnames)
        currentfieldnames = {};
        s = data;
    else
        s = getfield(data,currentfieldnames{:});
    end
    
    if isa(s,'struct')
        if isfield(s,'classname')
            obj = eval([s.classname '.loadobj(s)']);
            if isempty(currentfieldnames)
                data = obj;
            else
                data = setfield(data,currentfieldnames{:},obj);
            end                
        else
            fnames = fieldnames(s);
            for idx = 1:length(fnames)
                data = fieldToObj(data,[currentfieldnames fnames{idx}]);
            end
        end
    elseif isa(s,'cell')
        for idx = 1:length(s)
            s{idx} = fieldToObj(s{idx});
            data = setfield(data,currentfieldnames{:},s);
        end
    end
end

%--------------------------------------------------------------------------%
% loadjsonobj.m                                                            %
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
