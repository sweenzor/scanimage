function str = structOrObj2Assignments(obj,varname,props,numericPrecision)
%STRUCTOROBJ2ASSIGNMENTS Convert a struct or object to a series of
% assignment statements.
%
% str = structOrObj2Assignments(obj,varname,props)
% obj: (scalar) ML struct or object
% varname: (char) base variable name in assignment statements (see below).
% props: (optional cellstr) list of property names to encode. Defaults to all
% properties of obj. Property names can include dot notation for nested object/structure values.
% numericPrecision: (optional integer) specifies max number of digits to use in output string for numeric assignments. (Default value used otherwise)
%
% str is returned as:
% <varname>.prop1 = value1
% <varname>.prop2 = value2
% <varname>.structProp1 = value3
% <varname>.structProp2 = value4
% ... etc

if nargin < 3 || isempty(props)
    props = fieldnames(obj);
end

if nargin < 4 
    numericPrecision = []; %Use default
end


if ~isscalar(obj)
    str = sprintf('%s = <nonscalar struct/object>\n',varname);
    return;
end

str = [];

if isempty(varname)
    separator = '';
else
    separator = '.';
end

for c = 1:numel(props);
    pname = props{c};        
    
    [base,rem] = strtok(pname,'.');
    
    if isempty(rem)
        val = obj.(pname);
    else
        val = eval(['obj.' pname]);                
    end
        
    qualname = sprintf('%s%s%s',varname,separator,pname);
    if isobject(val) 
        str = lclNestedObjStructHelper(str,val,qualname);
    elseif isstruct(val)
        str = lclNestedObjStructHelper(str,val,qualname);
    else
        str = lclAddPVPair(str,qualname,most.util.toString(val,numericPrecision));
    end
end

end

function s = lclAddPVPair(s,pname,strval)
s = [s pname ' = ' strval sprintf('\n')];
end

function str = lclNestedObjStructHelper(str,val,qualname)
if isempty(val)
    str = [str qualname ' = []' sprintf('\n')]; 
elseif numel(val) > 1
    for c = 1:numel(val)
        qualnameidx = sprintf('%s__%d',qualname,c);
        str = [str most.util.structOrObj2Assignments(val(c),qualnameidx)]; %#ok<AGROW>
    end
else
    str = [str most.util.structOrObj2Assignments(val,qualname)]; 
end
end


%--------------------------------------------------------------------------%
% structOrObj2Assignments.m                                                %
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
