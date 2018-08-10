function toggleAdvancedPanel(hObject,offset,orientation)
%% TOGGLEADVANCEDPANEL Resizes a graphics panel to display hidden or advanced features.
%% SYNTAX
%   toggleAdvancedPanel(hObject,offset,orientation)
%       hObject: the calling uicontrol
%       offset: the number of units by which to grow the panel
%       orientation: the direction in which the panel should grow (one of {'x' 'y'})

    if nargin < 3 || isempty(orientation)
        if nargin < 2
            error('Not enough arguments given; the first two arguments must be supplied.')
        end
        orientation = 'y';
    end
    
    if ~isnumeric(offset)
       error('''offset'' must be numeric.');
    end
    
    if ~ismember(orientation,{'x' 'y'})
       error('''orientation'' must be ''x'' or ''y'''); 
    end
    
    % determine the control's parent and all its siblings
    parentFig = ancestor(hObject,'figure');
    parentPos = get(parentFig,'Position');
    siblings = [findobj(parentFig,'Type','uicontrol'); findobj(parentFig,'Type','uitable'); findobj(parentFig,'Type','uipanel')];
    
    % toggle the button state (and invert 'offset', if necessary)
    if get(hObject,'Value')
        if strcmp(orientation,'y')
            set(hObject,'String','/\');
        elseif strcmp(orientation,'x')
            set(hObject,'String','<<');
        end
    else
        if strcmp(orientation,'y')
            set(hObject,'String','\/');
        elseif strcmp(orientation,'x')
            set(hObject,'String','>>');
        end
        offset = -offset;
    end
    
    % resize the main figure
    if strcmp(orientation,'y')
        parentPos(2) = parentPos(2) - offset;
        parentPos(4) = parentPos(4) + offset;
    elseif strcmp(orientation,'x')
        parentPos(3) = parentPos(3) + offset;
    end
    set(parentFig,'Position',parentPos);
    
    % because of Matlab's coordinate-system, a 'y'-oriented resize requires
    % a bit more work; shift all the GUI elements vertically to keep 
    % everything in the right place.
    if strcmp(orientation,'y')
        for hUI = siblings'
            if ~strcmpi(get(hUI,'Type'),'uipanel') && isempty(ancestor(hUI,'uipanel'))
                childPos = get(hUI,'Position');
                childPos(2) = childPos(2) + offset;
                set(hUI,'Position',childPos);
            elseif strcmpi(get(hUI,'Type'),'uipanel')
                childPos = get(hUI,'Position');
                childPos(2) = childPos(2) + offset;
                set(hUI,'Position',childPos);
            end
        end
    end
end


%--------------------------------------------------------------------------%
% toggleAdvancedPanel.m                                                    %
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
