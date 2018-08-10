classdef RoiManager < scanimage.interfaces.Component
    %RoiManager     Functionality to manage regions of interest (ROIs)

    %% USER PROPS    
    properties (SetObservable)
        %%% Frame geometry and resolution

        pixelsPerLine = 512;            % defaultROI only: horizontal resolution
        linesPerFrame = 512;            % defaultROI only: vertical resolution
        
        scanZoomFactor = 1;             % defaultROI only: value of zoom. Constraint: zoomFactor >= 1
        scanRotation   = 0;             % defaultROI only: rotation counter clockwise about the Z-axis of the scanned area or line (degrees)
        scanAngleMultiplierSlow = 1;    % defaultROI only: scale slow output
        scanAngleMultiplierFast = 1;    % defaultROI only: scale fast scanner output
        scanAngleShiftSlow = 0;         % defaultROI only: shift slow scanner output (in FOV coordinates)
        scanAngleShiftFast = 0;         % defaultROI only: shift fast scanner output (in FOV coordinates)
        
        forceSquarePixelation = true;   % defaultROI only: specifies if linesPerFrame is forced to equal pixelsPerLine (logical type)
        forceSquarePixels = true;       % defaultROI only: if true scanAngleMultiplierSlow is constrained to match the fraction scanAngleMultiplierFast * linesPerFrame/pixelsPerLine (logical type)
    end
    
    properties (SetObservable, Dependent)
        %%% Frame timing

        scanFrameRate;                  % number of frames per second.
        scanFramePeriod;                % seconds per frame.
        linePeriod;                     % seconds to scan one line.
        scanVolumeRate;                 % number of volumes per second.
    end
    
    properties (SetObservable, Dependent, Transient)
        currentRoiGroup;                % The currently set roiGroup.
        
        % FOV Information for header for non mroi mode
        imagingFovDeg;                      % [deg] corner points of the scanned area in degrees
        imagingFovUm;                       % [um] corner points of the scanned area in micros
    end
    
    
    properties (SetObservable, Hidden)
        mroiEnable = false;
        scanType = 'frame';
    end
    
    %% INTERNAL PROPS
    properties(Hidden, Access = private)
        hRoiGroupDelayedEventListener;
        hCfgLoadingListener;
        abortUpdatePixelRatioProps = false;
        preventLiveUpdate = false;
        cachedScanTimesPerPlane;
        scan2DProps = struct();         % stores settings for different scanner systems
    end
    
    properties(SetObservable, Hidden, SetAccess = private)
        roiGroupDefault_;
        isLineScan = false;
    end
    
    properties(Hidden, Dependent, SetAccess = private)
        roiGroupDefault;                % The roiGroup used for non-MROI focus/grab/loop modes.
        currentNonDefRoiGroup;          % Current not default roi group (line or mroi)
        refAngularRange;                % Angular range that encompasses FOV of all scanners;
    end
    
    properties(Hidden, Dependent, SetObservable)
        fastZSettling;
    end
    
    %%% ABSTRACT PROPERTY REALIZATION (most.Model)
    properties (Hidden, SetAccess=protected)
        mdlPropAttributes = ziniInitPropAttributes();
        mdlHeaderExcludeProps = {'currentRoiGroup'};
    end
    
    %%% ABSTRACT PROPERTY REALIZATION (scanimage.interfaces.Component)
    properties (SetAccess = protected, Hidden)
        numInstances = 1;
    end
    
    properties (Constant, Hidden)
        COMPONENT_NAME = 'RoiGroup';                        % [char array] short name describing functionality of component e.g. 'Beams' or 'FastZ'
        PROP_TRUE_LIVE_UPDATE = {};                         % Cell array of strings specifying properties that can be set while the component is active
        PROP_FOCUS_TRUE_LIVE_UPDATE = {...                  % Cell array of strings specifying properties that can be set while focusing
            'scanZoomFactor','scanRotation','scanAngleMultiplierSlow',...
            'scanAngleMultiplierFast','scanAngleShiftSlow','scanAngleShiftFast'};
        DENY_PROP_LIVE_UPDATE = {'mroiEnable' 'scanType'};                         % Cell array of strings specifying properties for which a live update is denied (during acqState = Focus)
        
        FUNC_TRUE_LIVE_EXECUTION = {};                      % Cell array of strings specifying functions that can be executed while the component is active
        FUNC_FOCUS_TRUE_LIVE_EXECUTION = {};                % Cell array of strings specifying functions that can be executed while focusing
        DENY_FUNC_LIVE_EXECUTION = {};                      % Cell array of strings specifying functions for which a live execution is denied (during acqState = Focus)
    end
    
    %% EVENTS
    events (Hidden)
        pixPerLineChanged;
    end
    
    %% LIFECYCLE
    methods
        function obj = RoiManager(hSI)
            obj = obj@scanimage.interfaces.Component(hSI);
        end
        
        function delete(obj)
            % DELETE  Safely deletes the instance.

            most.idioms.safeDeleteObj(obj.roiGroupDefault_);
            most.idioms.safeDeleteObj(obj.hCfgLoadingListener);
        end
    end
    
    methods (Access=protected, Hidden)
        function mdlInitialize(obj)
            mdlInitialize@most.Model(obj);
            
            
            %add listener to know when config file finishes loading to do batch operations on new prop values
            obj.hCfgLoadingListener = addlistener(obj.hSI.hConfigurationSaver,'cfgLoadingInProgress','PostSet',@obj.cfgLoadingChanged);
        end
    end
    
    %% PROP ACCESS
    methods
        
        function set.currentRoiGroup(obj,val)
            obj.mdlDummySetProp(val,'currentRoiGroup');
            obj.updateTimingInformation();
        end
        
        function val = get.currentRoiGroup(obj)
            val = obj.roiGroupDefault;
        end
        
        function set.forceSquarePixelation(obj,val)
            val = obj.validatePropArg('forceSquarePixelation',val);
            if obj.componentUpdateProperty('forceSquarePixelation',val)
                obj.forceSquarePixelation = val;
                obj.updatePixelRatioProps('forceSquarePixelation');
            end
        end
        
        function set.forceSquarePixels(obj,val)
            val = obj.validatePropArg('forceSquarePixels',val);
            if obj.componentUpdateProperty('forceSquarePixels',val)
                obj.forceSquarePixels = val;
                obj.updatePixelRatioProps('forceSquarePixels');
            end
        end
        
        function set.linesPerFrame(obj,val)
            val = obj.validatePropArg('linesPerFrame',val);
            if obj.componentUpdateProperty('linesPerFrame',val)
                obj.linesPerFrame = val;
                obj.updatePixelRatioProps('linesPerFrame');
            end
        end
        
        function set.mroiEnable(obj,val)
            val = obj.validatePropArg('mroiEnable',val);
            
            if val
                most.util.denyInFreeVersion('mroiEnable') ;
            end
        end
        
        function set.scanType(obj,val)
            val = obj.validatePropArg('scanType',val);
            
            if ~strcmpi(val,'frame');
               most.util.denyInFreeVersion(sprintf('Scan Type %s',val)) ;
            end
        end
       
        function set.pixelsPerLine(obj,val)
            val = obj.validatePropArg('pixelsPerLine',val);
            if obj.componentUpdateProperty('pixelsPerLine',val)
                obj.pixelsPerLine = val;
                obj.updatePixelRatioProps('pixelsPerLine');
            end
            if ~obj.mroiEnable
                obj.notify('pixPerLineChanged');
            end
        end
        
        function val = get.roiGroupDefault(obj)
            if isempty(obj.roiGroupDefault_)
                obj.roiGroupDefault_ = scanimage.mroi.RoiGroup();
                obj.roiGroupDefault_.name = 'Default Imaging ROI Group';
                scanfield = scanimage.mroi.scanfield.fields.RotatedRectangle([0 0 1 1],0,[512, 512]);
                scanfield.name = 'Default Imaging Scanfield';
                roi = scanimage.mroi.Roi();
                roi.name = 'Default Imaging Roi';
                roi.add(0,scanfield);
                obj.roiGroupDefault_.add(roi);
            end
            
            if ~isvalid(obj.hSI.hScan2D)
                val = [];
                return
            end
            
            pts = obj.hSI.hScan2D.fovCornerPoints;
            pt1 = pts(1,:);
            pt2 = pts(2,:);
            pt3 = pts(3,:);
            pt4 = pts(4,:);
            
            centroid = scanimage.mroi.util.centroidQuadrilateral(pt1,pt2,pt3,pt4);

            dist = [];
            dist(end+1) = norm(centroid-scanimage.mroi.util.intersectLines(centroid,[1, 1],pt1,pt2-pt1));
            dist(end+1) = norm(centroid-scanimage.mroi.util.intersectLines(centroid,[1, 1],pt2,pt3-pt2));
            dist(end+1) = norm(centroid-scanimage.mroi.util.intersectLines(centroid,[1, 1],pt3,pt4-pt3));
            dist(end+1) = norm(centroid-scanimage.mroi.util.intersectLines(centroid,[1, 1],pt4,pt1-pt4));
            dist(end+1) = norm(centroid-scanimage.mroi.util.intersectLines(centroid,[1,-1],pt1,pt2-pt1));
            dist(end+1) = norm(centroid-scanimage.mroi.util.intersectLines(centroid,[1,-1],pt2,pt3-pt2));
            dist(end+1) = norm(centroid-scanimage.mroi.util.intersectLines(centroid,[1,-1],pt3,pt4-pt3));
            dist(end+1) = norm(centroid-scanimage.mroi.util.intersectLines(centroid,[1,-1],pt4,pt1-pt4));
            
            a1 = sqrt(2*min(dist)^2);
            a2 = obj.hSI.hScan2D.defaultRoiSize;
            a = min(a1,a2) * obj.hSI.hScan2D.fillFractionSpatial / obj.scanZoomFactor;

            % replace existing roi in default roi group with new roi
            scl = [obj.hSI.hScan2D.scannerset.transformParams.scaleX obj.hSI.hScan2D.scannerset.transformParams.scaleY];
            obj.roiGroupDefault_.rois(1).scanfields(1).centerXY = centroid + [obj.scanAngleShiftFast obj.scanAngleShiftSlow] .* scl;
            obj.roiGroupDefault_.rois(1).scanfields(1).sizeXY = [obj.scanAngleMultiplierFast obj.scanAngleMultiplierSlow] * a;
            obj.roiGroupDefault_.rois(1).scanfields(1).rotationDegrees = obj.scanRotation;
            obj.roiGroupDefault_.rois(1).scanfields(1).pixelResolution = [obj.pixelsPerLine, obj.linesPerFrame];
            
            val = obj.roiGroupDefault_;
        end
        
        function set.scanRotation(obj,val)
            val = obj.validatePropArg('scanRotation',val);
            if obj.componentUpdateProperty('scanRotation',val)
                obj.scanRotation = val;
                
                obj.coerceDefaultRoi();
                
                %Side effects
                obj.updateLiveNonMroiImaging();
            end
        end
        
        function set.scanZoomFactor(obj,val)
            val = obj.validatePropArg('scanZoomFactor',val);
            if obj.componentUpdateProperty('scanZoomFactor',val)
                obj.scanZoomFactor = round(val*100)/100;
                
                %Coerce SA shift to acceptable values
                obj.coerceDefaultRoi();
                
                %Side effects
                obj.updateLiveNonMroiImaging();
            end
        end
        
        function set.scanAngleMultiplierFast(obj,val)
            val = obj.validatePropArg('scanAngleMultiplierFast',val);
            if obj.componentUpdateProperty('scanAngleMultiplierFast',val)
                obj.scanAngleMultiplierFast = val;
                
                obj.updatePixelRatioProps('scanAngleMultiplierFast');
                
                %Side effects
                obj.updateLiveNonMroiImaging();
            end
        end
        
        function set.scanAngleMultiplierSlow(obj,val)
            val = obj.validatePropArg('scanAngleMultiplierSlow',val);
            if obj.componentUpdateProperty('scanAngleMultiplierSlow',val)
                obj.scanAngleMultiplierSlow = val;
                
                obj.updatePixelRatioProps('scanAngleMultiplierSlow');
                
                %Side effects
                obj.updateLiveNonMroiImaging();
            end
        end
        
        function set.scanAngleShiftSlow(obj,val)
            val = obj.validatePropArg('scanAngleShiftSlow',val);
            if obj.componentUpdateProperty('scanAngleShiftSlow',val)
                
                obj.scanAngleShiftSlow = round(val*1000)/1000;
                
                %Coerce SA shift to acceptable values
                obj.coerceDefaultRoi();
                
                %Side effects
                obj.updateLiveNonMroiImaging();
            end
        end
        
        function set.scanAngleShiftFast(obj,val)
            val = obj.validatePropArg('scanAngleShiftFast',val);
            if obj.componentUpdateProperty('scanAngleShiftFast',val)
                obj.scanAngleShiftFast = round(val*1000)/1000;
                
                %Coerce SA shift to acceptable values
                obj.coerceDefaultRoi();
                
                %Side effects
                obj.updateLiveNonMroiImaging();
            end
        end
    end
        
    methods(Hidden)
        function updateTimingInformation(obj,setLinePeriod)
            if obj.hSI.hConfigurationSaver.cfgLoadingInProgress
                return
            end
            
            obj.cacheScanTimesPerPlane;
            obj.scanFramePeriod = NaN; % trigger GUI update for scanFramePeriod
            obj.hSI.hScan2D.scanPixelTimeMean = NaN; % trigger GUI update for scanPixelTimeMean
            
            if nargin < 2 || isempty(setLinePeriod) || setLinePeriod
                obj.linePeriod = NaN;      % trigger GUI update for linePeriod
            end
        end
        
        function updateLiveNonMroiImaging(obj)
            if ~obj.mroiEnable
                if ~obj.preventLiveUpdate
                    obj.hSI.hScan2D.updateLiveValues();
                    obj.hSI.hFastZ.liveUpdate();
                    
                    if obj.hSI.active
                        obj.hSI.hDisplay.resetActiveDisplayFigs(false);
                    else
                        obj.hSI.hDisplay.needsReset = true;
                    end
                end
            end
        end
    end

    methods
        function cacheScanTimesPerPlane(obj,varargin)
            % CACHESCANTIMESPERPLANE   Recomputes scan times per plane and caches the result.
            %   obj.cacheScanTimesPerPlane   Returns nothing.
            
            ss = obj.hSI.hScan2D.scannerset;
            rg = obj.hSI.hScan2D.currentRoiGroup;
            
            if obj.isLineScan
                obj.cachedScanTimesPerPlane = rg.pathTime(ss);
            else
                N = numel(obj.hSI.hStackManager.zs);
                obj.cachedScanTimesPerPlane(N+1:end) = [];
                
                for idx = N : -1 : 1
                    obj.cachedScanTimesPerPlane(idx) = rg.sliceTime(ss,obj.hSI.hStackManager.zs(idx));
                end
            end
        end
        
        function set.scanFramePeriod(obj,val)
            obj.mdlDummySetProp(val,'scanFramePeriod');
        end
        
        function val = get.scanFramePeriod(obj)
            if isempty(obj.currentRoiGroup) || obj.hSI.hConfigurationSaver.cfgLoadingInProgress
                val = NaN;
            else
                if isempty(obj.cachedScanTimesPerPlane)
                    obj.cacheScanTimesPerPlane();
                end
                val = max(obj.cachedScanTimesPerPlane);
            end
        end
        
        function set.linePeriod(obj,val)
            obj.mdlDummySetProp(val,'linePeriod');
            obj.updateTimingInformation(false);
        end
        
        function val = get.linePeriod(obj)
            % currently this only outputs the scantime for the default roi
            scannerset = obj.hSI.hScan2D.scannerset;
            [lineScanPeriod,~] = scannerset.linePeriod(obj.roiGroupDefault.rois(1).scanfields(1));
            val = lineScanPeriod;
        end
        
        function set.fastZSettling(obj,~)
            obj.updateTimingInformation();
        end
        
        function val = get.fastZSettling(~)
            val = NaN;
        end
        
        function set.scanFrameRate(obj,val)
            obj.mdlDummySetProp(val,'scanFrameRate');
        end
        
        function val = get.scanFrameRate(obj)
            val = 1/obj.scanFramePeriod;
        end

        function set.scanVolumeRate(obj,val)
            obj.mdlDummySetProp(val,'scanFrameRate');
        end
        
        function val = get.scanVolumeRate(obj)
            val = (1 / obj.scanFramePeriod) / (obj.hSI.hStackManager.slicesPerAcq + obj.hSI.hFastZ.numDiscardFlybackFrames);
        end
        
        function v = get.refAngularRange(obj)
            rgs = cellfun(@(h)h.fovCornerPoints,obj.hSI.hScanners,'UniformOutput',false);
            v = 2*max(abs(vertcat(rgs{:})),[],1);
        end
        
        function v = get.imagingFovDeg(obj)
            if obj.mroiEnable
                v = [];
            else
                v = obj.currentRoiGroup.rois(1).scanfields(1).cornerpoints;
            end
        end
        
        function v = get.imagingFovUm(obj)
            v = obj.imagingFovDeg * obj.hSI.objectiveResolution;
        end
    end
    
    %% USER METHODS
    
    %% INTERNAL METHODS
    methods (Access = protected)
        function componentStart(obj)
        %   Runs code that starts with the global acquisition-start command
            obj.coerceDefaultRoi();
            obj.updateTimingInformation();
            assert(~isempty(obj.hSI.hScan2D.currentRoiGroup.activeRois) && ~isempty([obj.hSI.hScan2D.currentRoiGroup.activeRois.scanfields]), 'There must be at least one active ROI with at least one scanfield within the scanner FOV to start an acquisition.');
        end
        
        function componentAbort(obj)
        %   Runs code that aborts with the global acquisition-abort command
            % TODO: clear the cache once the acquisition completes. The
            % problem is that currently componentAbort is being called
            % prior to the end of the acquisition, which nullifies the
            % advantages of caching the scantimes per plane.
        end
        
        function roiGroupChanged(obj)
            if obj.mroiEnable || obj.isLineScan
                obj.updateTimingInformation();
                obj.hSI.hScan2D.updateLiveValues();
                obj.hSI.hFastZ.liveUpdate();
                
                obj.notify('pixPerLineChanged');
                
                if obj.hSI.active
                    obj.hSI.hDisplay.resetActiveDisplayFigs();
                else
                    obj.hSI.hDisplay.needsReset = true;
                end
            end
        end
        
        function coerceDefaultRoi(obj)
            % COERCEDEFAULTROI
            %   obj.coerceDefaultRoi
            %
            % NOTES
            %   Uses a persistent variable.
            persistent inp;
            
            if isempty(inp)
                try
                    inp = true;
                    ss = obj.hSI.hScan2D.scannerset;
                    
                    rG = obj.roiGroupDefault;
                    ss.satisfyConstraintsRoiGroup(rG);
                    
                    sas = rG.rois.scanfields.centerXY;
                    
                    obj.preventLiveUpdate = true;
                    if abs(obj.scanAngleShiftFast - sas(1)) > 0.000001
                        obj.scanAngleShiftFast = sas(1);
                    end
                    if abs(obj.scanAngleShiftSlow - sas(2)) > 0.000001
                        obj.scanAngleShiftSlow = sas(2);
                    end
                    if ~obj.hSI.hScan2D.supportsRoiRotation
                        obj.scanRotation = 0;
                    end
                    
                    obj.preventLiveUpdate = false;
                catch ME
                    inp = [];
                    ME.rethrow;
                end
                inp = [];
            end
        end
    end
    
    methods (Access = private)
        function updatePixelRatioProps(obj,sourceProp)
            if nargin < 2
                sourceProp = '';
            end
            
            if ~obj.abortUpdatePixelRatioProps && ~obj.hSI.hConfigurationSaver.cfgLoadingInProgress % prevent infinite recursion
                obj.abortUpdatePixelRatioProps = true;
                
                if obj.forceSquarePixelation && obj.linesPerFrame ~= obj.pixelsPerLine
                    obj.linesPerFrame = obj.pixelsPerLine;
                end
                
                if obj.forceSquarePixels
                    if isempty(strfind(sourceProp, 'scanAngleMultiplier'))
                        %changed a pixel value. change SA multipliers appropriately
                        samSlow = obj.scanAngleMultiplierFast * obj.linesPerFrame/obj.pixelsPerLine;
                        if samSlow > 1
                            obj.scanAngleMultiplierSlow = 1;
                            obj.scanAngleMultiplierFast = obj.pixelsPerLine/obj.linesPerFrame;
                        else
                            obj.scanAngleMultiplierSlow = samSlow;
                        end
                    else
                        if obj.forceSquarePixelation
                            %changed an SA multiplier. Since both forceSquarePixels and forceSquarePixelation are on, SA multipliers must be equal
                            if strcmp(sourceProp, 'scanAngleMultiplierSlow')
                                obj.scanAngleMultiplierFast = obj.scanAngleMultiplierSlow;
                            else
                                obj.scanAngleMultiplierSlow = obj.scanAngleMultiplierFast;
                            end
                        else
                            %changed an SA multiplier. change pixel values appropriately
                            obj.linesPerFrame = round(obj.pixelsPerLine * obj.scanAngleMultiplierSlow/obj.scanAngleMultiplierFast);
                        end
                    end
                end
                
                obj.abortUpdatePixelRatioProps = false;
                if ~obj.mroiEnable
                    obj.hSI.hDisplay.resetActiveDisplayFigs(false);
                end
            end
        end
        
        function cfgLoadingChanged(obj, ~, evnt)
            if ~evnt.AffectedObject.cfgLoadingInProgress
                %Just finsihed loading cfg file
                obj.updatePixelRatioProps();
            end
        end
    end   
    
    %% USER EVENTS
    %% FRIEND EVENTS
    %% INTERNAL EVENTS
