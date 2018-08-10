classdef ConfigDiscriminator < most.gui.GuiElement
    properties
        hLabel;
        hPhotonDiscriminator;
    end
    
    methods
        function obj = ConfigDiscriminator(hParent,hPhotonDiscriminator)
            obj = obj@most.gui.GuiElement(hParent);
            obj.hPhotonDiscriminator = hPhotonDiscriminator;
            obj.hUIPanel.Title = 'Photon Discriminator';
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
            str = sprintf('Peak Threshold: %d\nPeak Window: %d\nDebounce: %d\nPhase: %d',...
                obj.hPhotonDiscriminator.peakThreshold,...
                obj.hPhotonDiscriminator.peakDetectionWindowSize,...
                obj.hPhotonDiscriminator.peakDebounceSamples,...
                obj.hPhotonDiscriminator.phase);
            obj.hLabel.String = str;
        end
        
        function openInputDialog(obj,varargin)
            answer = inputdlg({'Peak Threshold','Peak Detection Window Size','Peak Debounce Samples','Phase'},'Photon Discriminator Conficuration',1,...
                {num2str(obj.hPhotonDiscriminator.peakThreshold),...
                num2str(obj.hPhotonDiscriminator.peakDetectionWindowSize),...
                num2str(obj.hPhotonDiscriminator.peakDebounceSamples),...
                num2str(obj.hPhotonDiscriminator.phase)});
            if ~isempty(answer)
                try
                    obj.hPhotonDiscriminator.peakThreshold = str2double(answer{1});
                    obj.hPhotonDiscriminator.peakDetectionWindowSize = str2double(answer{2});
                    obj.hPhotonDiscriminator.peakDebounceSamples = str2double(answer{3});
                    obj.hPhotonDiscriminator.phase = str2double(answer{4});
                catch ME
                    obj.configurationChanged();
                    rethrow(ME);
                end
            end
        end
    end
end

%--------------------------------------------------------------------------%
% ConfigDiscriminator.m                                                    %
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
