classdef BScope2Controls < most.Gui
    %BSCOPE2GUI Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Hidden)
        hBScope2 = [];
        hLsc = [];
        
        hGGm;
        hGRm;
        hFLm;
        
        ecuPresent = false;
        mcm5000Present = false;
        mcm6000Present = false;
    end
    
    methods
        function obj = BScope2Controls(hModel, hController)
            if nargin < 1
                hModel = [];
            end
            
            if nargin < 2
                hController = [];
            end
            
            obj = obj@most.Gui(hModel, hController, [49.6 14.38], 'characters');
            set(obj.hFig,'Name','BSCOPE2 CONTROLS','Resize','off');
            
            h2 = uipanel(...
                'Parent',obj.hFig,...
                'Units','characters',...
                'Position',[1 7.61538461538463 47.8 6.38461538461539]);
            
            h3 = uipanel(...
                'Parent',obj.hFig,...
                'Units','characters',...
                'Position',[1 3.15384615384615 47.6 4.23076923076923]);
            
            obj.addUiControl(...
                'Parent',obj.hFig,...
                'Units','characters',...
                'HorizontalAlignment','right',...
                'String','Flipper mirror position:',...
                'Style','text',...
                'Position',[1.2 8.3846153846154 22.2 1.07692307692308]);
            
            obj.addUiControl(...
                'Parent',obj.hFig,...
                'Units','characters',...
                'String','PMT',...
                'Style','togglebutton',...
                'Position',[24.2 8.15384615384616 11.6 1.69230769230769],...
                'Tag','pbPmt');
            
            obj.addUiControl(...
                'Parent',obj.hFig,...
                'FontUnits',get(0,'defaultuicontrolFontUnits'),...
                'Units','characters',...
                'String','Camera',...
                'Style','togglebutton',...
                'Position',[35.6 8.15384615384616 11.6 1.69230769230769],...
                'Tag','pbCamera');
            
            obj.addUiControl(...
                'Parent',obj.hFig,...
                'Units','characters',...
                'HorizontalAlignment','right',...
                'String','GG mirror position:',...
                'Style','text',...
                'Position',[3.2 10.2307692307692 20.2 1.07692307692308]);
            
            obj.addUiControl(...
                'Parent',obj.hFig,...
                'FontUnits',get(0,'defaultuicontrolFontUnits'),...
                'Units','characters',...
                'String','In Path',...
                'Style','togglebutton',...
                'Position',[24.2 10 11.6 1.69230769230769],...
                'Tag','pbGG_In');
            
            obj.addUiControl(...
                'Parent',obj.hFig,...
                'Units','characters',...
                'String','Out',...
                'Style','togglebutton',...
                'Position',[35.6 10 11.6 1.69230769230769],...
                'Tag','pbGG_Out');
            
            obj.addUiControl(...
                'Parent',obj.hFig,...
                'Units','characters',...
                'String','In Path',...
                'Style','togglebutton',...
                'Position',[24.2 11.8461538461538 11.6 1.69230769230769],...
                'Tag','pbGR_In');
            
            obj.addUiControl(...
                'Parent',obj.hFig,...
                'Units','characters',...
                'String','Out',...
                'Style','togglebutton',...
                'Position',[35.6 11.8461538461538 11.6 1.69230769230769],...
                'Tag','pbGR_Out');
            
            obj.addUiControl(...
                'Parent',obj.hFig,...
                'Units','characters',...
                'HorizontalAlignment','right',...
                'String','Rotation angle (deg):',...
                'Style','text',...
                'Position',[2.4 5.53846153846155 21 1.07692307692308]);
            
            obj.addUiControl(...
                'Parent',obj.hFig,...
                'Units','characters',...
                'ListboxTop',0,...
                'Position',[24.2 3.61538461538462 4 1.69230769230769],...
                'CData',icon1,...
                'TooltipString','Decrement rotation angle.',...
                'Tag','pbRotationAngle_Dec');
            
            obj.addUiControl(...
                'Parent',obj.hFig,...
                'Units','characters',...
                'ListboxTop',0,...
                'Position',[33.2000000000001 3.61538461538462 4 1.69230769230769],...
                'CData',icon2,...
                'TooltipString','Increment rotation angle.',...
                'Tag','pbRotationAngle_Inc');
            
            obj.addUiControl(...
                'Parent',obj.hFig,...
                'Units','characters',...
                'ListboxTop',0,...
                'String','0.1',...
                'Style','edit',...
                'Position',[28.2 3.6923076923077 5 1.53846153846154],...
                'BackgroundColor',[1 1 1],...
                'TooltipString','The step size to be used for angle inc/dec.',...
                'Tag','etRotationAngleStepSize');
            
            obj.addUiControl(...
                'Parent',obj.hFig,...
                'Units','characters',...
                'HorizontalAlignment','right',...
                'String','GR mirror position:',...
                'Style','text',...
                'Position',[3.6 12.0769230769231 19.8 1.07692307692308]);
            
            obj.addUiControl(...
                'Parent',obj.hFig,...
                'Units','characters',...
                'String','0',...
                'Style','edit',...
                'Position',[24.4 5.30769230769232 12.6 1.53846153846154],...
                'BackgroundColor',[1 1 1],...
                'TooltipString','Stage rotation angle.',...
                'Tag','etRotationAngle');
            
            obj.addUiControl(...
                'Parent',obj.hFig,...
                'Units','characters',...
                'String','Update',...
                'Position',[37.0000000000001 5.23076923076924 10.2 1.69230769230769],...
                'callback',@obj.changedBScope2RotationAngle,...
                'Tag','pbUpdateRotationAngle');
            
            obj.addUiControl(...
                'Parent',obj.hFig,...
                'Units','characters',...
                'String','Reset',...
                'Position',[37 3.61538461538462 10.2 1.69230769230769],...
                'Tag','pbResetLSC');
            
            h20 = uipanel(...
                'Parent',obj.hFig,...
                'Units','characters',...
                'Position',[1 0.307692307692308 47.6 2.61538461538462],...
                'Clipping','off');
            
            obj.addUiControl(...
                'Parent',h20,...
                'Units','characters',...
                'Max',255,...
                'SliderStep',[0.00392156862745098 0.0392156862745098],...
                'String',{  'Slider' },...
                'Style','slider',...
                'Position',[29.2 0.384615384615384 16.6 1.53846153846154],...
                'BackgroundColor',[0.9 0.9 0.9],...
                'Tag','slScanAlign');
            
            obj.addUiControl(...
                'Parent',obj.hFig,...
                'Units','characters',...
                'HorizontalAlignment','right',...
                'String','Scan align:',...
                'Style','text',...
                'Position',[2.4 1.07692307692308 21 1.07692307692308]);
            
            obj.addUiControl(...
                'Parent',obj.hFig,...
                'Units','characters',...
                'String','0',...
                'Style','edit',...
                'Position',[24.4 0.846153846153846 5.6 1.53846153846154],...
                'BackgroundColor',[1 1 1],...
                'TooltipString','Stage rotation angle.',...
                'Tag','etScanAlign');
            
            disabledControls = {};
            
            % determine if we have an MCM5000
            if numel(obj.hModel.hMotors.hMotor) && isa(obj.hModel.hMotors.hMotor(1).hLSC, 'dabs.thorlabs.MCM5000')
                obj.mcm5000Present = true;
                obj.hLsc = obj.hModel.hMotors.hMotor(1).hLSC;
                
                % default mirror controllers to the mcm5000
                obj.hGGm = obj.hLsc;
                obj.hGRm = obj.hLsc;
                obj.hFLm = obj.hLsc;
            end
            
            % determine if we have an MCM6000
            if numel(obj.hModel.hMotors.hMotor) && isa(obj.hModel.hMotors.hMotor(1).hLSC, 'dabs.thorlabs.MCM6000')
                obj.mcm6000Present = true;
                obj.hLsc = obj.hModel.hMotors.hMotor(1).hLSC;
            end
            
            % if we have an MCM5000 or MCM6000 and it has rotation, bind the controls.
            % Otherwise disable the controls
            if (obj.mcm5000Present && obj.hLsc.hasRotation) || (obj.mcm6000Present && obj.hLsc.hasRotation)
                obj.etRotationAngle.callback = @(src,~)obj.setBScope2RotationAngle(str2double(get(src,'Value')));
                
                obj.pbResetLSC.callback = @(varargin)obj.hLsc.reset();
                
                obj.pbRotationAngle_Inc.callback = @(varargin)obj.stepBScope2RotationAngle(1);
                obj.pbRotationAngle_Dec.callback = @(varargin)obj.stepBScope2RotationAngle(-1);
            else
                disabledControls = [disabledControls {'etRotationAngle' 'pbUpdateRotationAngle'...
                    'pbResetLSC' 'pbRotationAngle_Dec' 'etRotationAngleStepSize' 'pbRotationAngle_Inc'}];
            end
            
            
            % see if an ECU is available
            if ~isprop(obj.hModel, 'hBScope2') || ~obj.hModel.hBScope2.ecuInitSuccessful
                disabledControls = [disabledControls {'etScanAlign' 'slScanAlign'}];
            else
                obj.ecuPresent = true;
                obj.hBScope2 = obj.hModel.hBScope2;
                obj.etScanAlign.bindings = {obj.hBScope2 'scanAlign' 'Value'};
                obj.slScanAlign.bindings = {obj.hBScope2 'scanAlign' 'Value'};
                
                % check if usb mirror controllers are present. if so,
                % override controller
                if ~isempty(obj.hBScope2.hGGMirrorBCM)
                    obj.hGGm = obj.hBScope2;
                end
                
                if ~isempty(obj.hBScope2.hGRMirrorBCM)
                    obj.hGRm = obj.hBScope2;
                end
                
                if ~isempty(obj.hBScope2.hFlipperMirrorBCM)
                    obj.hFLm = obj.hBScope2;
                end
            end
            
            
            % for each mirror, if a controller is available, set the
            % binding. otherwise disable gui object
            if ~isempty(obj.hGGm)
                obj.pbGG_In.callback = @(varargin)obj.changeGalvoGalvoMirrorInPath(true);
                obj.pbGG_In.bindings = {obj.hGGm 'galvoGalvoMirrorInPath' 'Callback' @obj.changedGalvoGalvoMirrorInPath};
                
                obj.pbGG_Out.callback = @(varargin)obj.changeGalvoGalvoMirrorInPath(false);
                obj.pbGG_Out.bindings = {obj.hGGm 'galvoGalvoMirrorInPath' 'Callback' @obj.changedGalvoGalvoMirrorInPath};
            else
                disabledControls = [disabledControls {'pbGG_In' 'pbGG_Out'}];
            end
            
            if ~isempty(obj.hGRm)
                obj.pbGR_In.callback = @(varargin)obj.changeGalvoResonantMirrorInPath(true);
                obj.pbGR_In.bindings = {obj.hGRm 'galvoResonantMirrorInPath' 'Callback' @obj.changedGalvoResonantMirrorInPath};
                
                obj.pbGR_Out.callback = @(varargin)obj.changeGalvoResonantMirrorInPath(false);
                obj.pbGR_Out.bindings = {obj.hGRm 'galvoResonantMirrorInPath' 'Callback' @obj.changedGalvoResonantMirrorInPath};
            else
                disabledControls = [disabledControls {'pbGR_In' 'pbGR_Out'}];
            end
            
            if ~isempty(obj.hFLm)
                obj.pbPmt.callback = @(varargin)obj.changeFlipperMirrorPosition('pmt');
                obj.pbPmt.bindings = {obj.hFLm 'flipperMirrorPosition' 'Callback' @obj.changedFlipperMirrorPosition};
                
                obj.pbCamera.callback = @(varargin)obj.changeFlipperMirrorPosition('camera');
                obj.pbCamera.bindings = {obj.hFLm 'flipperMirrorPosition' 'Callback' @obj.changedFlipperMirrorPosition};
            else
                disabledControls = [disabledControls {'pbPmt' 'pbCamera'}];
            end
            
            cellfun(@(s)set(obj.(s).hCtl,'Enable','off'),disabledControls);
            
            % Only show the gui if some part of the bscope2 component is working
            if obj.ecuPresent || obj.mcm5000Present || ~isempty(obj.hGGm) || ~isempty(obj.hGRm) || ~isempty(obj.hFLm)
                obj.hController.defaultGuis{end+1} = 'BScope2Controls';
            end
            
            % add it to the main controls menu
            hObjs = hController.hGUIs.mainControlsV4.Children;
            hVwMnu = hObjs(arrayfun(@(o)isa(o,'matlab.ui.container.Menu')&&strcmp(o.Label,'View'), hObjs));
            uimenu('Parent',hVwMnu,'Label','BScope2 Controls','Tag','BScope2Controls','Position',15,'callback',@show);
            
            function show(varargin)
                figure(obj.hFig);
            end
        end
    end
    
    
    methods (Hidden)
        %%% BScope2
        function changedFlipperMirrorPosition(obj,~,~)
            switch obj.hFLm.flipperMirrorPosition
                case 'pmt'
                    set(obj.pbCamera,'Value',false);
                    set(obj.pbPmt,'Value',true);
                    
                case 'camera'
                    set(obj.pbPmt,'Value',false);
                    set(obj.pbCamera,'Value',true);
            end
        end
        
        
        function changeFlipperMirrorPosition(obj, val)
            obj.hFLm.flipperMirrorPosition = val;
        end
        
        
        function changedGalvoResonantMirrorInPath(obj,~,~)
            if obj.hGRm.galvoResonantMirrorInPath
                set(obj.pbGR_Out,'Value',false);
                set(obj.pbGR_In,'Value',true);
            else
                set(obj.pbGR_In,'Value',false);
                set(obj.pbGR_Out,'Value',true);
            end
        end
        
        
        function changeGalvoResonantMirrorInPath(obj, val)
            obj.hGRm.galvoResonantMirrorInPath = val;
        end
        
        
        function changedGalvoGalvoMirrorInPath(obj,~,~)
            if obj.hGGm.galvoGalvoMirrorInPath
                set(obj.pbGG_Out,'Value',false);
                set(obj.pbGG_In,'Value',true);
            else
                set(obj.pbGG_In,'Value',false);
                set(obj.pbGG_Out,'Value',true);
            end
        end
        
        
        function changeGalvoGalvoMirrorInPath(obj, val)
            obj.hGGm.galvoGalvoMirrorInPath = val;
        end
        
        
        function setBScope2RotationAngle(obj, val)
            if numel(val) == 1 && ~isnan(val)
                validateattributes(val,{'numeric'},{'scalar', '>=',-180,'<=',180});
                obj.hLsc.completeRotation(val);
                obj.changedBScope2RotationAngle();
            end
        end
        
        function stepBScope2RotationAngle(obj, mult)
            val = obj.hLsc.rotationAngleAbsolute + str2double(get(obj.etRotationAngleStepSize,'string')) * mult;
            validateattributes(val,{'numeric'},{'scalar', '>=',-180,'<=',180});
            obj.setBScope2RotationAngle(val);
        end
        
        function changedBScope2RotationAngle(obj,~,~)
            formatStr = '%.1f';
            rotationAngle = obj.hLsc.rotationAngleAbsolute;
            if ~isempty(rotationAngle)
                set(obj.etRotationAngle,'String',num2str(rotationAngle,formatStr));
            end
        end
    end
