classdef RoiDisplay < handle
    properties
        zs   = [0];             % [numeric] array of zs that are viewed in this object     
        chan = [];              % [numeric] scalar channel being displayed in this Axes object
        showCrosshair = false;  % [boolean] show/hide crosshair in display
        debugEnabled = false;   % [boolean] show/hide roiData debug in the ROI label.
        transposeImage = true;  % roiData.imageData stores images transposed
        parent;                 % parent graphic handle
        dataMultiplier = 1;
        CLim = [0,100];
        motionMatrix = eye(4);
        stabilizeDisplay = false;
        tfMap = containers.Map({true false}, {'on' 'off'});
        lastClickedSurfPoint;
    end
    

    properties (SetAccess = private, Hidden)
        hSI;
        hAxes;
        hMotionContainer;
        hMotionContainerOnTop;
        hInverseMotionContainer;
        hSurfs;
        hMainSurfs;
        roiMap;
        labelMap;
        hCrossHair;
        dragdata;
        hUicMain;
        hAnnotationAx;
        hUicFlowMain;
        hSurfContextMenu;
        hAxesContextMenu;
        hAnnotationMenu;
        hCursor;
        hOnTopGroup;
        hHighlightGroup;
        hLiveHistograms = [];
        hMeasureGroup;
        hPatchMeasure;
        hLineMeasure;
        hTextMeasure;
        is3dview = false;
        isCurrentView;
        isTiledView;
        isMaxProjView;
        lastDrawnZSurfs = matlab.graphics.chart.primitive.Surface.empty;
        hBackSurfs = matlab.graphics.chart.primitive.Surface.empty;
        lastDrawnZ = nan;
        
        zSurfs = {};
        currPos = [0 0];
        currFov = 10;
        maxXrg;
        maxYrg;
    end
    
    properties (SetAccess = private, Hidden, Dependent)
        hFig;
    end
    
    properties (Constant, Hidden)
        graphics2014b = most.idioms.graphics2014b(); % cache this for performance
    end
    
    
    methods
        function obj = RoiDisplay(hSI,parent,chan)
            if nargin < 1 || isempty(parent)
                parent = figure();
            end
            
            obj.hSI = hSI;
            rg = hSI.hRoiManager.refAngularRange;
            obj.maxXrg = [-.5 .5] * rg(1);
            obj.maxYrg = [-.5 .5] * rg(2);
            
            obj.hUicMain = handle(uicontainer('Parent',parent,'DeleteFcn',@(src,evt)most.idioms.safeDeleteObj(obj)));
            obj.parent = parent;
            obj.chan = chan;
            
            obj.hSurfContextMenu = handle(uicontextmenu('Parent',obj.hFig,'Callback',@obj.contextMenuOpen));
                uimenu('Parent',obj.hSurfContextMenu,'Label','Autoscale Contrast','Callback',@(src,evt)obj.surfContextMenuCallback(@obj.autoRoiContrast));
                uimenu('Parent',obj.hSurfContextMenu,'Label','Histogram','Callback',@(src,evt)obj.surfContextMenuCallback(@obj.showSurfHistogram));
                uimenu('Parent',obj.hSurfContextMenu,'Label','Image Stats','Callback',@(src,evt)obj.surfContextMenuCallback(@obj.surfImageStats));
                uimenu('Parent',obj.hSurfContextMenu,'Label','Pixel Value','Callback',@(src,evt)obj.surfContextMenuCallback(@obj.pixelValue));
                uimenu('Parent',obj.hSurfContextMenu,'Separator','on','Label','Reset View','Callback',@(src,evt)obj.surfContextMenuCallback(@obj.resetview));
                uimenu('Parent',obj.hSurfContextMenu,'Label','Center Stage','Tag','uiMenuCenterStage','Callback',@(src,evt)obj.surfContextMenuCallback(@obj.centerStage),'enable','off');
                uimenu('Parent',obj.hSurfContextMenu,'Label','Measure','Tag','uiMenuMeasure','Callback',@(src,evt)obj.surfContextMenuCallback(@obj.measure));
                uimenu('Parent',obj.hSurfContextMenu,'Label','Hide Cursor / Measurement','Callback',@(src,evt)obj.surfContextMenuCallback(@obj.hideCursor));
                uimenu('Parent',obj.hSurfContextMenu,'Label','Show Crosshair','Callback',@(src,evt)obj.surfContextMenuCallback(@obj.toggleCrosshair));
                uimenu('Parent',obj.hSurfContextMenu,'Separator','on','Label','Assign image data in base','Callback',@(src,evt)obj.surfContextMenuCallback(@obj.imageAssigninBase));
                uimenu('Parent',obj.hSurfContextMenu,'Label','Save to Tiff','Callback',@(src,evt)obj.surfContextMenuCallback(@obj.saveSurfToTiff));
                uimenu('Parent',obj.hSurfContextMenu,'Label','Add to Scanfield Display window','Callback',@(src,evt)obj.surfContextMenuCallback(@obj.addToSfDisp),'enable','off');
                uimenu('Parent',obj.hSurfContextMenu,'Separator','on','Label','Set roi as motion correction ref','Callback',@(src,evt)obj.surfContextMenuCallback(@obj.setMotionReferenceThisRoi),'enable','off');
                uimenu('Parent',obj.hSurfContextMenu,'Label','Add roi as motion correction ref','Callback',@(src,evt)obj.surfContextMenuCallback(@obj.addMotionReferenceThisRoi),'enable','off');
                uimenu('Parent',obj.hSurfContextMenu,'Label','Set roi slice as motion correction ref','Callback',@(src,evt)obj.surfContextMenuCallback(@obj.setMotionReferenceThisRoiSlice),'enable','off');
                uimenu('Parent',obj.hSurfContextMenu,'Label','Enable motion correction','Tag','uiMenuMotionCorrectionEnabled','Callback',@(src,evt)obj.toggleEnableMotionCorrection,'enable','off');
                
            obj.hAxesContextMenu = handle(uicontextmenu('Parent',obj.hFig,'Callback',@obj.contextMenuOpen));
                uimenu('Parent',obj.hAxesContextMenu,'Label','Autoscale Contrast','Callback',@(src,evt)obj.autoChanContrast());
                uimenu('Parent',obj.hAxesContextMenu,'Label','Show Volume Histogram','Callback',@(src,evt)obj.showVolumeHistogram());
                uimenu('Parent',obj.hAxesContextMenu,'Label','Volume Stats','Callback',@(src,evt)obj.volumeImageStats());
                uimenu('Parent',obj.hAxesContextMenu,'Separator','on','Label','Reset View','Callback',@obj.resetview);
                uimenu('Parent',obj.hAxesContextMenu,'Label','Top View','Callback',@(src,evt)obj.resetview('top'));
                uimenu('Parent',obj.hAxesContextMenu,'Label','Show Crosshair','Callback',@obj.toggleCrosshair);
                uimenu('Parent',obj.hAxesContextMenu,'Label','Hide Cursor / Measurement','Callback',@obj.hideCursor);
                hAnMenu = uimenu('Parent',obj.hAxesContextMenu,'Label','Annotation','enable','off');
                    uimenu('Parent',hAnMenu,'Label','Clear Annotations','Callback',@obj.clearAnnotations,'enable','off');
                    uimenu('Parent',hAnMenu,'Label','Draw Oval','Callback',@(varargin)obj.startAnnotation('oval'),'enable','off');
                    uimenu('Parent',hAnMenu,'Label','Draw Rectangle','Callback',@(varargin)obj.startAnnotation('rectangle'),'enable','off');
                    uimenu('Parent',hAnMenu,'Label','Draw Line','Callback',@(varargin)obj.startAnnotation('line'),'enable','off');
                uimenu('Parent',obj.hAxesContextMenu,'Separator','on','Label','Set vol as motion correction ref','Callback',@(src,evt)obj.setMotionReferenceThisVolume,'enable','off');
                uimenu('Parent',obj.hAxesContextMenu,'Separator','on','Label','Enable motion correction','Tag','uiMenuMotionCorrectionEnabled','Callback',@(src,evt)obj.toggleEnableMotionCorrection,'enable','off');
                
            obj.hAxes = handle(obj.prepareAxes('Parent',obj.hUicMain,'ButtonDownFcn',@obj.selectdrag,'UIContextMenu',obj.hAxesContextMenu));
            obj.hMotionContainer = handle(hgtransform('Parent',obj.hAxes,'Matrix',obj.motionMatrix));
            
            obj.hUicMain.SizeChangedFcn = @obj.reSize;
            
            obj.hCursor = handle(line('Parent',obj.hMotionContainer,'Visible','off','LineStyle','none',...
                'Marker','+','MarkerSize',10,'MarkerEdgeColor','r','LineWidth',1,'HitTest','off'));
            
            
            measureColor = [1 0 1];
            measureAlpha = 0.2;
            obj.hMeasureGroup = handle(hggroup('Parent',obj.hAxes,'Hittest','off','Visible','off'));
            obj.hPatchMeasure = handle(patch('Parent',obj.hMeasureGroup,'HitTest','off','PickableParts','none','LineStyle','none','FaceColor',measureColor,'FaceAlpha',measureAlpha,'Marker','none','PickableParts','none'));
            obj.hLineMeasure = handle(line('Parent',obj.hMeasureGroup,'HitTest','off','PickableParts','none','MarkerSize',10,'LineWidth',2,'MarkerEdgeColor',measureColor,'Color',measureColor,'Marker','o'));
            obj.hTextMeasure = handle(text('Parent',obj.hMeasureGroup,'HitTest','off','PickableParts','none','String','','VerticalAlignment','bottom','Color',measureColor,'FontWeight','bold'));
            
            obj.hOnTopGroup = handle(hgtransform('Parent',obj.hAxes,'Hittest','off'));
            if obj.graphics2014b
                obj.hOnTopGroup.PickableParts = 'none';
            end
            
            obj.hCrossHair = handle(hggroup('Parent',obj.hOnTopGroup,'Visible','off','HitTest','off'));
            line('XData',20*obj.maxXrg,'YData',zeros(1,2),...
                'Parent',obj.hCrossHair,'Color','white','LineWidth',1);
            line('XData',zeros(1,2),'YData',20*obj.maxYrg,...
                'Parent',obj.hCrossHair,'Color','white','LineWidth',1);
            obj.showCrosshair = obj.showCrosshair; % Set Visibility of cross hair according to obj.showCrosshair
            
            obj.hInverseMotionContainer = handle(hgtransform('Parent',obj.hAxes,'Matrix',eye(4)));
            obj.hHighlightGroup = handle(hggroup('Parent',obj.hInverseMotionContainer,'Visible','off','Hittest','off'));
            if obj.graphics2014b
                obj.hHighlightGroup.PickableParts = 'none';
            end
            
            
            obj.axesSelectedByUser(obj.hAxes);
            obj.CLim = obj.CLim;
        end
        
        function delete(obj)
            most.idioms.safeDeleteObj(obj.hSurfContextMenu);
            most.idioms.safeDeleteObj(obj.hAxesContextMenu);
            most.idioms.safeDeleteObj(obj.hUicMain);
            most.idioms.safeDeleteObj(obj.hAxes);
            most.idioms.safeDeleteObj(obj.roiMap);
            most.idioms.safeDeleteObj(obj.labelMap);
            most.idioms.safeDeleteObj(obj.hCrossHair);
            most.idioms.safeDeleteObj(obj.hUicMain);
            most.idioms.safeDeleteObj(obj.hUicFlowMain);
            most.idioms.safeDeleteObj(obj.hLiveHistograms);
        end
        
        function initialize(obj,zs,displayMode,specialView)
            obj.is3dview = strcmpi('3d',displayMode);
            
            obj.isMaxProjView = strcmpi(specialView,'max');
            obj.isCurrentView = obj.isMaxProjView | strcmpi(specialView,'current');
            obj.isTiledView = strcmpi(specialView,'tiled');

            obj.hAxes.PlotBoxAspectRatio = [1 1 1];
            
            obj.zs = zs;
            obj.zSurfs = repmat({matlab.graphics.primitive.Surface.empty},numel(zs),1);
            
            if isempty(obj.zs) || any(isnan(obj.zs))
                obj.setCrossHairZ(0-1e-6);
            else
                obj.setCrossHairZ(min(obj.zs)-1e-6);
            end
            
            delete(obj.hSurfs); % clear all existing surfaces in axis

            if obj.graphics2014b
                obj.hSurfs = gobjects(1,0);
                obj.hMainSurfs = gobjects(1,0);
            else
                obj.hSurfs = [];
                obj.hMainSurfs = [];
            end
            obj.roiMap = containers.Map('KeyType','uint64','ValueType','any');
            obj.labelMap = containers.Map('KeyType','uint64','ValueType','any');
            
            xs = zeros(2,2,0);
            ys = zeros(2,2,0);
            roi = obj.hSI.hRoiManager.currentRoiGroup.rois;
            scanField = roi.scanfields;
            if ~isempty(roi) && ~isempty(scanField)
                roiUuiduint64 = roi.uuiduint64;
                zSurfMap = containers.Map('KeyType','double','ValueType','any');
                zLabelMap = containers.Map('KeyType','double','ValueType','any');
                
                tmpzs = obj.zs;
                if any(isnan(tmpzs))
                    assert(numel(tmpzs) == 1, 'A roi display with an indeterminate z plane can only have one z level.')
                    tmpzs = 0;
                end
                
                
                %Surface handles for Roi
                for idx = 1:length(tmpzs)
                    z = tmpzs(idx);
                                   
                    
                    [imcoordsX,imcoordsY,imcoordsZ] = meshgrid(0:1,0:1,z);

                    if obj.transposeImage
                        imcoordsX = imcoordsX';
                        imcoordsY = imcoordsY';
                    end
                    
                    [imcoordsX,imcoordsY] = scanField.transform(imcoordsX,imcoordsY);
                    
                    %%% this code does not work with rotated ROIs
                    %imcoordsX = fixZero(imcoordsX')';
                    %imcoordsY = fixZero(imcoordsY);
                    
                    xs(:,:,end+1) = imcoordsX;
                    ys(:,:,end+1) = imcoordsY;

                    imData = NaN; %Unused if mroi disabled

                    surfs = struct();
                    [surfs.hSurf,centerpoint] = prepareSurface(imcoordsX,imcoordsY,imcoordsZ,imData,'Parent',obj.hMotionContainer,'EdgeColor',obj.hSI.hDisplay.roiDisplayEdgeColor,'EdgeAlpha',obj.hSI.hDisplay.roiDisplayEdgeAlpha,'Visible',obj.tfMap(~obj.isCurrentView));
                    set(surfs.hSurf,'HitTest','on','ButtonDownFcn',@(src,evt)obj.clickedsurf(centerpoint,src,evt));
                    
                    
                    %add roi and z info
                    set(surfs.hSurf,'UserData',struct('roi',roi,'scanField',scanField,'z',z,'origPos',struct('XData',surfs.hSurf.XData,'YData',surfs.hSurf.YData),'offset',[0 0]));
                    
                    obj.zSurfs{z==zs}(end+1) = surfs.hSurf;
                    
                    obj.hSurfs = [obj.hSurfs surfs.hSurf];
                    obj.hMainSurfs = [obj.hMainSurfs surfs.hSurf];
                    

                    zSurfMap(z) = surfs;

                    %Roi Names
%                         hLabel = text(imcoordsX(1)+0.01,imcoordsY(1),imcoordsZ(1),roi.name,...
%                             'Parent',obj.hAxes,...
%                             'FontWeight','normal',...
%                             'Color','Yellow',...
%                             'FontSize',7,...
%                             'HorizontalAlignment','Left',...
%                             'VerticalAlignment','Top');
%                         zLabelMap(z) = hLabel;

                end
                obj.roiMap(roiUuiduint64) = zSurfMap;
                obj.labelMap(roiUuiduint64) = zLabelMap;
            end
            
            if strcmpi(displayMode,'no_transform') && ~isempty(xs)
                obj.maxXrg = [min(xs(:)),max(xs(:))];
                obj.maxYrg = [min(ys(:)),max(ys(:))];
            end
            
            obj.resetview();
            obj.CLim = obj.CLim;
            
            
            % nested functions
%             function lims = fixZero(lims)
%                 if all(lims(:,1) == lims(:,2))
%                     lims(:,1) = lims(:,1) - obj.viewAngularRange * 0.01;
%                     lims(:,2) = lims(:,2) + obj.viewAngularRange * 0.01;
%                 end
%             end
            
            function [hSurf,centerpoint] = prepareSurface(imcoordsX,imcoordsY,imcoordsZ,imData,varargin)
                hSurf = handle(surface(imcoordsX,imcoordsY,imcoordsZ,imData,...
                    'FaceColor','texturemap',...
                    'CDataMapping','scaled',...
                    'FaceLighting','none',...
                    'UIContextMenu',obj.hSurfContextMenu,...
                    varargin{:}));
                
                centerpoint = [(imcoordsX(1,1) + imcoordsX(2,2))/2,...
                              (imcoordsY(1,1) + imcoordsY(2,2))/2,...
                              (imcoordsZ(1,1) + imcoordsZ(2,2))/2];
            end
        end
        
        function reSize(obj,varargin)
            if ~obj.is3dview
                obj.hAxes.Parent.Units = 'pixels';
                s = obj.hAxes.Parent.Position([3 4]);
                obj.hAxes.Parent.Units = 'normalized';
                
                windowAsp = s(1)/s(2);
                canvasAsp = diff(obj.maxXrg) / diff(obj.maxYrg);
                
                if obj.isTiledView
                    % determine best tiling based on aspect ratio of FOV
                    % and aspect ratio of window
                    N = numel(obj.zs);
                    cols = max(min(round((N*windowAsp/canvasAsp)^.5),N),1);
                    rows = ceil(N/cols);
                    
                    canvasAsp = canvasAsp * cols / rows;
                else
                    rows = 1;
                    cols = 1;
                end
                
                margin = 0.05;
                
                if windowAsp > canvasAsp
                    marginY = margin*diff(obj.maxYrg);
                    yrg = [obj.maxYrg(1) (obj.maxYrg(2) + (diff(obj.maxYrg)+marginY) * (rows-1))] + (rows>1)*marginY*[-.5 .5];
                    xrg = [obj.maxXrg(1) (obj.maxXrg(1) + diff(yrg) * windowAsp)];
                    
                    o = diff(xrg)/cols - diff(obj.maxXrg);
                    xrg = xrg - o/2;
                else
                    marginX = margin*diff(obj.maxXrg);
                    xrg = [obj.maxXrg(1) (obj.maxXrg(2) + (diff(obj.maxXrg)+marginX) * (cols-1))] + (cols>1)*marginX*[-.5 .5];
                    yrg = [obj.maxYrg(1) (obj.maxYrg(1) + diff(xrg) / windowAsp)];
                    
                    o = diff(yrg)/rows - diff(obj.maxYrg);
                    yrg = yrg - o/2;
                end
                
                obj.hAxes.XLim = xrg;
                obj.hAxes.YLim = yrg;
                obj.hAxes.Color = .94*ones(1,3);
                obj.hAxes.XColor = 'none';
                obj.hAxes.YColor = 'none';
                
                if obj.isTiledView %&& false
                    xsz = diff(xrg) / cols;
                    ysz = diff(yrg) / rows;
                    
                    % move surfaces
                    for i = 1:numel(obj.zs)
                        x = mod(i-1,cols);
                        y = floor((i-1)/cols);
                        
                        xoff = xsz * x;
                        yoff = ysz * y;
                        
                        for j = 1:numel(obj.zSurfs{i})
                            s = obj.zSurfs{i}(j);
                            p = s.UserData.origPos;
                            s.XData = p.XData + xoff;
                            s.YData = p.YData + yoff;
                            s.UserData.offset = [xoff yoff];
                        end
                        
                        enoughBackSurfs(i);
                        obj.hBackSurfs(i).XData = repmat(obj.maxXrg + xoff,2,1);
                        obj.hBackSurfs(i).YData = repmat(obj.maxYrg' + yoff,1,2);
                        obj.hBackSurfs(i).ZData = (max(obj.zs)+1)*ones(2);
                    end
                else
                    enoughBackSurfs(1);
                    obj.hBackSurfs(1).XData = repmat(obj.maxXrg,2,1);
                    obj.hBackSurfs(1).YData = repmat(obj.maxYrg',1,2);
                    obj.hBackSurfs(1).ZData = (max(obj.zs)+1)*ones(2);
                end
                
                obj.scrollWheelFcn(obj.hAxes,[],struct('VerticalScrollCount',0));
            end
            
            function enoughBackSurfs(N)
                while numel(obj.hBackSurfs) < N
                    obj.hBackSurfs(end+1) = surface(nan,nan,nan,'parent',obj.hAxes,'facecolor','k','edgecolor','k','hittest','off');
                end
            end
        end
        
        function resetview(obj,option,varargin)
            if nargin < 2 || ~ischar(option)
                option = '';
            end
            
            obj.reSize();
            obj.hAxes.CameraViewAngleMode = 'auto';
            
            if obj.hSI.hDisplay.needsReset
                % user initiated reset; do not restore the camera props
                obj.hSI.hDisplay.resetActiveDisplayFigs(false);
            elseif isempty(obj.zs) || length(obj.zs) == 1 || any(isnan(obj.zs))
                if isempty(obj.zs) || any(isnan(obj.zs))
                    z = 0;
                else
                    z = obj.zs(1);
                end
                
                camtarget(obj.hAxes,[mean(obj.hAxes.XLim),mean(obj.hAxes.YLim),z]);
                obj.hOnTopGroup.Matrix = makehgtform('translate',[0 0 z-1e-6]);
                obj.hAxes.ZLim = [z-2 z+2];
                drawnow(); % order of operation is important here: first move the axis view to center, then set view angle
                view(obj.hAxes,0,-90);
            else
                if obj.isCurrentView || obj.isTiledView || strcmp(option,'top')
                    camtarget(obj.hAxes,[mean(obj.hAxes.XLim),mean(obj.hAxes.YLim),min(obj.zs)]);
                    drawnow(); % order of operation is important here: first move the axis view to center, then set view angle
                    view(obj.hAxes,0,-90);
                else
                    camtarget(obj.hAxes,[mean(obj.hAxes.XLim),mean(obj.hAxes.YLim),(max(obj.zs)-min(obj.zs))/2]);
                    drawnow(); % order of operation is important here: first move the axis view to center, then set view angle
                    view(obj.hAxes,-135,-45);
                    camup(obj.hAxes,[0,0,-1]);
                end
                obj.hOnTopGroup.Matrix = makehgtform('translate',[0 0 min(obj.zs)-1e-6]);
                obj.hAxes.ZLim = [min(obj.zs)-2 max(obj.zs)+2];
            end
        end
        
        
        
        function drawRoiData(obj,roiDatas)
            if isempty(roiDatas)
                return
            end
                        
            if ~iscell(roiDatas)
                roiDatas = {roiDatas};
            end
            
            for i = 1:numel(roiDatas)
                roiData = roiDatas{i};
                if roiData.hRoi.display && any(roiData.channels == obj.chan)
                    try % this try catch statement is faster than using obj.roiMap.isKey
                        zSurfMap = obj.roiMap(roiData.hRoi.uuiduint64);
                    catch
%                         most.mimics.warning('roiMap value for this roi ID is not valid.');
                        continue
                    end
                    
                    %zLabelMap = obj.labelMap(roiData.hRoi.uuid);
                    for zIdx = 1:numel(roiData.zs)
                        if isnan(obj.zs)
                            z = 0;
                        else
                            z = roiData.zs(zIdx);
                        end
                        
                        try % this try catch statement is faster than using obj.roiMap.isKey
                            surfs = zSurfMap(z); % get the right surface handle
                            
                            if obj.isCurrentView
                                if obj.lastDrawnZ ~= z && ~isempty(obj.lastDrawnZSurfs)
                                    set(obj.lastDrawnZSurfs, 'Visible', 'off');
                                    obj.lastDrawnZSurfs = matlab.graphics.chart.primitive.Surface.empty;
                                end
                                
                                obj.lastDrawnZ = z;
                                obj.lastDrawnZSurfs(end+1) = surfs.hSurf;
                                obj.lastDrawnZSurfs(end).Visible = 'on';
                            end
                        catch
%                             most.mimics.warning('roiData has an encoded z value of %.2f, but this is not a display key in RoiDisplay. Roidata ID: %s\n', z, roiData.hRoi.uuid(1:8));
                            continue
                        end
                        
%                             hLabel = zLabelMap(z); % get the handle to the ROI label.
                        
                        imData = roiData.imageData{roiData.channels == obj.chan}{zIdx};
                        
                        
                        surfSetCdata(surfs.hSurf,imData);
                        
                        
                        if isfield(surfs,'hHist')
                            if ~isempty(surfs.hHist) && isvalid(surfs.hHist)
                                if obj.dataMultiplier ~= 1;
                                    imData = imData(:)./cast(obj.dataMultiplier,'like',imData);
                                end
                                surfs.hHist.updateData(imData);
                            else
                                surfs = rmfield(surfs,'hHist');
                                zSurfMap(z) = surfs;
                            end
                        end

                        if obj.debugEnabled
                            %display debug information on ROI
%                             labelString = [ num2str(roiData.zs) ' ' ...
%                                             num2str(roiData.frameTimestamp) ' ' ...
%                                             num2str(roiData.frameNumberAcq) ' ' ...
%                                             num2str(roiData.frameNumberAcqMode) ];
%                                 set(hLabel,'String',labelString);
                        end
                    end
                end
            end
            
            function surfSetCdata(hSurf,cData)
                if obj.graphics2014b
                    hSurf.CData = cData;
                else
                    if isa(cData,'uint8')
                        hSurf.CData = cData;
                    else
                        cDataDbl = double(cData);
                        hSurf.CData = cDataDbl;
                    end
                end
            end
            
            function surfSetAlphaData(hSurf,alphaData)
                if size(alphaData,3) > 1
                    % RGB merge display cannot be used with transparency
                    % deactivate FaceAlpha by seting surf to opaque
%                     hSurf.FaceAlpha = 1;
%                     return
                    alphaData = max(alphaData,[],3);
                end
                
                if obj.graphics2014b
                    hSurf.AlphaData = alphaData;
                else
                    if isa(alphaData,'uint8')
                        % todo: handle merge!
                        hSurf.AlphaData = alphaData;
                    else
                        cDataDbl = double(alphaData);
                        hSurf.AlphaData = cDataDbl;
                    end
                end
            end
        end
        
        
        function hAx = prepareAxes(obj,varargin)
            hAx = handle(axes(...
                'Box','off',...
                'NextPlot','add',...
                'XLimMode','manual',...
                'YLimMode','manual',...
                'ZLimMode','manual',...
                'DataAspectRatio',[1 1 1],...
                'XLim',obj.maxXrg,...
                'YLim',obj.maxYrg,...
                'ZLim',[-Inf Inf],...
                'Color','black',...
                'Position',[0 0 1 1],...
                'XTick',[],'YTick',[],'ZTick',[],...
                'XTickLabelMode','manual','YTickLabelMode','manual','ZTickLabelMode','manual',...
                'XTickLabel',[],'YTickLabel',[],'ZTickLabel',[],...
                'CLim',[0 1],...
                'Projection','orthographic',...
                varargin{:}));
        end
    end
    
    methods        
        function val = get.hFig(obj)
            val = ancestor(obj.hUicMain,'figure');
        end
        
        function set.parent(obj,val)
           set(obj.hUicMain,'Parent',val);
        end
        
        function set.motionMatrix(obj,val)            
            if size(val,1) == 3 && size(val,2) == 3
                val = scanimage.mroi.util.affine2Dto3D(val);
            end
            
            if ~isequal(val,obj.motionMatrix)
                if obj.stabilizeDisplay
                    obj.hMotionContainer.Matrix = val;
                    obj.hMotionContainerOnTop.Matrix = val;
                    obj.hMotionContainerProjectionX.Matrix = val;
                    obj.hMotionContainerProjectionY.Matrix = val;
                else
                    obj.hInverseMotionContainer.Matrix = inv(val);
                end
                obj.motionMatrix = val;
            end
        end
        
        function set.stabilizeDisplay(obj,val)
            oldVal = obj.stabilizeDisplay;
            obj.stabilizeDisplay = val;
            
            if val~=oldVal
                % first reset all containers
                obj.hMotionContainer.Matrix = eye(4);
                obj.hMotionContainerOnTop.Matrix = eye(4);
                obj.hMotionContainerProjectionX.Matrix = eye(4);
                obj.hMotionContainerProjectionY.Matrix = eye(4);
                obj.hInverseMotionContainer.Matrix = eye(4);
                
                % then apply motion matrix
                motionMatrix_ = obj.motionMatrix;
                obj.motionMatrix = eye(4);
                obj.motionMatrix = motionMatrix_; % force update by changing matrix
            end
        end
        

        function resetScanFields(obj)
            % sets all scanFields back to black            
            for hSurf = obj.hSurfs
                hSurf.AlphaData = NaN;
                hSurf.CData = NaN;
            end
        end
        
        function setCrossHairZ(obj,z)
           hLines = obj.hCrossHair.Children;
           for hLine = hLines(:)'
               zData = hLine.ZData;
               hLine.ZData = ones(size(zData)).*z;
           end
        end
    end
    
    methods
        
        function set.dataMultiplier(obj,val)
            obj.dataMultiplier = double(val);
            obj.CLim = obj.CLim;
        end
        
        function set.CLim(obj,val) 
            correctedVal = double(val) .* obj.dataMultiplier;
            obj.hAxes.CLim = correctedVal;
            
            
            obj.CLim = val;
            
            mask = false(length(obj.hLiveHistograms),1);
            for idx = 1:length(obj.hLiveHistograms)
                hHist = obj.hLiveHistograms(idx);
                if isvalid(hHist)
                    mask(idx) = true;
                    hHist.lut = obj.CLim;
                end
            end
            % delete invalid hHist
            obj.hLiveHistograms(~mask) = [];
        end
        
        function set.showCrosshair(obj,val)
            if val
                visibleOnOff = 'on';
            else
                visibleOnOff = 'off';
            end
            
            if ~isempty(obj.hCrossHair) && ishandle(obj.hCrossHair)
                obj.hCrossHair.Visible = visibleOnOff;
				if ~obj.graphics2014b
                    % workaround for Matlab<2014b to hide crosshair
                    set(obj.hCrossHair.Children,'Visible',visibleOnOff);
                end
                
                % check / uncheck menu item
                mnu = findall(obj.hSurfContextMenu,'Label','Show Crosshair');
                mnu = [mnu findall(obj.hAxesContextMenu,'Label','Show Crosshair')];
                set(mnu,'Checked',visibleOnOff);
            end
            
            obj.showCrosshair = val;
        end
    end
    
    %% 3d mouse navigation functions 
    methods
        function axesSelectedByUser(obj,hAx)
            obj.hFig.WindowScrollWheelFcn = @(src,evt)obj.scrollWheelFcn(hAx,src,evt);
        end
        
        function scrollWheelFcn(obj,hAx,~,evt)
            zoomSpeedFactor = 1.1;
            cAngle = hAx.CameraViewAngle;
            scroll = zoomSpeedFactor ^ double(evt.VerticalScrollCount);
            cAngle = cAngle * scroll;
            
            if ~obj.is3dview
                % limit max angle
                maxViewOPct = .01;
                maxViewPct = 1 + maxViewOPct;
                maxCamAngle = atand(min(diff(hAx.XLim),diff(hAx.YLim))*maxViewPct / abs(hAx.CameraPosition(3) - hAx.CameraTarget(3)));
                cAngle = min(cAngle, maxCamAngle);
                
            end
            
            cp = hAx.CurrentPoint([1 3]);
            hAx.CameraViewAngle = cAngle;
            
            if ~obj.is3dview
                % dolly to keep mouse over same point
                dff = cp - hAx.CurrentPoint([1 3]);
                camdolly(obj.hAxes,dff(1),dff(2),0,'movetarget','data');
                
                % dolly to keep view within range
                viewportHalfSize = abs(abs(hAx.CameraPosition(3) - hAx.CameraTarget(3))*tand(obj.hAxes.CameraViewAngle)) / 2;
                camPos =  obj.hAxes.CameraPosition([1 2]);
                
                % the calculated viewport size applies to the smaller one when window is not square
                lims = [obj.hAxes.XLim; obj.hAxes.YLim] + maxViewOPct * [-.5 .5; -.5 .5] .* repmat([diff(obj.hAxes.XLim); diff(obj.hAxes.YLim)],1,2);
                primAxis = 2 - (diff(lims(2,:)) > diff(lims(1,:)));
                camPos(primAxis) = min(max(camPos(primAxis),lims(primAxis,1) + viewportHalfSize), lims(primAxis,2) - viewportHalfSize);
                
                secAxis = 3 - primAxis;
                viewportHalfSize = viewportHalfSize * diff(lims(secAxis,:)) / diff(lims(primAxis,:));
                camPos(secAxis) = min(max(camPos(secAxis),lims(secAxis,1) + viewportHalfSize), lims(secAxis,2) - viewportHalfSize);
                
                obj.hAxes.CameraPosition([1 2]) = camPos;
                obj.hAxes.CameraTarget([1 2]) = camPos([1 2]);
            end
        end
        
        function coerceView(obj)
            obj.scrollWheelFcn(obj.hAxes,[],struct('VerticalScrollCount',0));
        end
        
        function pt = getPoint(obj)
            pt = hgconvertunits(obj.hFig,[0 0 obj.hFig.CurrentPoint],...
				obj.hFig.Units,'pixels',0);
            pt = pt(3:4);
        end
        
        function clickedsurf(obj,surfcenter,src,evt)
            hAx = ancestor(src,'axes');
            
            obj.lastClickedSurfPoint = evt.IntersectionPoint;
            
            switch obj.hFig.SelectionType
                case 'open'   % double click
                    obj.resetview();
                otherwise
                    modKey = obj.hFig.CurrentModifier;
                    if iscellstr(modKey) && isscalar(modKey) && strcmpi(modKey{1},'control')
                    else
                        obj.selectdrag(src,evt);
                    end
            end
            obj.axesSelectedByUser(hAx);
        end
        
        function selectdrag(obj,src,evt)
            obj.axesSelectedByUser(obj.hAxes);

           switch obj.hFig.SelectionType;
               case 'normal' % left click
                   obj.startdrag(@obj.dolly);
               case 'alt'    % right click
                   % reserved for context menu
               case 'open'   % double click
               case 'extend' % scroll wheel click
                   obj.startdrag(@obj.orbit);
           end
        end
        
        function startdrag(obj,dragtype)
            pt = obj.getPoint();
            obj.dragdata = struct(...
                'figStartPoint',pt,...
                'figLastPoint',pt,...
                'WindowButtonMotionFcn',obj.hFig.WindowButtonMotionFcn,...
                'WindowButtonUpFcn',obj.hFig.WindowButtonUpFcn);
            obj.hFig.WindowButtonMotionFcn = @(src,evt)obj.motion(dragtype,src,evt);
            obj.hFig.WindowButtonUpFcn = @obj.stopdrag;
            waitfor(obj.hFig,'WindowButtonMotionFcn',[]);
        end
        
        function motion(obj,dragtype,~,~)
            pt = obj.getPoint();
            deltaPix = pt - obj.dragdata.figLastPoint;
            obj.dragdata.figLastPoint = pt;
            dragtype(deltaPix);
        end
        
        function stopdrag(obj,src,~)
            src.WindowButtonMotionFcn = obj.dragdata.WindowButtonMotionFcn;
            src.WindowButtonUpFcn = obj.dragdata.WindowButtonUpFcn;
            obj.dragdata = [];
        end
        
        function pan(obj,deltaPix)
            panxy = -deltaPix*camva(obj.hAxes)/500;
            campan(obj.hAxes,panxy(1),panxy(2),'camera',[0 0 1]);
        end
        
        function orbit(obj,deltaPix)
            if obj.is3dview
                camorbit(obj.hAxes,deltaPix(1),-deltaPix(2),'data',[0 0 1])
            end
        end
        
        function dolly(obj,deltaPix)
            obj.hAxes.CameraViewAngleMode = 'manual';
            camdolly(obj.hAxes,-deltaPix(1),-deltaPix(2),0,'movetarget','pixels');
            obj.coerceView();
        end        
    end
    
    %% Surf UI Context Menu Callbacks
    methods
        function contextMenuOpen(obj,src,evt)
        end
        
        function surfContextMenuCallback(obj,fcn)
            hSurf = gco(obj.hFig);
            if ~isempty(hSurf) && strcmpi(hSurf.Type,'surface')
                fcn(hSurf);
            end
            
            if isvalid(obj) % when axes is reset by fcn, obj might get deleted
                obj.axesSelectedByUser(obj.hAxes);
            end
        end
        
        
        function showSurfHistogram(obj,hSurf)
            userData = hSurf.UserData;
            roi = userData.roi;
            z   = userData.z;
            data = obj.getSurfCData(hSurf);
            zSurfMap = obj.roiMap(roi.uuiduint64);
            surfs = zSurfMap(z); % get the right surface handle 
            surfs.hHist = obj.showHistogram(data,sprintf('Roi %s, Channel %d, z=%f',roi.name,obj.chan,z));
            zSurfMap(z) = surfs;
        end
        
        function showVolumeHistogram(obj)
            data = obj.getVolumeData();
            obj.showHistogram(data,'Volume Histogram Snapshot');
        end
        
        function hHist = showHistogram(obj,data,title)
            if ~isempty(data)                
                hHist = scanimage.mroi.LiveHistogram(obj.hSI);
                hHist.channel = obj.chan;
                hHist.title = title;
                res = obj.hSI.hScan2D.channelsAdcResolution;
                hHist.dataRange = [-(2^(res-1)),2^(res-1)-1];
                hHist.lut = obj.CLim;
                hHist.viewRange = mean(obj.CLim) + [-1.5 1.5].*double(diff(obj.CLim))./2;
                hHist.updateData(data);
                obj.hLiveHistograms = [obj.hLiveHistograms hHist];
            end
        end
        
        
        function measure(obj,hSurf,varargin)
            persistent init
            
            if isempty(varargin)
                mode = 'start';
            else
                mode = varargin{1};
            end
            
            try
                [~,pointWithMotion] = getMouseSurfPixel(obj,hSurf);
                switch mode
                    case 'start'
                        init = struct();
                        init.WindowButtonMotionFcn = obj.hFig.WindowButtonMotionFcn;
                        init.WindowButtonDownFcn = obj.hFig.WindowButtonDownFcn;
                        init.startPoint = pointWithMotion;
                        
                        
                        init.R_motor = [];
                        init.R_angle = [];
                        
                        obj.hFig.WindowButtonMotionFcn = @(src,evt)obj.measure(hSurf,'update');
                        obj.hFig.WindowButtonDownFcn = @(src,evt)obj.measure(hSurf,'stop');
                    case 'update'
                        p1 = init.startPoint;
                        p2 = pointWithMotion;
                        
                        zOffset = -1e-3;
                        
                        r = norm(p2-p1);
                        rmotor = [];
                        
                            obj.hPatchMeasure.Visible = 'off';
                        
                        obj.hLineMeasure.XData = [p1(1),p2(1)];
                        obj.hLineMeasure.YData = [p1(2),p2(2)];
                        obj.hLineMeasure.ZData = [p1(3),p2(3)] + zOffset;
                        
                        if isempty(rmotor)
                            text = sprintf('%.3f°\n',r);
                        else
                            text = sprintf('%.3f°\n%.3fum\n',r,rmotor);
                        end
                        obj.hTextMeasure.Position = p2 + [0 0 zOffset];
                        obj.hTextMeasure.String = text;
                        
                        init.R_motor = rmotor;
                        init.R_angle = r;
                        
                        obj.hMeasureGroup.Visible = 'on';
                    case 'stop'                        
                        measurement = struct();
                        measurement.R_angle = init.R_angle;
                        measurement.R_motor = init.R_motor;
                        
                        assignin('base','measurement',measurement);
                        evalin('base','measurement');
                        
                        obj.measure(hSurf,'abort');
                    case 'abort'
                        obj.hFig.WindowButtonMotionFcn = init.WindowButtonMotionFcn;
                        obj.hFig.WindowButtonDownFcn = init.WindowButtonDownFcn;
                        init.WindowButtonMotionFcn = [];
                        init.WindowButtonDownFcn = [];                        
                    otherwise
                        assert(false);
                end
            catch ME
                if ~strcmpi(mode,'abort') % avoid recursion
                    obj.measure(hSurf,'abort');
                end
                rethrow(ME);
            end            
        end
        
        function pixelValue(obj,hSurf)            
            [actualPointXYZ,pointXYZWithMotion,pixelXY,pixelVal,axesPointXYZ] = obj.getClickedSurfPixel(hSurf);

            if ~isempty(actualPointXYZ) && ~isempty(pixelXY) && ~isempty(pixelVal)      
                s = struct();
                s.pixelXY = pixelXY;
                s.pointXYZ = actualPointXYZ(:)';
                s.pointXYZWithMotion = pointXYZWithMotion(:)';
                s.value = pixelVal(:)';
                
            
                assignin('base','Pixel',s);
                evalin('base','Pixel');
                
                obj.hCursor.Parent = ancestor(hSurf,'hgtransform');
                obj.hCursor.XData = axesPointXYZ(1);
                obj.hCursor.YData = axesPointXYZ(2);
                obj.hCursor.ZData = axesPointXYZ(3)-1e-6;
                obj.hCursor.Visible = 'on';
            end
        end
        
        function surfImageStats(obj,hSurf)
            data = obj.getSurfCData(hSurf);
            obj.imageStats(data);
        end
        
        function volumeImageStats(obj)
            data = obj.getVolumeData();
            obj.imageStats(data);
        end
        
        function imageStats(obj,data)
            if isempty(data)
                return
            end
            
            data = double(data); % std requires floating point type
            
            s = struct();
            s.mean = mean(data(:));
            s.std = double(std(data(:)));
            s.max = max(data(:));
            s.min = min(data(:));
            s.size = size(data);
            
            assignin('base','ImageStats',s);
            evalin('base','ImageStats');
        end
        
        function hideCursor(obj,varargin)
            obj.hCursor.Visible = 'off';
            obj.hMeasureGroup.Visible = 'off';
        end
        
        function imageAssigninBase(obj,hSurf)            
            assignin('base','ImageData',obj.getSurfCData(hSurf));
            fprintf('Assigned <a href="matlab: figure(''Colormap'',gray());imagesc(ImageData);axis(''image'');fprintf(''>> size(ImageData)\\n'');size(ImageData)">ImageData</a> in workspace ''base''\n');
        end
        
        function saveSurfToTiff(obj,hSurf,filename)
            imgdata = obj.getSurfCData(hSurf);
            
            if nargin < 3 || isempty(filename)
                [filename,pathname] = uiputfile('.tif','Choose path to save tif','image.tif');
                if filename==0;return;end
                filename = fullfile(pathname,filename);
            end
            
            if isa(imgdata,'uint8') && size(imgdata,3)==3
                photometric = Tiff.Photometric.RGB;
                sampleFormat = Tiff.SampleFormat.UInt;
                samplesPerPixel = 3;
                bitsPerSample = 8;
            else
                imgdata = int16(imgdata);
                photometric = Tiff.Photometric.MinIsBlack;
                sampleFormat = Tiff.SampleFormat.Int;
                samplesPerPixel = 1;
                bitsPerSample = 16;
            end
            
            hTif = Tiff(filename,'w');
            try
                tagstruct.ImageLength = size(imgdata,1);
                tagstruct.ImageWidth = size(imgdata,2);
                tagstruct.Photometric = photometric;
                tagstruct.BitsPerSample = bitsPerSample;
                tagstruct.SamplesPerPixel = samplesPerPixel;
                tagstruct.SampleFormat = sampleFormat;
                tagstruct.RowsPerStrip = 16;
                tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
                tagstruct.Software = 'ScanImage';
                hTif.setTag(tagstruct);

                hTif.write(imgdata);
            catch ME
                most.idioms.reportError(ME);
                hTif.close();
            end
            hTif.close();
        end
        
        function autoRoiContrast(obj,hSurf)
            cd = hSurf.CData;
            if ~isempty(obj.chan) && ~isempty(cd)
                obj.hSI.hDisplay.channelAutoScale(obj.chan,single(cd)./obj.dataMultiplier);
            end
        end
        
        function autoChanContrast(obj,~)
            cd = obj.getVolumeData();
            if ~isempty(obj.chan) && ~isempty(cd)
                obj.hSI.hDisplay.channelAutoScale(obj.chan,cd);
            end
        end
        
        function addToSfDisp(obj,hSurf)
            ud = hSurf.UserData;
            rois = obj.hSI.hRoiManager.roiGroupMroi.rois;
            ids = {rois.uuid};
            [tf, idx] = ismember(ud.roi.uuid, ids);
            if tf
                hSDC = obj.hSI.hController{1}.hScanfieldDisplayControls;
                hSDC.addDisp(rois(idx).name, obj.chan, idx, ud.z);
                obj.hSI.hDisplay.enableScanfieldDisplays = true;
            end
        end
        
        function toggleCrosshair(obj,varargin)
            obj.showCrosshair = ~obj.showCrosshair;
        end
        
        function CData = getSurfCData(obj,hSurf,correctTranspose)
            if nargin < 3 || isempty(correctTranspose)
                correctTranspose = true;
            end
            
            CData = hSurf.CData;
            
            if isempty(CData) || (isscalar(CData) && isnan(CData))
                CData = [];
                return
            end
            
            CData = CData ./ cast(obj.dataMultiplier,'like',CData);
            if obj.transposeImage && correctTranspose
                CData = permute(CData,[2,1,3]);
            end
        end
        
        function data = getVolumeData(obj)
           CDatas = arrayfun(@(hSurf)obj.getSurfCData(hSurf),obj.hMainSurfs,'UniformOutput',false);
           CDatas = cellfun(@(CData)CData(:),CDatas,'UniformOutput',false);
           data = vertcat(CDatas{:});
        end
        
        function [pointXYZ,pointWithMotionXYZ,pixelXY,pixelVal,axesPointXYZ] = getClickedSurfPixel(obj,hSurf,coerceToPixel)
            if nargin < 4 || isempty(coerceToPixel)
                coerceToPixel = true;
            end
            
            axesPointXYZ = obj.lastClickedSurfPoint;
            pointXYZ = axesPointXYZ - [hSurf.UserData.offset 0];
            pointWithMotionXYZ = scanimage.mroi.util.xformPoints(pointXYZ,obj.motionMatrix,true);
            
            sf = hSurf.UserData.scanField;
            pixelToRefTransform = scanimage.mroi.util.affine2Dto3D(sf.pixelToRefTransform);
            pixelXY = scanimage.mroi.util.xformPoints(pointWithMotionXYZ,pixelToRefTransform,true);
            pixelXY = pixelXY([1 2]);
            
            if coerceToPixel
                pixelXY = min(max(round(pixelXY),[1 1]),sf.pixelResolutionXY);
                pointWithMotionXYZ = scanimage.mroi.util.xformPoints([pixelXY hSurf.UserData.z],pixelToRefTransform,false);
                pointXYZ = scanimage.mroi.util.xformPoints(pointWithMotionXYZ,obj.motionMatrix,false);
                axesPointXYZ = pointXYZ + [hSurf.UserData.offset 0];
            end
            
            data = obj.getSurfCData(hSurf);
            if coerceToPixel && all(pixelXY>=1) && all(pixelXY<=size(data))
                pixelVal = data(pixelXY(2),pixelXY(1),:);
            else
                pixelVal = [];
            end
        end
        
        function [pointXY,pointWithMotionXY] = getMouseSurfPixel(obj,hSurf)
            
            pointXY = [];
            
            hAx = ancestor(hSurf,'axes');
            r = hAx.CurrentPoint;
            r = scanimage.mroi.util.xformPoints(r,obj.motionMatrix,true)';
            
            xx = hSurf.XData;
            yy = hSurf.YData;
            zz = hSurf.ZData;
            
            if obj.transposeImage
                xx = xx';
                yy = yy';
                zz = zz';
            end
            
            pp = [xx(1,1);yy(1,1);zz(1,1)];
            v1 = [xx(1,1)-xx(2,1);yy(1,1)-yy(2,1);zz(1,1)-zz(2,1)];
            v2 = [xx(1,1)-xx(1,2);yy(1,1)-yy(1,2);zz(1,1)-zz(1,2)];
            n = -cross(v1,v2);
            
            pl = r(:,1);
            l = r(:,1) - r(:,2);
            
            if dot(l,n) ~= 0
                d = dot(pp-pl,n)/dot(l,n);
                pointXY = d*l+pl;
                pointXY = pointXY(:)';
                pointWithMotionXY = scanimage.mroi.util.xformPoints(pointXY,obj.motionMatrix);
            else
                return % surface and view plane are perpendicular
            end
        end
        
    end
end


%--------------------------------------------------------------------------%
% RoiDisplay.m                                                             %
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
