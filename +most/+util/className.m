function out = className(className,type)
%className - returns the name / related paths of a class
%
% SYNTAX
%     s = className(className)
%     s = className(className,type)
%     
% ARGUMENTS
%     className: object or string specifying a class
%     type:      <optional> one of {'classNameShort','classPrivatePath','packagePrivatePath','classPath'}
%                   if omitted function defaults to 'classNameShort' 
%
% RETURNS
%     out - a string containing the appropriate class name / path

if nargin < 2 || isempty(type)
    type = 'classNameShort';
end

if isobject(className)
    className = class(className);
end

switch type
    case 'classNameShort'
        classNameParts = textscan(className,'%s','Delimiter','.');
        out = classNameParts{1}{end};
    case 'classPrivatePath'
        out = fullfile(fileparts(which(className)),'private');
    case 'packagePrivatePath'
        mc = meta.class.fromName(className);
        containingpack = mc.ContainingPackage;
        if isempty(containingpack)
            out = [];
        else
            p = fileparts(fileparts(which(className)));
            out = fullfile(p,'private');
        end
    case 'classPath'
        out = fileparts(which(className));
    otherwise
        error('most.util.className: Not a valid option: %s',type);
end
end


%--------------------------------------------------------------------------%
% className.m                                                              %
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
