classdef LoadingPanel < handle
    %CONTEXIMCFGPANEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        hSIDV;
        hPnl;
        hAx;
        hFrm;
    end
    
    methods
        function obj = LoadingPanel(hSIDV)
            obj.hSIDV = hSIDV;
        end
        
        function init(obj)
            sz = [200 32];
            obj.hPnl = uipanel('parent',obj.hSIDV.hFig,'BorderType','None','BackgroundColor','k','units','pixels','position',[0 0 sz],'Visible','off');
            obj.hAx = axes('parent',obj.hPnl,'color','none','XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',...
                [],'xcolor','none','ycolor','none','position',[0 0 1 1],'xlim',[0 1],'ylim',[0 1],'hittest','off');
            
            %% frame
            marg = 1;
            R = 10;
            cb = marg+R;
            crvS = R*sin(linspace(0,pi/2,20));
            crvC = R*cos(linspace(0,pi/2,20));
            
            xs = [cb-crvC       sz(1)-cb+crvS  sz(1)-cb+crvC  cb-crvS      marg];
            ys = [sz(2)-cb+crvS  sz(2)-cb+crvC  cb-crvS       marg+R-crvC  sz(2)-cb];
            patch('parent',obj.hAx,'xdata',xs/sz(1),'ydata',ys/sz(2),'LineWidth',2,'edgecolor','w','FaceColor','none','hittest','off');
            text(.5,.5,'Loading data...','parent',obj.hAx,'Color','w','FontSize',12,'FontWeight','bold','horizontalalignment','center');
        end
        
        function delete(obj)
            most.idioms.safeDeleteObj(obj.hPnl);
        end
        
        function show(obj)
            if isempty(obj.hPnl)
                obj.init();
            end
            obj.hSIDV.hFig.Units = 'pixels';
            obj.hPnl.Units = 'pixels';
            p = obj.hSIDV.hFig.Position;
            sz = obj.hPnl.Position([3 4]);
            pp = [(p(3)-sz(1))/2 (p(4)-sz(2))/2 sz];
            obj.hPnl.Position = pp;
            obj.hPnl.Visible = 'on';
            drawnow();
        end
        
        function close(obj,varargin)
            obj.hPnl.Visible = 'off';
        end
    end
end

%--------------------------------------------------------------------------%
% LoadingPanel.m                                                           %
% Copyright � 2018 Vidrio Technologies, LLC                                %
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