end


%% local
function dat = icon1
    dat(:,:,1) = [...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9411    0.9425    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9410    0.9549         0    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9409    0.9447         0         0    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9411    0.9446         0         0         0    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9411    0.9508         0         0         0         0    0.9760    0.9760    0.9760    0.9760    0.9760    0.9760    0.9760    0.9760    0.9412;...
        0.9412    0.9731         0         0         0         0         0         0         0         0         0         0         0         0         0    0.9412;...
        0.9412         0         0         0         0         0         0         0         0         0         0         0         0         0         0    0.9412;...
        0.9412         0         0         0         0         0         0         0         0         0         0         0         0         0         0    0.9412;...
        0.9412    0.9711         0         0         0         0         0         0         0         0         0         0         0         0         0    0.9412;...
        0.9412    0.9411    0.9549         0         0         0         0    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9410    0.9447         0         0         0    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9409    0.9448         0         0    0.9410    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9410    0.9549         0    0.9414    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9411    0.9425    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412];


    dat(:,:,2) = [...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9411    0.9425    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9410    0.9549         0    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9409    0.9447         0         0    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9411    0.9446         0         0         0    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9411    0.9508         0         0         0         0    0.9760    0.9760    0.9760    0.9760    0.9760    0.9760    0.9760    0.9760    0.9412;...
        0.9412    0.9731         0         0         0         0         0         0         0         0         0         0         0         0         0    0.9412;...
        0.9412         0         0         0         0         0         0         0         0         0         0         0         0         0         0    0.9412;...
        0.9412         0         0         0         0         0         0         0         0         0         0         0         0         0         0    0.9412;...
        0.9412    0.9711         0         0         0         0         0         0         0         0         0         0         0         0         0    0.9412;...
        0.9412    0.9411    0.9549         0         0         0         0    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9410    0.9447         0         0         0    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9409    0.9448         0         0    0.9410    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9410    0.9549         0    0.9414    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9411    0.9425    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412];


    dat(:,:,3) = [...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9411    0.9425    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9410    0.9549    1.0000    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9409    0.9447    1.0000    1.0000    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9411    0.9446    1.0000    1.0000    1.0000    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9411    0.9508    1.0000    1.0000    1.0000    1.0000    0.9760    0.9760    0.9760    0.9760    0.9760    0.9760    0.9760    0.9760    0.9412;...
        0.9412    0.9731    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    0.9412;...
        0.9412    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    0.9412;...
        0.9412    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    0.9412;...
        0.9412    0.9711    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    0.9412;...
        0.9412    0.9411    0.9549    1.0000    1.0000    1.0000    1.0000    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9410    0.9447    1.0000    1.0000    1.0000    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9409    0.9448    1.0000    1.0000    0.9410    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9410    0.9549    1.0000    0.9414    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9411    0.9425    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412];
