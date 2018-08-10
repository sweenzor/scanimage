classdef ContexImCfgPanel < handle
    %CONTEXIMCFGPANEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        hSIDV;
        hPnl;
        hAx;
        hFrm;
        hChannelSel;
        hContrastSlider;
        
        autoScaleSaturationFraction = [.1 .01];
        prevWindowButtonDownFcn;
        ctxtImInd;
    end
    
    properties (SetObservable)
        pmtChannel = 1;
        clim = [0 100];
    end
    
    methods
        function obj = ContexImCfgPanel(hSIDV)
            obj.hSIDV = hSIDV;
        end
        
        function init(obj)
            pp = [10 10 400 110];
            obj.hPnl = uipanel('parent',obj.hSIDV.hFig,'BorderType','None','BackgroundColor','k','units','pixels','position',pp,'Visible','off');
            obj.hAx = axes('parent',obj.hPnl,'color','none','XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',...
                [],'xcolor','none','ycolor','none','position',[0 0 1 1],'xlim',[0 1],'ylim',[0 1],'hittest','off');
            
            %% frame
            marg = 1;
            R = 10;
            cb = marg+R;
            crvS = R*sin(linspace(0,pi/2,20));
            crvC = R*cos(linspace(0,pi/2,20));
            
            xs = [cb-crvC       pp(3)-cb+crvS  pp(3)-cb+crvC  cb-crvS      marg];
            ys = [pp(4)-cb+crvS  pp(4)-cb+crvC  cb-crvS       marg+R-crvC  pp(4)-cb];
            patch('parent',obj.hAx,'xdata',xs/pp(3),'ydata',ys/pp(4),'LineWidth',2,'edgecolor','w','FaceColor','none','hittest','off');
            
            %% channel
            obj.hChannelSel = most.gui.wire.popupMenu('parent',obj.hPnl,'BackgroundColor','k', 'BorderColor','w','units','pixels','position',[8 pp(4)-32 160 26],'FontColor','w','FontSize',12,'FontWeight','bold','Bindings',{obj 'pmtChannel'});
            
            %% Contrast
            hContrastFlow = most.gui.uiflowcontainer('parent',obj.hPnl,'flowdirection','lefttoright','units','pixels','position',[4 pp(4)-68 392 32]);
            hContrastFlow.BackgroundColor = 'k';
            most.gui.staticText('parent',hContrastFlow,'string','Contrast:','BackgroundColor','k','FontColor','w','FontSize',12,'FontWeight','bold','HorizontalAlignment','right','WidthLimits',76);
            obj.hContrastSlider = most.gui.constrastSlider('parent',hContrastFlow,'BackgroundColor','k', 'BorderColor','w','BarColor','k','DarkColor',[0 0 0],'BrightColor',[1 1 1],'Bindings',{obj 'clim'});
            most.gui.wire.button('parent',hContrastFlow,'BackgroundColor','k', 'BorderColor','w','WidthLimits',30,'FontColor','w','FontSize',12,'FontWeight','bold','String','A','Callback',@obj.autoContrast);
            
            %% button
            most.gui.wire.button('parent',obj.hPnl,'BackgroundColor','k', 'BorderColor','w','units','pixels','position',[8 8 100 26],'FontColor','w','FontSize',12,'FontWeight','bold','String','Done','Callback',@obj.close);
        end
        
        function delete(obj)
            most.idioms.safeDeleteObj(obj.hPnl);
            most.idioms.safeDeleteObj(obj.hContrastSlider);
        end
        
        function show(obj,ctxtImInd)
            if isempty(obj.hPnl)
                obj.init();
            end
            
            %% move panel
            obj.hSIDV.hFig.Units = 'pixels';
            fp = obj.hSIDV.hFig.Position;
            
            obj.hPnl.Units = 'pixels';
            pp = obj.hPnl.Position;
            
            p = obj.hSIDV.hFig.CurrentPoint - pp([3 4])/2;
            p = [min(p(1),fp(3)-pp(3)) min(p(2),fp(4)-pp(4))];
            p = [max(p(1),0) max(p(2),0)];
            obj.hPnl.Position([1 2]) = p;
            
            %% cfg panel
            obj.ctxtImInd = ctxtImInd;
            ctxtIm = obj.hSIDV.contextImgs(ctxtImInd);
            
            obj.hChannelSel.choices = arrayfun(@(i)sprintf('PMT Channel %d',i),ctxtIm.chans,'uniformoutput',false);
            obj.pmtChannel = ctxtIm.chan;
            
            %% show panel
            obj.prevWindowButtonDownFcn = obj.hSIDV.hFig.WindowButtonDownFcn;
            obj.hSIDV.hFig.WindowButtonDownFcn = @obj.popupClick;
            obj.hPnl.Visible = 'on';
        end
        
        function close(obj,varargin)
            obj.hPnl.Visible = 'off';
            obj.hSIDV.hFig.WindowButtonDownFcn = @obj.popupClick;
            obj.hSIDV.hFig.WindowButtonDownFcn = obj.prevWindowButtonDownFcn;
        end
        
        function autoContrast(obj,varargin)
            ci = obj.hSIDV.contextImgs(obj.ctxtImInd);
            im = single([]);
            for i = 1:numel(ci.roiDatas)
                pixels = [im; single(ci.roiDatas{i}.imageData{obj.pmtChannel}{1}{1}{end}(:))];
            end
            
            if ~isempty(pixels)
                pixels = sort(pixels);
                N = numel(pixels);
                iblk = ceil(N*obj.autoScaleSaturationFraction(1));
                iwht = ceil(N*(1-obj.autoScaleSaturationFraction(2)));
                
                obj.clim = round([pixels(iblk) pixels(iwht)]);
            end
        end
        
        function popupClick(obj,varargin)
            if ~mouseIsInAxes(obj.hAx)
                obj.close();
            end
        end
        
        function set.pmtChannel(obj,v)
            obj.pmtChannel = v;
            ci = obj.hSIDV.contextImgs(obj.ctxtImInd);
            lut = double(ci.luts{v});
            obj.clim = lut;
            
            mx = -inf;
            mn = inf;
            
            for i = 1:numel(ci.roiDatas)
                rd = ci.roiDatas{i};
                
                im = rd.imageData{v}{1}{1}{end};
                p = im(:);
                mx = max([mx; p]);
                mn = min([mn; p]);
                
                ci.surfs(i).CData = repmat(uint8(255 * max(min((single(im) - lut(1)) / diff(lut),1),0))',1,1,3);
            end
            
            obj.hContrastSlider.max = double(mx);
            obj.hContrastSlider.min = double(mn);
            obj.hContrastSlider.value = lut;
        end
        
        function set.clim(obj,lut)
            obj.clim = lut;
            
            obj.hSIDV.contextImgs(obj.ctxtImInd).luts{obj.pmtChannel} = lut;
            ci = obj.hSIDV.contextImgs(obj.ctxtImInd);
            
            for i = 1:numel(ci.roiDatas)
                im = ci.roiDatas{i}.imageData{obj.pmtChannel}{1}{1}{end};
                ci.surfs(i).CData = repmat(uint8(255 * max(min((single(im) - lut(1)) / diff(lut),1),0))',1,1,3);
            end
        end
    end
    
end

function tf = mouseIsInAxes(hAx)
    coords =  hAx.CurrentPoint(1,1:2);
    xlim = hAx.XLim;
    ylim = hAx.YLim;
    tf = (coords(1) > xlim(1)) && (coords(1) < xlim(2)) && (coords(2) > ylim(1)) && (coords(2) < ylim(2));
end


%--------------------------------------------------------------------------%
% ContexImCfgPanel.m                                                       %
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