end

%% LOCAL (after classdef)
function s = ziniInitPropAttributes()
s = struct();

s.mroiEnable = struct('Classes','binaryflex','Attribues',{{'scalar'}});
s.scanType   = struct('Options',{{'frame','line'}});

%%% Frame geometry and resolution
s.pixelsPerLine             = struct('Classes','numeric','Attributes',{{'integer','positive','finite','scalar'}});
s.linesPerFrame             = struct('Classes','numeric','Attributes',{{'integer','positive','finite','scalar'}});
s.scanZoomFactor            = struct('Classes','numeric','Attributes',{{'scalar','finite','>=',1}});
s.scanRotation              = struct('Classes','numeric','Attributes',{{'scalar','finite'}});
s.scanAngleMultiplierSlow   = struct('Classes','numeric','Attributes',{{'scalar','finite','>=',0}});
s.scanAngleMultiplierFast   = struct('Classes','numeric','Attributes',{{'scalar','finite','>=',0}});
s.forceSquarePixelation     = struct('Classes','binaryflex','Attributes',{{'scalar'}});
s.forceSquarePixels         = struct('Classes','binaryflex','Attributes',{{'scalar'}});
s.scanAngleShiftSlow        = struct('Classes','numeric','Attributes',{{'scalar','finite'}});
s.scanAngleShiftFast        = struct('Classes','numeric','Attributes',{{'scalar','finite'}});

%%% Frame timing
s.scanFrameRate   = struct('DependsOn',{{'scanFramePeriod'}});
s.scanVolumeRate  = struct('DependsOn',{{'scanFramePeriod','hSI.hStackManager.slicesPerAcq','hSI.hFastZ.numDiscardFlybackFrames'}});
s.scanFramePeriod = struct('DependsOn',{{'linePeriod','hSI.hStackManager.zs','fastZSettling'}});
s.fastZSettling   = struct('DependsOn',{{'hSI.hFastZ.enable','hSI.hFastZ.waveformType','hSI.hFastZ.flybackTime'}});
s.linePeriod      = struct('DependsOn',{{'hSI.imagingSystem','hSI.hScan2D.scannerset','hSI.hScan2D.pixelBinFactor','hSI.hScan2D.sampleRate','mroiEnable','currentRoiGroup','pixelsPerLine','linesPerFrame','scanType'}});
end


%--------------------------------------------------------------------------%
% RoiManager.m                                                             %
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
