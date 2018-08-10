classdef RoiGroup < scanimage.mroi.RoiTree    
    %% Properties    
    properties(SetAccess = private)
        rois = scanimage.mroi.Roi.empty(1,0);
    end
    
    properties(SetAccess = private,Dependent)
        activeRois;   % subset of rois, where roi.enable  == true
        displayRois;  % subset of rois, where roi.display == true
        zs;           % array containing Z's of Rois in RoiGroup
    end
    
    %% Private properties
    properties (Hidden, SetAccess = private)
        roiStatusIds;
        roiUuiduint64s;
        roiUuiduint64sSorted;
        roiUuiduint64sSortIndx;
    end
    
    properties(Access = private)       
        roisListenerMap;
    end
    
    %% Lifecycle
    methods
        function obj=RoiGroup(nm)
            %% Makes an empty RoiGroup
            obj = obj@scanimage.mroi.RoiTree();
            
            if nargin > 0 && ~isempty(nm)
                obj.name = nm;
            end
        end
        
        function delete(obj)
            delete(obj.roisListenerMap);
        end
        
        function s=saveobj(obj)
            s = saveobj@scanimage.mroi.RoiTree(obj);
            s.rois = arrayfun(@(r) saveobj(r),obj.rois);
        end
        
        function copyobj(obj,other)
            copyobj@scanimage.mroi.RoiTree(obj,other);
            obj.clear();
            arrayfun(@(roi)obj.add(roi),other.rois,'UniformOutput',false);
        end
    end
    
    methods(Access = protected)
        % Override copyElement method:
        function cpObj = copyElement(obj)
            %cpObj = copyElement@matlab.mixin.Copyable(obj);
            cpObj = scanimage.mroi.RoiGroup();
            copyElement@scanimage.mroi.RoiTree(obj,cpObj);
            arrayfun(@(roi)cpObj.add(roi.copy()),obj.rois,'UniformOutput',false);
        end
    end
    
    %% Public methods for AO generation
    methods        
        % public
        function [ao_volts,samplesPerTrigger,sliceScanTime,path_FOV] = scanStackAO(obj,scannerset,zPowerReference,zs,zWaveform,flybackFrames,zActuator,sliceScanTime,tuneZ)
            if nargin < 7 || isempty(zActuator)
                zActuator = 'fast';
            end
            if nargin < 8 || isempty(sliceScanTime)
                sliceScanTime = [];
            end
            if nargin < 9 || isempty(tuneZ)
                tuneZ = true;
            end
            
            [path_FOV,samplesPerTrigger,sliceScanTime] = obj.scanStackFOV(scannerset,zPowerReference,zs,zWaveform,flybackFrames,zActuator,sliceScanTime,tuneZ);
            ao_volts = arrayfun(@(fov)scannerset.pathFovToAo(fov),path_FOV);
        end
        
        % private
        function [path_FOV,samplesPerTrigger,sliceScanTime] = scanStackFOV(obj,scannerset,zPowerReference,zs,zWaveform,flybackFrames,zActuator,sliceScanTime,tuneZ,maxPtsPerSf,applyConstraints)
            if nargin < 7 || isempty(zActuator)
                zActuator = 'fast';
            end
            if nargin < 8
                sliceScanTime = [];
            end
            if nargin < 9
                tuneZ = true;
            end
            if nargin < 10 || isempty(maxPtsPerSf)
                maxPtsPerSf = inf;
            end
            if nargin < 11 || isempty(applyConstraints)
                applyConstraints = true;
            end
            
            if applyConstraints
                scannerset.satisfyConstraintsRoiGroup(obj);
            end
            
            if isempty(sliceScanTime)
                for idx = numel(zs) : -1 : 1
                    scanTimesPerSlice(idx) = obj.sliceTime(scannerset,zs(idx));
                end
                sliceScanTime = max(scanTimesPerSlice);
            end
            
            if numel(zs) > 1 && strcmp(zWaveform, 'sawtooth')
                dz = (zs(end)-zs(1))/(numel(zs)-1);
                dzdt = dz/sliceScanTime;
            else
                dzdt = 0;
            end
            
            flybackTime = scannerset.frameFlybackTime;
            frameTime = sliceScanTime - flybackTime;
            
            for idx = numel(zs) : -1 : 1
                [outputData{idx}, slcEmpty(idx)] = obj.scanSliceFOV(scannerset,zPowerReference,zs(idx),dzdt,zActuator,frameTime,flybackTime,zWaveform,maxPtsPerSf);
            end
            
            outputData(numel(zs)+1:numel(zs)+flybackFrames) = obj.zFlybackFrames(scannerset,flybackFrames,frameTime,flybackTime,zWaveform);

            samplesPerTrigger = scannerset.samplesPerTriggerForAO(outputData);
            
            if strcmp(zWaveform, 'slow')
                assert(~any(slcEmpty),'Some slices did not contain any ROIs to scan.');
                path_FOV = cellfun(@(x)scannerset.interpolateTransits(x,tuneZ,zWaveform),outputData);
            else
                dataPoints = most.util.vertcatfields([outputData{:}]);
                path_FOV = scannerset.interpolateTransits(dataPoints,tuneZ,zWaveform);
            end
        end

        % private
        % (used by scanStackFOV and scanStackAO)
        function [path_FOV, slcEmpty] = scanSliceFOV(obj,scannerset,zPowerReference,z,dzdt,zActuator,frameTime,flybackTime,zWaveformType,maxPtsPerSf)
            %% ao_volts = scan(obj,scannerset,z,dzdt,frameTime,flybackTime)
            %
            %  Generates the full ao for scanning plane z using the 
            %  specified scannerset
              
            paths{1} = obj.rois.scanPathFOV(scannerset,zPowerReference,z,z,dzdt,zActuator,false);
            paths{2} = scannerset.transitNaN(obj.rois.scanfields,NaN);
            slcEmpty = false;
            tfStim = false;

            path_FOV = most.util.vertcatfields([paths{:}]);
            
            % Padding: 
            if ~tfStim && (frameTime + flybackTime) > 0
                path_FOV = scannerset.padFrameAO(path_FOV,frameTime,flybackTime,zWaveformType);
            end
        end
        
        function data = zFlybackFrames(~,ss,flybackFrames,frameTime,flybackTime,zWaveformType)
            data = [];
            for i = flybackFrames:-1:1
                path_FOV = ss.zFlybackFrame(frameTime);
                data{i} = ss.padFrameAO(path_FOV,frameTime,flybackTime,zWaveformType);
            end
        end
        
        % public (but should look at why)
        function scanTime = scanTimes(obj,scannerset,z)
            % Returns array of seconds with scanTime for each scanfield
            % at a particular z
            scanTime=0;
            if ~isa(scannerset,'scanimage.mroi.scannerset.ScannerSet')
                return;                
            end
                
            scanfields  = obj.scanFieldsAtZ(z);
            scanTime    = cellfun(@(scanfield)scannerset.scanTime(scanfield),scanfields);
        end

        % public (but should look at why)
        function [seconds,flybackseconds] = transitTimes(obj,scannerset,z)
            % Returns array of seconds with transitionTime for each scanfield
            % at a particular z
            % seconds includes the transition from park to the first scanfield of the RoiGroup
            % flybackseconds is the flyback transition from last scanfield to park

            seconds=0;
            flybackseconds=0;            
            if ~isa(scannerset,'scanimage.mroi.scannerset.ScannerSet')
                return;                
            end
            
            scanfields = obj.scanFieldsAtZ(z);
            if isempty(scanfields)
                seconds = [];
                flybackseconds = 0;
            else
                scanfields = [{NaN} scanfields {NaN}]; % pre- and ap- pend "park" to the scan field sequence
                
                tp = scanimage.mroi.util.chain(scanfields); % form pair of scanfields for transition
                seconds = cellfun(@(pair) scannerset.transitTime(pair{1},pair{2}),tp);
                
                flybackseconds = seconds(end); % save flybackseconds separately
                seconds(end) = [];
            end
        end
        
        % public
        function seconds = sliceTime(obj,scannerset,z)
            %% Returns the minimum time [seconds] to scan plane z (does not include any padding)
            scantimes = obj.scanTimes(scannerset,z);
            [transitTimes,flybackTime] = obj.transitTimes(scannerset,z);
            seconds = sum(scantimes) + sum(transitTimes) + flybackTime;
        end
        
        function seconds = pathTime(obj,scannerset)
            r = obj.activeRois;
            if isempty(r)
                seconds = nan;
            else
                allf = [r(:).scanfields];
                seconds = sum(arrayfun(@(sf)scannerset.scanTime(sf),allf));
            end
        end

        % public
        function [scanfields,zrois] = scanFieldsAtZ(obj,z,activeSfsOnly)
            scanfields = {obj.rois.scanfields};
            zrois = num2cell(obj.rois);
        end

    end

    %% Public methods for operating on the roi list -- mostly for UI
    methods
        function clear(obj)
            delete(obj.roisListenerMap);
            obj.roiStatusIds = cast([],'like',obj.statusId);
            obj.roiUuiduint64s = cast([],'like',obj.uuiduint64);
            obj.rois = scanimage.mroi.Roi.empty(1,0);
        end
        
        function roi = getRoiById(obj,id)
            roi = obj.rois;
        end

        function idxs = idToIndex(obj,ids,throwError)
            % returns the index of the array obj.rois for roi ids
            % ids: cellstr of uuids OR vector of uuidint64 OR numeric vector
            % throwError: false (standard): does not throw error
            %             true: issues error if one or more rois with given id are
            %                           not found
            % returns idxs: indices of rois in obj.rois; for unknown rois 0
            %               is returned
            
            if nargin < 3 || isempty(throwError)
                throwError = false;
            end
            
            
            if isa(ids,class(obj.uuiduint64))
                % assume id is a uuiduint64
                idxs = ismembc2(ids,obj.roiUuiduint64sSorted); % performance optimization
                idxs(idxs>0) = obj.roiUuiduint64sSortIndx(idxs(idxs>0)); % resort
            elseif isnumeric(ids)
                idxs = ids;
                idxs(idxs<1) = 0;
                idxs(idxs>length(obj.rois)) = 0;
            elseif ischar(ids) || iscellstr(ids)
                % this is relatively slow. better: use uuiduint64
                [~,idxs] = ismember(ids,{obj.rois.uuid});
            else
                error('Unknown id format: %s',class(ids));
            end
            
            if throwError && any(idxs==0)
                if isa(ids,'char')
                    zeroIds = ['''' ids ''''];
                elseif iscellstr(ids)
                    zeroIds = strjoin(ids(idxs==0));
                else
                    zeroIds = mat2str(ids(idxs==0));
                end
                
                error('SI:mroi:StimSeriesIndexNotFound Could not find rois with id(s) %s',zeroIds);
            end
        end
        
        function obj = add(obj,roi)
            if(~isa(roi,'scanimage.mroi.Roi'))
                error('MROI:TypeError','Expected an object of type scanimage.mroi.Roi');
            end
            
            obj.clear();
            obj.rois = roi;
            obj.roisListenerMap = addlistener(roi,'changed',@obj.fireChangedEvent);
        end
        
        function mc=scanfieldMetaclass(obj)
            if(isempty(obj.rois) || isempty(obj.rois(1).scanfields)),
                mc=meta.class.fromName(''); % empty class if no scanfields/not determined
            else
                mc=metaclass(obj.rois(1).scanfields(1));
            end
        end

        function obj=filterByScanfield(obj,f)
            % Disables some scanfields according to f.
            %
            % f must be a function mapping a scanfield to a boolean
            %   if f returns false, then the entire roi will be disabled.            
            for r=obj.rois
                tf=arrayfun(f,r.scanfields);
                if any(~tf)
                    r.enable=false;
                end
            end

        end
        
        
        % Both of these functions need to be present in the free version to
        % satisfy abstract class.
        function tf = isequalish(A,B)
           % No op? 
        end
        
        function h = hashgeometry(obj)
            % not implemented
            assert(false);
        end
    end % end public methods
    
    methods (Hidden)
        function roiChanged(obj,src,evt)
            idx = obj.idToIndex(src.uuiduint64);
            obj.roiStatusIds(idx) = src.statusId;
            obj.fireChangedEvent();
        end
    end
    
    %% Property access methods
    methods
        function val = get.activeRois(obj)
            if ~isempty(obj.rois)
                val = obj.rois([obj.rois.enable]);
            else
                val = [];
            end
        end
        
        function val = get.displayRois(obj)
            if ~isempty(obj.rois)
                val = obj.rois([obj.rois.enable] & [obj.rois.display]);
            else
                val = [];
            end
        end
        
        function val = get.zs(obj)
            zs = [];
            for roi = obj.rois
                zs = horzcat(zs,roi.zs(:)'); %#ok<AGROW>
            end
            val = sort(unique(zs));
        end
        
        function set.rois(obj,val)
            if isempty(val)
                val = scanimage.mroi.Roi.empty(1,0);
            end
            obj.rois = val;
            obj.fireChangedEvent();
        end
        
        function set.roiUuiduint64s(obj,val)
            if isempty(val)
                val = cast([],'like',obj.uuiduint64);
            end
            
            obj.roiUuiduint64s = val;
            [obj.roiUuiduint64sSorted,obj.roiUuiduint64sSortIndx] = sort(val);
        end
        
        function saveToFile(obj,f)
            %roigroup = obj;
            %save(f,'roigroup','-mat');
            most.json.savejson('',obj,f);
        end
    end
    
    %% Static methods
    methods(Static)
        function obj=loadobj(s)
            obj=scanimage.mroi.RoiGroup();
            loadobj@scanimage.mroi.RoiTree(obj,s);
            if iscell(s.rois)
                s.rois = [s.rois{:}];
            end
            arrayfun(@(r) obj.add(scanimage.mroi.Roi.loadobj(r)),s.rois,'UniformOutput',false);
        end
        
        function obj=loadFromFile(f)
            try
                obj = most.json.loadjsonobj(f);
            catch ME
                % support for old binary roigroup file format
                try
                    data = load(f,'-mat','roigroup');
                    obj = data.roigroup;
                catch
                    rethrow(ME);
                end
            end
        end
    end
end


%--------------------------------------------------------------------------%
% RoiGroup.m                                                               %
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
