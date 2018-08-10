classdef Roi < scanimage.mroi.RoiTree
    %% 3D region of interest formed from 2d scanfields over a z interval.
    % 
    % The 3d shape is determined by interpolating between (z,scanfield)
    % pairs that are added as control points.
    %
    
    %% Public properties
    properties (SetObservable)
        enable = true;                  % specifies if the Roi is scanned
        display = true;                 % specifies if the Roi is displayed
        discretePlaneMode = false;      % if true, roi only exists on planes where scanfield is defined
        
        % Roi specific beam settings
        powers = [];                % array containing power values for each beam [mumeric]
        pzAdjust = [];              % #ok<*NBRAK> % array indicating whether power/z adjustment is enabled for each beam [logical]
        Lzs = [];                   % array containing length constant for each beam, to use for power adjustment during Z stacks [numeric]
        interlaceDecimation = [];   % array indicating for each beam that beam should only be on every n'th line
        interlaceOffset = [];       % array indicating for each beam the offset line to start interlace
    end
    
    properties(SetAccess = private)
        scanfields = []; % A collection of scanimage.mroi.Scanfield objects
        zs = [];         % the plane for each set of control points
    end
    
    %% Private / friend properties
    properties (Hidden, SetAccess = private)
        sfStatusIds;
        sfUuiduint64s;
        sfUuiduint64sSorted;
        sfUuiduint64sSortIndx;
    end
    
    properties(Access = private)
        scanFieldsListenerMap;
    end

    %% Lifecycle
    methods
        function obj = Roi()
            %% Makes an empty Roi
            obj = obj@scanimage.mroi.RoiTree();
            obj.scanFieldsListenerMap = containers.Map('KeyType',class(obj.uuiduint64),'ValueType','any');
            obj.sfStatusIds = cast([],'like',obj.statusId);
            obj.sfUuiduint64s = cast([],'like',obj.uuiduint64);
        end
        
        function delete(obj)
            obj.scanFieldsListenerMap; % Matlab 2016a workaround to prevent obj.scanFieldsListenerMap from becoming invalid
            cellfun(@(lh)delete(lh),obj.scanFieldsListenerMap.values); % delete all scanfield listener handles
        end
        
        function s=saveobj(obj)
            s = saveobj@scanimage.mroi.RoiTree(obj);
            s.zs = obj.zs;
            s.scanfields = arrayfun(@(sf)saveobj(sf),obj.scanfields);
            s.discretePlaneMode = obj.discretePlaneMode;
            s.powers = obj.powers;
            s.pzAdjust = obj.pzAdjust;
            s.Lzs = obj.Lzs;
            s.interlaceDecimation = obj.interlaceDecimation;
            s.interlaceOffset = obj.interlaceOffset;
        end
    end
    
    methods(Access = protected)
        function cpObj = copyElement(obj)
            %cpObj = copyElement@matlab.mixin.Copyable(obj);
            
            cpObj = scanimage.mroi.Roi();
            cpObj = copyElement@scanimage.mroi.RoiTree(obj,cpObj);
            cpObj.enable = obj.enable;
            cpObj.display = obj.display;
            cpObj.powers = obj.powers;
            cpObj.pzAdjust = obj.pzAdjust;
            cpObj.Lzs = obj.Lzs;
            cpObj.interlaceDecimation = obj.interlaceDecimation;
            cpObj.interlaceOffset = obj.interlaceOffset;
            cpObj.discretePlaneMode = obj.discretePlaneMode;
            
            arrayfun(@(z)cpObj.add(z,obj.get(z).copy()),obj.zs,'UniformOutput',false);
        end
    end
    
    %% Public methods
    methods
        function [path_FOV,dt] = scanPathFOV(obj,scannerset,zPowerReference,z,actz,dzdt,zActuator,tfStim,maxPtsPerSf)
            %% returns the scan pattern for the z'th plane
            %  nx,ny are the number of x pixels and y pixels to scan, respectively
            %
            %  If obj.hit(z) is not true, returns [].
            %  otherwise returns a "number of channels" by "number of samples" array.
            %            
            
            if nargin < 8
                tfStim = false;
            end
            if nargin < 9 || isempty(maxPtsPerSf)
                maxPtsPerSf = inf;
            end
            
            path_FOV=[]; dt=0;
            
            if tfStim
                err = isempty(obj.scanfields);
                if ~err
                    sf = obj.scanfields(1);
                    actz = obj.zs(1);
                end
            else
                [sf,err] = obj.interpolate(z); % interpolate only returns enabled sfs
            end

            if(err);return; end
                        
            [path_FOV,dt] = scannerset.scanPathFOV(sf,obj,zPowerReference,actz,dzdt,zActuator,maxPtsPerSf);
        end        
        
        function idxs = idToIndex(obj,id,throwError)
            % returns the index of the array obj.scanfields for scanfield ids
            % ids: cellstr of uuids OR vector of uuidint64 OR numeric vector
            % throw: false(standard): does not throw error
            %        true: issues error if one or more scanfields with given id are
            %              not found
            % returns idxs: indices of scanfields in obj.scanfields; for unknown rois 0
            %               is returned
            
            if nargin < 3 || isempty(throwError)
                throwError = false;
            end
            
            if isa(id,'uint64')
                % assume id is a uuiduint64
                idxs = ismembc2(id,obj.sfUuiduint64sSorted); % performance optimization
                idxs(idxs>0) = obj.sfUuiduint64sSortIndx(idxs(idxs>0)); % resort
            elseif isnumeric(id)
                idxs = id;
                idxs(idxs<1) = 0;
                idxs(idxs>length(obj.scanfields)) = 0;
            elseif isa(id,'char') || iscellstr(id)
                % this is relatively slow. better: use uuiduint64
                [~,idxs] = ismember(id,{obj.scanfields.uuid});
            else
                error('Unknown id format: %s',class(id));
            end
            
            if throwError && any(idxs==0)
                if isa(id,'char')
                    zeroIds = ['''' id ''''];
                elseif iscellstr(id)
                    zeroIds = strjoin(id(idxs==0));
                else
                    zeroIds = mat2str(id(idxs==0));
                end
                    
                error('SI:mroi:StimSeriesIndexNotFound Could not find scanfields with id(s) [%s]',zeroIds);
            end
        end
                
        function obj=add(obj,z,scanfield)
            %% obj=add(obj,z,scanfield)
            % Adds a scanfield at a particular z plane.
            % Serves as a control point for interpolation.
            % FIXME: See Note (1)
     
            if(~isa(scanfield,'scanimage.mroi.scanfield.ScanField')),
                error('MROI:TypeError','scanfield must be a kind of scanimage.mroi.scanfield.ScanField');
            end
            if(~isempty(obj.scanfields))
                if(~isa(scanfield,class(obj.scanfields(1)))),
                    error('MROI:TypeError','All the scanfields added to an scanimage.mroi.Roi must be the same type.');
                end
            end
            
            obj.zs = z;
            obj.scanfields = scanfield;
        end
        
        function obj=removeById(obj,id,silent)
            if nargin < 3 || isempty(silent)
                silent = false;
            end
            
            idxs = obj.idToIndex(id,~silent);
            idxs(isnan(idxs)) = [];
            if isempty(idxs)
                return
            end
            
            uuiduint64s = [obj.scanfields(idxs).uuiduint64];
            obj.scanfields(idxs)=[];
            obj.sfStatusIds(idxs) = [];
            obj.sfUuiduint64s(idxs) = [];
            obj.zs(idxs)=[];
            
            for uuiduint64 = uuiduint64s
                if ~any(ismember(uuiduint64,[obj.scanfields.uuiduint64]))
                    lh = obj.scanFieldsListenerMap(uuiduint64);
                    delete(lh);
                    obj.scanFieldsListenerMap.remove(uuiduint64);
                end
            end
        end
        
        function obj=removeByZ(obj,z,silent)
            if nargin < 3 || isempty(silent)
                silent = false;
            end
            
            [tf,idxs] = ismember(z,obj.zs);
            idxs = idxs(tf);
            obj.removeById(idxs,silent);
        end
        
        function clear(obj)
            obj.scanfields=[];
            obj.sfStatusIds = [];
            obj.sfUuiduint64s = [];
            obj.zs=[];
            
            cellfun(@(h)delete(h),obj.scanFieldsListenerMap.values);
            obj.scanFieldsListenerMap.remove(obj.scanFieldsListenerMap.keys);
        end
        
        function sf = get(obj,z,force)
            if nargin < 3
                force = false;
            end
            [sf,err] = obj.interpolate(z,force);
        end
        
        function tf = hit(obj,z)
            %% returns true if this roi is involved in the imaging of plane z
            if(isempty(obj.zs)),   tf = false; return; end
            if obj.discretePlaneMode, tf = any(obj.zs == z); return; end
            if(length(obj.zs)==1), tf = true;  return; end
            tf = min(obj.zs(:))<=z && z<=max(obj.zs(:));
        end
    end
    
    methods (Hidden)
        function sfChanged(obj,src,evt)
            idx = obj.idToIndex(src.uuiduint64);
            obj.sfStatusIds(idx) = src.statusId;
            obj.fireChangedEvent();            
        end
    end
    
    %% Private methods
    methods(Access=private)        
        function [sfs,err] = interpolate(obj,z,force)
            if nargin < 3
                force = false;
            end
            
            if isempty(obj.scanfields)
                sfs = [];
                err = 1;
                return;
            else
                err=0;
                discr = obj.discretePlaneMode || isa(obj.scanfields(1),'scanimage.mroi.scanfield.fields.StimulusField');
                sfs = obj.scanfields;
                return;
            end
            
        end
    end
    
    %% Property setter
    methods        
        function set.zs(obj,val)
            obj.zs = val;
            obj.fireChangedEvent();
        end
        
        function set.enable(obj,val)
            obj.enable = logical(val);
            obj.fireChangedEvent();
        end
        
        function set.display(obj,val)
            obj.display = val;
            obj.fireChangedEvent();
        end
        
        function set.discretePlaneMode(obj,val)
            obj.discretePlaneMode = val;
            obj.fireChangedEvent();
        end
        
        function set.powers(obj,val)
            obj.powers = val;
            obj.fireChangedEvent();
        end
        
        function set.pzAdjust(obj,val)
            obj.pzAdjust = val;
            obj.fireChangedEvent();
        end
        
        function set.Lzs(obj,val)
            obj.Lzs = val;
            obj.fireChangedEvent();
        end
        
        function set.interlaceDecimation(obj,val)
            obj.interlaceDecimation = val;
            obj.fireChangedEvent();
        end
        
        function set.interlaceOffset(obj,val)
            obj.interlaceOffset = val;
            obj.fireChangedEvent();
        end
        
        function set.sfUuiduint64s(obj,val)
            if isempty(val)
                val = cast([],'like',obj.uuiduint64);
            end
            
            obj.sfUuiduint64s = val;
            [obj.sfUuiduint64sSorted,obj.sfUuiduint64sSortIndx] = sort(val);
        end
    end
    
    %% Static methods
    methods(Static)
        function obj=loadobj(s)
            obj=scanimage.mroi.Roi;
            loadobj@scanimage.mroi.RoiTree(obj,s);
            
            loadfield('discretePlaneMode');
            loadfield('powers');
            loadfield('pzAdjust');
            loadfield('Lzs');
            loadfield('interlaceDecimation');
            loadfield('interlaceOffset');
            
            if iscell(s.scanfields)
                s.scanfields = [s.scanfields{:}];
            end
            
            sfs=arrayfun(@(e) scanimage.mroi.scanfield.ScanField.loadobj(e),s.scanfields,'UniformOutput',false);
            
            for i=1:length(s.zs)
                obj.add(s.zs(i),sfs{i});
            end
            
            function loadfield(n)
                if isfield(s, n)
                    obj.(n) = s.(n);
                end
            end
        end
    end
    
    methods
       function tf = isequalish(roiA, roiB)
            if numel(roiA.scanfields) == numel(roiB.scanfields)
                tfSF = all(arrayfun(@(a,b) a.isequalish(b), roiA.scanfields, roiB.scanfields));
            else
                tfSF = false;
            end
            
            if numel(roiA.zs) == numel(roiB.zs)
                zsTF = all(roiA.zs == roiB.zs);
            else
               zsTF = false; 
            end
            
            discretePlaneTF = roiA.discretePlaneMode == roiB.discretePlaneMode;
            
            tf = tfSF && zsTF && discretePlaneTF;
       end 
        
       function h = hashgeometry(obj)
           roiHashes = arrayfun(@(r)r.hashgeometry,obj.scanfields,'UniformOutput',false);
           h = most.util.dataHash({obj.zs,roiHashes});
       end
    end
end


%--------------------------------------------------------------------------%
% Roi.m                                                                    %
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