end

function dat = icon2
    dat(:,:,1) = [...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9425    0.9411    0.9412    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9414         0    0.9549    0.9410    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9410         0         0    0.9448    0.9409    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412         0         0         0    0.9447    0.9410    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412         0         0         0         0    0.9549    0.9411    0.9412;...
        0.9412         0         0         0         0         0         0         0         0         0         0         0         0         0    0.9711    0.9412;...
        0.9412         0         0         0         0         0         0         0         0         0         0         0         0         0         0    0.9412;...
        0.9412         0         0         0         0         0         0         0         0         0         0         0         0         0         0    0.9412;...
        0.9412         0         0         0         0         0         0         0         0         0         0         0         0         0    0.9731    0.9412;...
        0.9412    0.9760    0.9760    0.9760    0.9760    0.9760    0.9760    0.9760    0.9760         0         0         0         0    0.9508    0.9411    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412         0         0         0    0.9446    0.9411    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412         0         0    0.9447    0.9409    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412         0    0.9549    0.9410    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9425    0.9411    0.9412    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412];


    dat(:,:,2) = [...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9425    0.9411    0.9412    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9414         0    0.9549    0.9410    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9410         0         0    0.9448    0.9409    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412         0         0         0    0.9447    0.9410    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412         0         0         0         0    0.9549    0.9411    0.9412;...
        0.9412         0         0         0         0         0         0         0         0         0         0         0         0         0    0.9711    0.9412;...
        0.9412         0         0         0         0         0         0         0         0         0         0         0         0         0         0    0.9412;...
        0.9412         0         0         0         0         0         0         0         0         0         0         0         0         0         0    0.9412;...
        0.9412         0         0         0         0         0         0         0         0         0         0         0         0         0    0.9731    0.9412;...
        0.9412    0.9760    0.9760    0.9760    0.9760    0.9760    0.9760    0.9760    0.9760         0         0         0         0    0.9508    0.9411    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412         0         0         0    0.9446    0.9411    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412         0         0    0.9447    0.9409    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412         0    0.9549    0.9410    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9425    0.9411    0.9412    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412];


    dat(:,:,3) = [...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9425    0.9411    0.9412    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9414    1.0000    0.9549    0.9410    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9410    1.0000    1.0000    0.9448    0.9409    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    1.0000    1.0000    1.0000    0.9447    0.9410    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    1.0000    1.0000    1.0000    1.0000    0.9549    0.9411    0.9412;...
        0.9412    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    0.9711    0.9412;...
        0.9412    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    0.9412;...
        0.9412    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    0.9412;...
        0.9412    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    1.0000    0.9731    0.9412;...
        0.9412    0.9760    0.9760    0.9760    0.9760    0.9760    0.9760    0.9760    0.9760    1.0000    1.0000    1.0000    1.0000    0.9508    0.9411    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    1.0000    1.0000    1.0000    0.9446    0.9411    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    1.0000    1.0000    0.9447    0.9409    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    1.0000    0.9549    0.9410    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9425    0.9411    0.9412    0.9412    0.9412    0.9412    0.9412;...
        0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412    0.9412];
end


%--------------------------------------------------------------------------%
% BScope2Controls.m                                                        %
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
