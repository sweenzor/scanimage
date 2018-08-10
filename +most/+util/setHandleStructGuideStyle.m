function handles = setHandleStructGuideStyle(hFig)
% generates the handle_struct (as known for guide GUIs) for a figure and
% set it as guidata for the figure. Only objects with the property 'Tag'
% set are included

hFig = ancestor(hFig,'figure'); % ensure h is a figure handle
objs = findobj(hFig); % get all children of figure
objs = [hFig,objs(:)']; % include figure itself is an object as well

handles = struct();

% find all objects with property 'Tag' set and add to handles struct
for idx = 1:length(objs)
    obj = objs(idx);
    tag = get(obj,'Tag');
    if ~isempty(tag)
        handles.(tag) = obj;
    end
end

% set handles as guidata for figure
guidata(hFig,handles);
end

%--------------------------------------------------------------------------%
% setHandleStructGuideStyle.m                                              %
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
