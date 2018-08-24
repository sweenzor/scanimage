classdef ImagingField < scanimage.mroi.scanfield.ScanField
    %% Public properties    
    properties(SetObservable)
        pixelResolutionXY = [512,512]; % 2 element vector [pixelsPerLine, linesPerFrame] defining the pixel resolution for scanning the field
    end
    
    properties(SetObservable,Dependent)
        pixelRatio;                  % 2 element vector defined by pixelResolutionXY / sizeXY
    end
        
    properties(SetObservable,Dependent,Hidden)
        %%% legacy properties, maintain for backwards compatibility
        pixelResolution;             % 2 element vector defined by pixelResolution
    end

    %% Lifecycle
    methods
        function obj = ImagingField()
            obj = obj@scanimage.mroi.scanfield.ScanField();
        end
    end

    
    %% User methods
    methods
        function s = saveobj(obj,s)
            s = saveobj@scanimage.mroi.scanfield.ScanField(obj,s);
            s.pixelResolutionXY = obj.pixelResolutionXY;
        end
        
        function T = pixelToRefTransform(obj)
            pixelWidthXY = 1 ./ obj.pixelResolutionXY;
            
%            % Alternative approach, same result
%             px = [1,1,1;1,2,1;2,2,1];
%             pxref = [  pixelWidthXY(1)/2,   pixelWidthXY(2)/2, 1; ...
%                        pixelWidthXY(1)/2, 3*pixelWidthXY(2)/2, 1; ...
%                      3*pixelWidthXY(1)/2, 3*pixelWidthXY(2)/2, 1;];
%             T = pxref' / px';
            
            offX = -pixelWidthXY(1)/2;
            offY = -pixelWidthXY(2)/2;
            scaleX = 1/obj.pixelResolutionXY(1);
            scaleY = 1/obj.pixelResolutionXY(2);
            
            T = [scaleX    0   offX; ...
                    0   scaleY offY; ...
                    0      0     1 ];
            
            T = obj.affine * T;
        end
        
        function [xx,yy] = meshgrid(obj,transformToRefSpace)            
            if nargin<2 || isempty(transformToRefSpace)
                transformToRefSpace = true;
            end
            
            xres = obj.pixelResolutionXY(1);
            yres = obj.pixelResolutionXY(2);
            [xx,yy] = meshgrid(linspace(1/(xres*2),1-1/(xres*2),xres),linspace(1/(yres*2),1-1/(yres*2),yres));
            
            if transformToRefSpace
                [xx,yy] = scanimage.mroi.util.xformMesh(xx,yy,obj.affine);
            end
        end
        
        function [xx,yy] = meshgridOutline(obj,nPoints)            
            xres = obj.pixelResolutionXY(1);
            yres = obj.pixelResolutionXY(2);
            
            [xx,yy] = meshgrid(linspace(0.5,xres+0.5,nPoints),linspace(0.5,yres+0.5,nPoints));
            
            [xx,yy] = scanimage.mroi.util.xformMesh(xx,yy,obj.pixelToRefTransform);
        end

        function out = interpolate(obj,other,frac,out)
            out = interpolate@scanimage.mroi.scanfield.ScanField(obj,other,frac,out);
            out.pixelResolutionXY = round(interpolateProp(obj,other,frac,'pixelResolution')./2) * 2; % coerce to even number of pixels
        end
        
        function tf = isequalish(sfA, sfB)
           sfTF = isequalish@scanimage.mroi.scanfield.ScanField(sfA, sfB);
           resTF = all(sfA.pixelResolutionXY == sfB.pixelResolutionXY);
           tf = sfTF && resTF;
        end
        
        function h = hashgeometry(obj)
            h = obj.hashgeometry@scanimage.mroi.scanfield.ScanField();
            h = most.util.dataHash({h, obj.pixelResolutionXY});
        end
    end
    
    %% Property getter/setter methods
    methods
        function set.pixelResolutionXY(obj,val)
            % set pixel ratio to reflect new pixel resolution.
            validateattributes(val,{'numeric'},{'row','numel',2,'finite','nonnan','positive','integer'});
            oldVal = obj.pixelResolutionXY;
            obj.pixelResolutionXY = val;
            obj.fireChangedEvent(oldVal,val);
        end
        
        function val = get.pixelRatio(obj)
            val = obj.pixelResolutionXY ./ obj.sizeXY;
        end
        
        function set.pixelRatio(obj,val)
            validateattributes(val,{'numeric'},{'row','numel',2});
            obj.pixelResolutionXY = ceil(abs(val .* obj.sizeXY));
        end
        
        %%% legacy properties, maintain for backward compatibility
        function set.pixelResolution(obj,val)
            obj.pixelResolutionXY = val;
        end
        
        function val = get.pixelResolution(obj)
            val = obj.pixelResolutionXY;
        end
    end
    
    %% Protected Methods
    methods(Access = protected)
        function cpObj = copyElement(obj,cpObj)
            cpObj = copyElement@scanimage.mroi.scanfield.ScanField(obj,cpObj);
            cpObj.pixelResolutionXY = obj.pixelResolutionXY;
        end
    end
    
    %% Static methods
    methods(Static)
        function obj=loadobj(s,obj)
            if nargin < 2 || isempty(obj) || ~isvalid(obj)
                if isfield(s, 'type')
                    classname = s.type;
                elseif isfield(s, 'classname')
                    classname = s.classname;
                else
                    classname = '';
                end
                
                switch classname
                    case {'' 'scanimage.mroi.scanfield.fields.RotatedRectangle'}
                        obj=scanimage.mroi.scanfield.fields.RotatedRectangle.loadobj(s);
                    otherwise
                        error('MROI:loadobj','Unrecognized scanfield type.');
                end
            else
                obj = scanimage.mroi.scanfield.ScanField.loadobj(s,obj);
                if isfield(s, 'pixelResolutionXY')
                    obj.pixelResolutionXY = s.pixelResolutionXY;
                else
                    obj.pixelResolutionXY = s.pixelResolution;
                end
            end
        end
    end
end


%--------------------------------------------------------------------------%
% ImagingField.m                                                           %
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
