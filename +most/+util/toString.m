function s = toString(v,numericPrecision)
%TOSTRING Convert a MATLAB array to a string
% s = toString(v)
%   numericPrecision: <Default=15> Maximum number of digits to encode into string for numeric values
%
% Unsupported inputs v are returned as '<unencodeable value>'. Notably,
% structs are not supported because at the moment structs are processed
% with structOrObj2Assignments.
%
% At moment - only vector cell arrays of uniform type (string, logical, numeric) are encodeable

s = '<unencodeable value>';

if nargin < 2 || isempty(numericPrecision)
    numericPrecision = 6;
end

if iscell(v)
    if isempty(v)
        s = '{}';
    elseif isvector(v)
        if iscellstr(v)
            v = strrep(v,'''','''''');
            if size(v,1) > 1 % col vector
                list = sprintf('''%s'';',v{:});
            else
                list = sprintf('''%s'' ',v{:});
            end
            list = list(1:end-1);
            s = ['{' list '}'];
        elseif all(cellfun(@isnumeric,v(:))) || all(cellfun(@islogical,v(:)))
            strv = cellfun(@(x)mat2str(x,numericPrecision),v,'UniformOutput',false);
            if size(v,1)>1 % col vector
                list = sprintf('%s;',strv{:});
            else
                list = sprintf('%s ',strv{:});
            end
            list = list(1:end-1);
            s = ['{' list '}'];
        else
            s = '{';
            for i = 1:numel(v)
                if isa(v{i}, 'function_handle')
                    s = [s func2str(v{i}) ' '];
                elseif ischar(v{i})
                    s = [s '''' v{i} ''' '];
                elseif isnumeric(v{i}) || islogical(v{i})
                    s = [s most.util.array2Str(v{i}) ' '];
                elseif iscell(v{i})
                    s = [s most.util.toString(v{i}) ' '];
                end
            end
            s(end) = '}';
        end
    end
    
elseif ischar(v)
    if strfind(v,'''')
       v =  ['$' strrep(v,'''','''''')];
    end
    s = ['''' v ''''];
elseif isnumeric(v) || islogical(v)
    if ndims(v) > 2
        s = most.util.array2Str(v);
    else
        s = mat2str(v,numericPrecision);
    end
    
elseif isa(v,'containers.Map')
    s = most.util.map2str(v);
    
elseif isa(v,'function_handle')
    s = func2str(v);
    if ~strcmpi(s(1),'@');
        s = ['@' s];
    end    
end

end


%--------------------------------------------------------------------------%
% toString.m                                                               %
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
