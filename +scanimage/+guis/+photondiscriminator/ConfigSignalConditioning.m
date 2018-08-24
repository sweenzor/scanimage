classdef ConfigSignalConditioning < most.gui.GuiElement
    properties
        hLabel;
        hPhotonDiscriminator;
    end
    
    methods
        function obj = ConfigSignalConditioning(hParent,hPhotonDiscriminator)
            obj = obj@most.gui.GuiElement(hParent);
            obj.hPhotonDiscriminator = hPhotonDiscriminator;
            obj.hUIPanel.Title = 'Signal Conditioning';
            obj.init();
        end
        
        function delete(obj)
            most.idioms.safeDeleteObj(obj.hLabel);
        end
        
        function init(obj)
            most.idioms.safeDeleteObj(obj.hLabel);
            obj.hLabel = uicontrol('Parent',obj.hUIPanel,'Style','text','HorizontalAlignment','left','Enable','inactive','ButtonDownFcn',@obj.openInputDialog);
            obj.panelResized();
            
            obj.configurationChanged();
        end
            
        function scrollWheelFcn(obj,varargin)
           % No-Op 
        end
    end
    
    methods
        function configurationChanged(obj)
            obj.updateLabelString();
        end
        
        function panelResized(obj)
            panelPos = obj.getPositionInUnits('pixel');
            obj.hLabel.Units = 'pixel';
            padding = 15;
            obj.hLabel.Position = [padding padding panelPos(3:4)-3*padding];
        end
        
        function str = updateLabelString(obj)
            str = sprintf('Scale: 2^%d\nOffset: %d\nDifferentiate: %d',...
                          obj.hPhotonDiscriminator.rawDataScaleByPowerOf2,...
                          obj.hPhotonDiscriminator.staticNoise(1),...
                          obj.hPhotonDiscriminator.differentiate);
            obj.hLabel.String = str;
        end
        
        function openInputDialog(obj,varargin)
            answer = inputdlg({'Scale 2^x' 'Offset' 'Differentiate'},'Signal Conditioning',1,...
                {num2str(obj.hPhotonDiscriminator.rawDataScaleByPowerOf2),...
                num2str(obj.hPhotonDiscriminator.staticNoise),...
                num2str(obj.hPhotonDiscriminator.differentiate)});
            if ~isempty(answer)
                try
                    obj.hPhotonDiscriminator.rawDataScaleByPowerOf2 = str2double(answer{1});
                    obj.hPhotonDiscriminator.staticNoise = str2double(answer{2});
                    obj.hPhotonDiscriminator.differentiate = str2double(answer{3});
                catch ME
                    most.idioms.rethrowMsgDlg(ME);
                end
            end
        end
    end
end

%--------------------------------------------------------------------------%
% ConfigSignalConditioning.m                                               %
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
