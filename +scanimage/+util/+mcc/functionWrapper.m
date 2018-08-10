function varargout = functionWrapper(fWrapper_fstruct, varargin)
persistent PARSED_PERSISTENT_VARS;
if isempty(PARSED_PERSISTENT_VARS)
    PARSED_PERSISTENT_VARS = containers.Map;
end

%init if dne
if ~isKey(PARSED_PERSISTENT_VARS, fWrapper_fstruct.name)
    PARSED_PERSISTENT_VARS(fWrapper_fstruct.name) = struct();
end

pvarfnames = fieldnames(PARSED_PERSISTENT_VARS(fWrapper_fstruct.name));
pnames = fWrapper_fstruct.persistnames;
newnames = setxor(pvarfnames, pnames);
oldnames = intersect(pvarfnames, pnames);
%pvars have changed, add new pvars
if ~isempty(newnames)
    oldpstruct = PARSED_PERSISTENT_VARS(fWrapper_fstruct.name);
    pstruct = struct();
    for i=1:numel(oldnames)
        pstruct.(oldnames{i}) = oldpstruct.(oldnames{i});
    end
    for i=1:numel(newnames)
        pstruct.(newnames{i}) = [];
    end
    PARSED_PERSISTENT_VARS(fWrapper_fstruct.name) = pstruct;
end

%unpack persistent vars
pstruct = PARSED_PERSISTENT_VARS(fWrapper_fstruct.name);
for i=1:numel(pnames)
    eval([pnames{i} ' = pstruct.' pnames{i} ';']);
end

%unpack fcn arguments
for i=1:length(fWrapper_fstruct.argnames)
    if strcmp(fWrapper_fstruct.argnames{i}, 'varargin')
        varargin = varargin(i:end);
        break;
    end
    if strcmp(fWrapper_fstruct.argnames{i}, '~')
        continue;
    end
    eval([fWrapper_fstruct.argnames{i} ' = varargin{i};']);
end

eval(fWrapper_fstruct.fcn);

%repack persistent vars
fWrapper_pstruct = PARSED_PERSISTENT_VARS(fWrapper_fstruct.name);
fWrapper_pfields = fieldnames(fWrapper_pstruct);
for i=1:length(fWrapper_pfields)
    fWrapper_pstruct.(fWrapper_pfields{i}) = eval(fWrapper_pfields{i});
end
PARSED_PERSISTENT_VARS(fWrapper_fstruct.name) = fWrapper_pstruct;
%varargout is set automatically by eval so don't pack output args
if ~any(strcmp(fWrapper_fstruct.outnames, 'varargout'))
    for i=1:length(fWrapper_fstruct.outnames)
        outnm = fWrapper_fstruct.outnames{i};
        varargout{i} = eval(fWrapper_fstruct.outnames{i});
    end
end
end

%--------------------------------------------------------------------------%
% functionWrapper.m                                                        %
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
