classdef PockelsDisplay < handle
    properties
        value = 100;
        calibrated = false;
        name = '';
    end
    
    properties (Access = private)
        containers;
        hAx;
        hStatusSurf;
        hStatusText;
        hOutlineSurf;
    end
    
    methods
        function obj = PockelsDisplay(hParent,name)
            if nargin < 1 || isempty(hParent);
                hParent = figure();
            end
            
            if nargin < 2
                name = 'Pockels Cell';
            end
            
            obj.containers.main = most.idioms.uiflowcontainer('Parent',hParent,'FlowDirection','TopDown');
                obj.containers.top = uicontainer('Parent',obj.containers.main);
                    obj.hAx = axes('Parent',obj.containers.top,'XLim',[0,1],'YLim',[0,1],'LooseInset',[0 0 0 0],'XTick',[],'YTick',[],'XTickLabel',[],'YTickLabel',[],'Visible','off');            
                        obj.hStatusSurf = surface('Parent',obj.hAx,'XData',[0,0;1 1],'YData',[0 1;0 1],'ZData',zeros(2,2),'FaceColor',[1 0 0],'FaceAlpha',0.8,'EdgeColor','none');
                        obj.hOutlineSurf = surface('Parent',obj.hAx,'XData',[0,0;1 1],'YData',[0 1;0 1],'ZData',zeros(2,2),'FaceColor','none','EdgeColor',[0.3 0.3 0.3]);
                        obj.hStatusText = text('Parent',obj.hAx,'Position',[0.5,0.5],'HorizontalAlignment','center','VerticalAlignment','middle');
            obj.updateDisplay();
            
            obj.name = name;
        end
        
        function delete(obj)
            delete(obj.containers.main);            
        end
    end
    
    methods
        function set.value(obj,val)
            validateattributes(val,{'numeric'},{});
            obj.value = val;
            obj.updateDisplay();
        end
        
        function set.calibrated(obj,val)
            validateattributes(val,{'logical'},{'scalar'});
            obj.calibrated = val;
            obj.updateDisplay();
        end
        
        function set.name(obj,val)
            if isempty(val)
                val = ''; % assert right type
            else
                validateattributes(val,{'char'},{});
            end
            
            obj.name = val;
            obj.updateDisplay();
        end
    end
    
    methods (Access = private)
        function updateDisplay(obj)
            if obj.calibrated
                if isnan(obj.value)
                    obj.hStatusSurf.XData = [0,0;1,1];
                    obj.hStatusSurf.YData = [0,1;0,1];
                    app = sprintf('\n(Undefined)');
                else
                    obj.hStatusSurf.XData = [0,0;1,1] .* obj.value/100;
                    obj.hStatusSurf.YData = [0,1;0,1];
                    app = '';
                end
            else
                obj.hStatusSurf.XData = [0,0;1,1];
                obj.hStatusSurf.YData = [0,1;0,1];
                app = sprintf('\n(Uncalibrated)');
            end
            obj.hStatusText.String = sprintf('%s: %.0f%%%s',obj.name,obj.value,app);
        end
    end
end

%--------------------------------------------------------------------------%
% PockelsDisplay.m                                                         %
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
