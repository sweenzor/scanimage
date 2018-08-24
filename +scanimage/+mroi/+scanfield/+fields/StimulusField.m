classdef StimulusField < scanimage.mroi.scanfield.ScanField
    %% Abstract property realization scanimage.mroi.scanfield.ScanField    
    properties (SetAccess = protected, Dependent)
        shortDescription;
    end

    %% Class properties
    properties (SetObservable)
        stimfcnhdl = @scanimage.mroi.stimulusfunctions.logspiral; % function handle to parametric function that defines stimulus path
        stimparams = {};     % cell array of additional parameter name/value tuples to be passed into stimfcnhdl {'revolutions',5,}

        beamsfcnhdl = @scanimage.mroi.stimulusbeamfunctions.beamPowers; % function handle to parametric function that defines stimulus beam powers (for power users)
        
        duration = 0.01;     % time (seconds) the stimulus will take
        repetitions = 1;     % number of repetitions of the stimulus
        powers = 10;         % array of power of each beam in percent
        slmPattern = [];     % [Nx3] array of points or [NxM] bitmap to generate with SLM during this stimulus function
        zSpan = 0;           % depth scaling for the z coordinate of 3D stimfcn
    end
    
    properties (SetObservable, Dependent, Hidden)
        %%% legacy properties, maintain for backward compatibility
        scalingXY;           % [x,y] scaling of the stimulus in reference coordinates
    end
    
    properties(Hidden)
        % for performance;
        isPause = false;
        isPark = false;
        isPoint = false;
        isWayPoint = false;
    end
    
    %% Lifecycle
    methods
        function obj = StimulusField(stimfcnhdl,stimparams,duration,repetitions,...
                centerXY,scalingXY,rotationDegrees,powers,zSpan)
            obj = obj@scanimage.mroi.scanfield.ScanField();
            
            if nargin > 0 && ~isempty(stimfcnhdl)
                obj.stimfcnhdl = stimfcnhdl;
            end
            
            if nargin > 1 && ~isempty(stimparams)
                obj.stimparams = stimparams;
            end
            
            if nargin > 2 && ~isempty(duration)
                obj.duration = duration;
            end
            
            if nargin > 3 && ~isempty(repetitions)
                obj.repetitions = repetitions;
            end
            
            if nargin > 4 && ~isempty(scalingXY)
                obj.centerXY = centerXY;
            end
            
            if nargin > 5 && ~isempty(scalingXY)
                obj.scalingXY = scalingXY;
            end
            
            if nargin > 6 && ~isempty(rotationDegrees)
                obj.rotationDegrees = rotationDegrees;
            end
            
            if nargin > 7
                obj.powers = powers; 
            end
            
            if nargin > 8
                obj.zSpan = zSpan;
            end
        end
    end
    
    %% Abstract methods realization of scanimage.mroi.scanfield.ScanField
    methods        
        function rect = boundingbox(obj)
            disp('Todo: scanimage.mroi.scanfield.fields.StimulusField.boundingbox: implement this properly');
            rect = [];
        end
        
        function pts = cornerpoints(obj)
            pts = [-1,-1;1,-1;1,1;-1,1];
            pts = scanimage.mroi.util.xformPoints(pts,obj.affine);
        end
        
        function [xs,ys]=transform(obj,xs,ys)            
            %% Transforms points from unit-scan space to fov space
            [xs,ys] = scanimage.mroi.util.xformPointsXY(xs,ys,obj.affine);
        end
        
        function setByAffineParams(obj, p)
            most.idioms.warn('TODO: Implement setByAffineParams for StimulusField');
        end
        
        function T=affine(obj)
            % Returns the affine transform
            
            % scaling
            S=diag([obj.sizeXY/2 1]);
            
            % rotation
            R=eye(3);
            radians = obj.rotation*pi/180;
            c = cos(radians);
            s = sin(radians);
            R(1:2,1:2) = [c -s; s c];
            
            % translation
            C=eye(3);
            C(:,3)=[obj.centerXY 1];
            
            T = C*R*S;
        end
    end
    
    %% Public methods
    methods
        function out = interpolate(obj,other,frac)
            assert(strcmp(func2str(obj.stimfcnhdl),func2str(other.stimfcnhdl)),...
                  ['Cannot interpolate scanfields %s and %s.',...
                   'The scanfields use different stimulus path generation functions: %s   vs.   %s'],...
                   func2str(obj.stimfcnhdl),func2str(other.stimfcnhdl));
                
            assert(strcmp(func2str(obj.beamsfcnhdl),func2str(other.beamsfcnhdl)),...
                  ['Cannot interpolate scanfields %s and %s.',...
                   'The scanfields use different stimulus beam power generation functions: %s   vs.   %s'],...
                   func2str(obj.beamsfcnhdl),func2str(other.beamsfcnhdl));
            
            out = scanimage.mroi.scanfield.fields.StimulusField();
            out = interpolate@scanimage.mroi.scanfield.ScanField(obj,other,frac,out);
                
            out.stimfcnhdl = obj.stimfcnhdl;
            out.beamsfcnhdl = obj.beamsfcnhdl;
            out.stimparams = obj.stimparams;
            
            out.duration = interpolateProp(obj,other,frac,'duration');
            out.repetitions = interpolateProp(obj,other,frac,'repetitions');
            out.powers = interpolateProp(obj,other,frac,'powers');
            out.zSpan = interpolateProp(obj,other,frac,'zSpan');
        end
        

        function s = saveobj(obj)
            s = struct();
            s = saveobj@scanimage.mroi.scanfield.ScanField(obj,s);
            
            s.stimulusFunction = func2str(obj.stimfcnhdl);
            s.stimparams = obj.stimparams;
            s.duration = obj.duration;
            s.repetitions = obj.repetitions;
            s.powers = obj.powers;
            s.zSpan = obj.zSpan;
            s.beamsFunction = func2str(obj.beamsfcnhdl);
            s.slmPattern = obj.slmPattern;
        end
        
        function recenterGalvoOntoSlmPattern(obj)
            if isempty(obj.slmPattern)
                return
            end
            
            if size(obj.slmPattern,2)>4
                % obj.slmPattern appears to be an image, not a set of
                % points
                return
            end
            
            % slmPattern is relative to obj.centerXY
            slmPatternXY = bsxfun(@plus,obj.slmPattern(:,1:2),obj.centerXY); % convert to absolute coordinates
            if size(obj.slmPattern,2)<4
                weights = ones(size(obj.slmPattern(1),1));
            else
                weights = obj.slmPattern(:,4);
            end
            
            % calculate center of mass
            slmPatternCenterXY = bsxfun(@times,slmPatternXY,weights);
            slmPatternCenterXY = sum(slmPatternCenterXY,1) / sum(weights,1);
            
            obj.slmPattern(:,1:2) = bsxfun(@minus,slmPatternXY,slmPatternCenterXY);
            obj.centerXY = slmPatternCenterXY;
        end
    end
    
    %% Protected methods
    methods (Access = protected)
        function cpObj = copyElement(obj)
            cpObj = scanimage.mroi.scanfield.fields.StimulusField();
            cpObj = copyElement@scanimage.mroi.scanfield.ScanField(obj,cpObj);
            
            cpObj.stimfcnhdl = obj.stimfcnhdl;
            cpObj.stimparams = obj.stimparams;
            cpObj.duration = obj.duration;
            cpObj.repetitions = obj.repetitions;
            cpObj.powers = obj.powers;
            cpObj.beamsfcnhdl = obj.beamsfcnhdl;
            cpObj.slmPattern = obj.slmPattern;
            cpObj.zSpan = obj.zSpan;
        end
    end
    
    %% Static methods
    methods(Static)
        function obj=loadobj(s)
            obj=scanimage.mroi.scanfield.fields.StimulusField();
            obj=scanimage.mroi.scanfield.ScanField.loadobj(s,obj);
                      
            if isfield(s,'stimfcnhdl') ; obj.stimfcnhdl =str2func(s.stimfcnhdl) ; end
            if isfield(s,'stimparams') ; obj.stimparams =s.stimparams           ; end
            if isfield(s,'beamsfcnhdl'); obj.beamsfcnhdl=str2func(s.beamsfcnhdl); end            
            if isfield(s,'duration')   ; obj.duration   =s.duration             ; end
            if isfield(s,'repetitions'); obj.repetitions=s.repetitions          ; end
            if isfield(s,'powers')     ; obj.powers     =s.powers               ; end
            if isfield(s,'slmPattern') ; obj.slmPattern =s.slmPattern           ; end
            if isfield(s,'zSpan')      ; obj.zSpan      =s.zSpan                ; end
            
            %%% maintain compatbility with legacy properties
            if isfield(s,'stimulusFunction')      ; obj.stimfcnhdl =str2func(s.stimulusFunction); end
            if isfield(s,'stimulusFunctionParams'); obj.stimparams =s.stimulusFunctionParams    ; end
            if isfield(s,'beamsFunction')         ; obj.beamsfcnhdl=str2func(s.beamsFunction)   ; end
        end
    end
    
    %% Property setters / getters
    methods
        function val = get.shortDescription(obj)
            if isempty(obj.stimfcnhdl)
                stimfcnname = [];
            else
                stimfcnname = regexp(func2str(obj.stimfcnhdl),'[^.]*$','match','once');
            end
            val = sprintf('Stim: %s',stimfcnname);
        end
        
        function set.stimfcnhdl(obj,val)
            if isa(val,'char')
                val = str2func(val);
            end
            
            obj.stimfcnhdl = val;
            obj.isPause = strcmp(func2str(val),'scanimage.mroi.stimulusfunctions.pause');
            obj.isPark = strcmp(func2str(val),'scanimage.mroi.stimulusfunctions.park');
            obj.isWayPoint = strcmp(func2str(val),'scanimage.mroi.stimulusfunctions.waypoint');
            obj.isPoint = strcmp(func2str(val),'scanimage.mroi.stimulusfunctions.point') || obj.isWayPoint;
            obj.fireChangedEvent();
        end
        
        function set.stimparams(obj,val)
            if isa(val,'string')
                val = cellstr(val);
            end
            assert(iscell(val)&&size(val,1)<=1&&~mod(length(val),2),...
                'Expect stimparams to be a cell row vector with an even number of elements');
            obj.stimparams = val;
            obj.fireChangedEvent();
        end
        
        function set.beamsfcnhdl(obj,val)
            obj.beamsfcnhdl = val;
            obj.fireChangedEvent();
        end
        
        function set.duration(obj,val)
            obj.duration = val;
            obj.fireChangedEvent();
        end
        
        function set.repetitions(obj,val)
            obj.repetitions = val;
            obj.fireChangedEvent();
        end
        
        function set.powers(obj,val)
            obj.powers = val;
            obj.fireChangedEvent();
        end
        
        %%% legacy properties, maintain for backward compatibility
        function set.scalingXY(obj,val)
            % stim normally ranges from -scalingXY to scalingXY 
            % so size is 2*scalingXY
            validateattributes(val,{'numeric'},{'vector','numel',2});
            
            obj.sizeXY = val .* 2;
        end
        
        function val=get.scalingXY(obj)
            val = obj.sizeXY ./ 2;
        end
        
        function set.slmPattern(obj,val)
            obj.slmPattern = val;
            obj.fireChangedEvent();
        end
        
        function set.zSpan(obj,val)
            validateattributes(val,{'numeric'},{'scalar','finite','nonnan'});
            obj.zSpan = val;
            obj.fireChangedEvent();
        end
    end
end


%--------------------------------------------------------------------------%
% StimulusField.m                                                          %
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
