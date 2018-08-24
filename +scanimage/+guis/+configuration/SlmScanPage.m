classdef SlmScanPage < scanimage.guis.configuration.ConfigurationPage
    
    properties
        scannerName;
        numChans;
        aisFixed;
        
        hShutterTable;
        hChannelTable;
        hBeamPopUp;
        hLutDevicePopUp;
        hLutChannelPopUp;
        
        tfMap = containers.Map({true false}, {'on' 'off'});
        ADAPTER_MODULE_CHANNEL_COUNT = containers.Map({'','NI5732','NI5733','NI5734','NI5751','NI517x','NI5771'},{2,2,2,4,4,4,2});
    end
    
    properties (SetObservable)
        slmTpye = '';
        slmChoices = {};
        
        acqDev = '';
        acqDaqChoices = {};
        
        digIoDev = '';
        digIoDevChoices = {};
        
        lutDev = '';
        
        linScanner = '';
        linscanChoices = {};
        
        focalLength = 100;
        zeroOrderBlockRadius = 0.01;
        updateTerm = 1;
        updatePolarity = '';
        
        galvoFeedbackDaq = '';
    end
    
    properties (Constant)
        modelClass = 'scanimage.components.scan2d.SlmScan';
    end
    
    methods
        function obj = SlmScanPage(hConfigEditor, scannerName, create)
            if nargin < 3 || isempty(create)
                create = false;
            end
            obj = obj@scanimage.guis.configuration.ConfigurationPage(hConfigEditor,create,false,sprintf('SlmScan (%s)',scannerName));
            
            ph = 600;
            obj.minimumWidth = 900;
            obj.hPanel = uipanel('parent',[],'BorderType','none','units','pixels','position',[0 0 obj.minimumWidth ph]);
            
            uicontrol(...
                'parent', obj.hPanel, ...
                'Style', 'text', ...
                'String', 'SLM Type', ...
                'HorizontalAlignment', 'left', ...
                'Units', 'pixels', ...
                'Position', [46 ph-42 100 14]);
        
            most.gui.uicontrol(...
                'parent', obj.hPanel, ...
                'Style', 'popupmenu', ...
                'String', ' ',...
                'Bindings',{{obj 'slmTpye' 'choice'} {obj 'slmChoices' 'choices'}}, ...
                'HorizontalAlignment', 'left', ...
                'Units', 'pixels', ...
                'Position', [280 ph-44 150 20]);
        
            uicontrol(...
                'parent', obj.hPanel, ...
                'Style', 'text', ...
                'String', 'Signal Acquisition DAQ', ...
                'TooltipString', 'NI DAQ board or FPGA where PMT signal is connected for acquisition.', ...
                'HorizontalAlignment', 'left', ...
                'Units', 'pixels', ...
                'Position', [46 ph-72 200 14]);
        
            most.gui.popupMenuEdit(...
                'parent', obj.hPanel, ...
                'Position', [280 ph-74 150 22],...
                'TooltipString', 'NI DAQ board or FPGA where PMT signal is connected for acquisition.', ...
                'validationFunc',@obj.validateAcqDaqChoice,...
                'Bindings',{{obj 'acqDev' 'string'} {obj 'acqDaqChoices' 'choices'}});
        
            uicontrol(...
                'parent', obj.hPanel, ...
                'Style', 'text', ...
                'String', 'Auxiliary Digital I/O DAQ', ...
                'HorizontalAlignment', 'left', ...
                'TooltipString', 'Enter the Device name of the DAQ board that is used for digital inputs/outputs (triggers/clocks etc).', ...
                'Units', 'pixels', ...
                'Position', [46 ph-102 150 14]);
        
            most.gui.popupMenuEdit(...
                'parent', obj.hPanel, ...
                'Position', [280 ph-104 150 22],...
                'validationFunc',@obj.validateDigDaqChoice, ...
                'Bindings',{{obj 'digIoDevChoices' 'choices'} {obj 'digIoDev' 'string'}},...
                'TooltipString', 'Enter the Device name of the DAQ board that is used for digital inputs/outputs (triggers/clocks etc).');
            
            uicontrol(...
                'parent', obj.hPanel, ...
                'Style', 'text', ...
                'String', 'Beam DAQ', ...
                'HorizontalAlignment', 'left', ...
                'Units', 'pixels', ...
                'Position', [46 ph-132 100 14]);
        
            obj.hBeamPopUp = uicontrol(...
                'parent', obj.hPanel, ...
                'Style', 'popupmenu', ...
                'String', ' ', ...
                'HorizontalAlignment', 'left', ...
                'Units', 'pixels', ...
                'Position', [280 ph-134 150 20]);
            
            uicontrol(...
                'parent', obj.hPanel, ...
                'Style', 'text', ...
                'String', 'LUT Calibration DAQ', ...
                'HorizontalAlignment', 'left', ...
                'Units', 'pixels', ...
                'Position', [46 ph-163 100 14]);
        
            obj.hLutDevicePopUp = uicontrol(...
                'parent', obj.hPanel, ...
                'Style', 'popupmenu', ...
                'String', ' ', ...
                'HorizontalAlignment', 'left', ...
                'Units', 'pixels', ...
                'TooltipString', 'The DAQ device used to measure intensity for LUT calibration.', ...
                'Position', [280 ph-164 150 20],...
                'Callback', @(varargin)obj.lutDeviceChanged);
            
            uicontrol(...
                'parent', obj.hPanel, ...
                'Style', 'text', ...
                'String', 'LUT Calibration Channel', ...
                'HorizontalAlignment', 'left', ...
                'Units', 'pixels', ...
                'Position', [46 ph-193 100 14]);
        
            obj.hLutChannelPopUp = uicontrol(...
                'parent', obj.hPanel, ...
                'Style', 'popupmenu', ...
                'String', ' ', ...
                'HorizontalAlignment', 'left', ...
                'Units', 'pixels', ...
                'TooltipString', 'The channel on the DAQ device to be used to measure intensity for LUT calibration.', ...
                'Position', [280 ph-194 150 20]);
            
            uicontrol(...
                'parent', obj.hPanel, ...
                'Style', 'text', ...
                'String', 'If the SLM is in a beam path in series with a galvo pair, enter the associated scanner name (the galvo pair should be configured separately as a another scanning system).',...
                'HorizontalAlignment', 'left', ...
                'fontsize',10,...
                'Units', 'pixels', ...
                'Position', [46 ph-253 400 48]);
            
            uicontrol(...
                'parent', obj.hPanel, ...
                'Style', 'text', ...
                'String', 'Linear Scanner Name', ...
                'HorizontalAlignment', 'left', ...
                'Units', 'pixels', ...
                'Position', [46 ph-280 100 14]);
        
            most.gui.popupMenuEdit(...
                'parent', obj.hPanel, ...
                'HorizontalAlignment', 'left', ...
                'validationFunc',@obj.validateLinscanChoice, ...
                'Bindings',{{obj 'linscanChoices' 'choices'} {obj 'linScanner' 'string'}},...
                'Position', [280 ph-284 150 22]);
            
            uicontrol(...
                'parent', obj.hPanel, ...
                'Style', 'text', ...
                'String', 'Select shutters that must be open when using this scanner.', ...
                'HorizontalAlignment', 'left', ...
                'Units', 'pixels', ...
                'Position', [518 ph-37 300 14]);
            
            obj.hShutterTable = uitable( ... 
                'parent', obj.hPanel, ...
                'Tag', 'ShutterTable', ...
                'ColumnName', {'Select', 'Shutter Device'}, ...
                'ColumnFormat', {'logical', 'char'}, ...
                'ColumnEditable', [true, false], ...
                'ColumnWidth', {50, 210}, ...
                'Data',{},...
                'RowName', [], ...
                'RowStriping', 'Off', ...
                'Units', 'pixels', ...
                'Position', [518 ph-142 284 100]);
            
            uicontrol(...
                'parent', obj.hPanel, ...
                'Style', 'text', ...
                'String', 'Select DAQ channels and and indicate those with an inverted PMT signal.', ...
                'HorizontalAlignment', 'left', ...
                'Units', 'pixels', ...
                'Position', [518 ph-180 380 14]);
            
            obj.hChannelTable = uitable( ... 
                'parent', obj.hPanel, ...
                'ColumnName', {'DAQ Channel', 'Invert'}, ...
                'ColumnFormat', {'char', 'logical'}, ...
                'ColumnEditable', [false, true], ...
                'ColumnWidth', {110 50}, ...
                'RowName', {}, ...
                'Data', {}, ...
                'RowStriping', 'Off', ...
                'Units', 'pixels', ...
                'Position', [518 ph-284 284 100]);
            
            uicontrol(...
                'parent', obj.hPanel, ...
                'Style', 'text', ...
                'String', 'Effective Focal Length', ...
                'HorizontalAlignment', 'left', ...
                'TooltipString', 'Effective focal length of the optical path', ...
                'Units', 'pixels', ...
                'Position', [46 ph-327 189 14]);
        
            most.gui.uicontrol(...
                'parent', obj.hPanel, ...
                'Style', 'edit', ...
                'HorizontalAlignment', 'center', ...
                'Bindings',{obj 'focalLength' 'value'},...
                'TooltipString', 'Effective focal length of the optical path', ...
                'Units', 'pixels', ...
                'Position', [280 ph-331 50 22]);
            
            uicontrol(...
                'parent', obj.hPanel, ...
                'Style', 'text', ...
                'String', 'Zero Order Beam Block Raduis', ...
                'HorizontalAlignment', 'left', ...
                'TooltipString', 'Radius of area at center of SLM FOV that cannot be excited, usually due to presence of zero-order beam block. Expressed as a percentage of the overall FOV.', ...
                'Units', 'pixels', ...
                'Position', [46 ph-374 189 14]);
        
            most.gui.uicontrol(...
                'parent', obj.hPanel, ...
                'Style', 'edit', ...
                'HorizontalAlignment', 'center', ...
                'Bindings',{obj 'zeroOrderBlockRadius' 'value'},...
                'TooltipString', 'Radius of area at center of SLM FOV that cannot be excited, usually due to presence of zero-order beam block. Expressed as a percentage of the overall FOV.', ...
                'Units', 'pixels', ...
                'Position', [280 ph-378 50 22]);

            uicontrol(...
                'parent', obj.hPanel, ...
                'Style', 'text', ...
                'String', 'SLM Update Trigger Input Terminal', ...
                'HorizontalAlignment', 'left', ...
                'TooltipString', '', ...
                'Units', 'pixels', ...
                'Position', [46 ph-421 198 14]);
        
            most.gui.uicontrol(...
                'parent', obj.hPanel, ...
                'Style', 'popupmenu', ...
                'String', [{'None'}; arrayfun(@(x){sprintf('PFI%d',x)},(0:15)')], ...
                'HorizontalAlignment', 'left', ...
                'Bindings',{obj 'updateTerm' 'value'},...
                'TooltipString', '', ...
                'Units', 'pixels', ...
                'Position', [280 ph-425 50 20]);

            uicontrol(...
                'parent', obj.hPanel, ...
                'Style', 'text', ...
                'String', 'SLM Update Trigger Signal Polarity', ...
                'HorizontalAlignment', 'left', ...
                'TooltipString', '', ...
                'Units', 'pixels', ...
                'Position', [46 ph-468 198 14]);
        
            most.gui.uicontrol(...
                'parent', obj.hPanel, ...
                'Style', 'popupmenu', ...
                'String', {'Rising' 'Falling'}, ...
                'HorizontalAlignment', 'left', ...
                'TooltipString', '', ...
                'Bindings',{obj 'updatePolarity' 'choice'},...
                'Units', 'pixels', ...
                'Position', [280 ph-471 60 20]);
        
%             obj.hConfigEditor.addSimRio();
            obj.reload(scannerName);
        end
        
        function delete(~)
        end
        
        function refreshPageDependentOptions(obj)
            vs = obj.hConfigEditor.hSlmRegistry.values;
            vs = [vs{:}];
            obj.slmChoices = unique({vs.DisplayName});
            
            sigAcqChcs = obj.hConfigEditor.availableDaqs;
            if ~isempty(obj.hConfigEditor.rioChoices)
                sigAcqChcs = [sigAcqChcs; obj.hConfigEditor.rioChoices];
            end
            obj.acqDaqChoices = sigAcqChcs;
            
            isXSer = [];
            if ~isempty(obj.hConfigEditor.availableDaqs)
                isXSer = [obj.hConfigEditor.daqInfo.isXSer];
            end
            obj.digIoDevChoices = [{'None'}; obj.hConfigEditor.availableDaqs(isXSer)];
            
            
            % update shutter options while preserving selected options
            shutterIDs = [];
            if ~isempty(obj.hShutterTable.Data)
                shutterIDs = find([obj.hShutterTable.Data{:,1}]);
            end
            
            shutters = obj.hConfigEditor.shutterNames;
            shutterDat = [repmat({false},numel(shutters),1) shutters];
            obj.hShutterTable.Data = shutterDat;
            
            if ~isempty(shutterIDs)
                shutterIDs(shutterIDs > numel(shutters)) = [];
                obj.hShutterTable.Data(:,1) = {false};
                obj.hShutterTable.Data(shutterIDs,1) = {true};
            end
            
            scannerNames = obj.hConfigEditor.scannerNames()';
            obj.linscanChoices = [{'None'} scannerNames(cellfun(@(x)strcmp(x,'Linear'),obj.hConfigEditor.scannerTypes))];
            
            str = [{'None'} obj.hConfigEditor.beamDaqNames];
            v = min(numel(str),obj.hBeamPopUp.Value);
            obj.hBeamPopUp.String = str;
            obj.hBeamPopUp.Value = v;
        end
        
        function reload(obj,scannerName)
            if nargin > 1
                obj.scannerName = scannerName;
                obj.listLabel = ['Scanner Settings (' scannerName ')'];
                obj.heading = ['SlmScan (' scannerName ')'];
                obj.descriptionText = ['Configure DAQ settings and optical parameters for the ''' scannerName ''' SLM system. Previously configured beam DAQs and shutters can be assigned to this SLM.'...
                    ' You can also specify that the SLM shares a light path with a linear scan system.'];
            end
            obj.refreshPageDependentOptions();
            
            % reload the settings
            mdfData = obj.getCurrentMdfDataStruct();
            
            if ~isempty(mdfData.slmType)
                obj.slmTpye = obj.hConfigEditor.hSlmRegistry(lower(mdfData.slmType)).DisplayName;
            else
                obj.slmTpye = 'Generic Monitor SLM';
            end
            
            if ~isempty(mdfData.beamDaqID) && mdfData.beamDaqID <= obj.hConfigEditor.numBeamDaqs
                obj.hBeamPopUp.Value = mdfData.beamDaqID+1;
            else
                obj.hBeamPopUp.Value = 1;
            end
            
            if isempty(mdfData.deviceNameAcq)
                obj.acqDev = '';
            else
                obj.acqDev = mdfData.deviceNameAcq;
            end
            
            mdfData.channelsInvert(end+1:obj.numChans) = mdfData.channelsInvert(1);
            mdfData.channelsInvert(obj.numChans+1:end) = [];
            obj.hChannelTable.Data(:,2) = num2cell(mdfData.channelsInvert(:));
            
            if ~obj.aisFixed
                chIds = 0:obj.numChans-1;
                ns = 1:min(numel(mdfData.channelIDs),obj.numChans);
                chIds(ns) = mdfData.channelIDs(ns);
                obj.hChannelTable.Data(:,1) = arrayfun(@(x)sprintf('AI%d',x),chIds,'uniformoutput',false);
            end
            
            obj.digIoDev = mdfData.deviceNameAux;
            
            mdfData.shutterIDs(mdfData.shutterIDs > obj.hConfigEditor.numShutters) = [];
            obj.hShutterTable.Data(:,1) = {false};
            obj.hShutterTable.Data(mdfData.shutterIDs,1) = {true};
            
            obj.linScanner = mdfData.linearScannerName;
            if isempty(obj.linScanner)
                obj.linScanner = 'None';
            end
            
            obj.focalLength = mdfData.focalLength;
            obj.zeroOrderBlockRadius = mdfData.zeroOrderBlockRadius;
            
            v = mdfData.slmUpdateTriggerInputTerm;
            if (length(v) > 3) && all(ischar(v)) && strncmp(v,'PFI',3) && ~isnan(str2double(v(4:end)))
                obj.updateTerm = str2double(v(4:end)) + 2;
            else
                obj.updateTerm = 1;
            end
            
            if strcmp(mdfData.slmUpdateTriggerPolarity, 'rising')
                obj.updatePolarity = 'Rising';
            else
                obj.updatePolarity = 'Falling';
            end
            
            obj.hLutDevicePopUp.String = [{''};obj.hConfigEditor.availableDaqs];
            obj.lutDev = mdfData.lutCalibrationDaqDevice;
            numAOs = numel(obj.hLutChannelPopUp.String);
            if ~isempty(mdfData.lutCalibrationChanID)
                obj.hLutChannelPopUp.Value = max(min(mdfData.lutCalibrationChanID+1,numAOs),1);
            else
                mdfData.lutCalibrationChanID = 1;
            end
        end
        
        function s = getNewVarStruct(obj)
            s = struct();
            
            s.slmType = obj.hConfigEditor.slmName2RegMap(obj.slmTpye);
            
            s.beamDaqID = obj.hBeamPopUp.Value - 1;
            if s.beamDaqID < 1
                s.beamDaqID = [];
            end
            
            s.shutterIDs = find([obj.hShutterTable.Data{:,1}]);
            if isempty(s.shutterIDs)
                s.shutterIDs = [];
            end
            
            if ~obj.aisFixed
                s.channelIDs = str2double(strrep(obj.hChannelTable.Data(:,1),'AI',''))';
            else
                s.channelIDs = [];
            end
            
            s.channelsInvert = [obj.hChannelTable.Data{:,2}];
            
            s.deviceNameAux = obj.digIoDev;
            
            rio = strsplit(obj.acqDev,' (');
            if strncmp(rio{1},'RIO',3)
                s.deviceNameAcq = rio{1};
                if isempty(strfind(rio{2},'not found'))
                    fpgaDig = strsplit(strrep(rio{2},')',''),',');
                    s.fpgaModuleType = fpgaDig{1};
                    if numel(fpgaDig) > 1
                        s.digitizerModuleType = strtrim(fpgaDig{2});
                    else
                        if strncmp(s.fpgaModuleType,'NI5171',6)
                            s.fpgaModuleType = 'NI5171';
                        end
                        s.digitizerModuleType = '';
                    end
                else
                    s.fpgaModuleType = 'NI7961';
                    s.digitizerModuleType = 'NI5732';
                end
            else
                s.deviceNameAcq = obj.acqDev;
            end
            
            s.focalLength = obj.focalLength;
            s.zeroOrderBlockRadius = obj.zeroOrderBlockRadius;
            
            s.linearScannerName = obj.linScanner;
            if strcmp(s.linearScannerName, 'None')
                s.linearScannerName = '';
            end
            
            if obj.updateTerm > 1
                s.slmUpdateTriggerInputTerm = sprintf('PFI%d',obj.updateTerm-2);
            else
                s.slmUpdateTriggerInputTerm = '';
            end
            
            if obj.updatePolarity == 1
                s.slmUpdateTriggerPolarity = 'rising';
            else
                s.slmUpdateTriggerPolarity = 'falling';
            end
            
            s.lutCalibrationDaqDevice = obj.lutDev;
            if isempty(obj.lutDev)
                s.lutCalibrationChanID = [];
            else
                s.lutCalibrationChanID = obj.hLutChannelPopUp.Value-1;
            end
        end
        
        function [lvl,v,errMsg] = validateAcqDaqChoice(obj,v,oldV)
            errMsg = '';
            lvl = ~ismember(v,obj.acqDaqChoices);
            if lvl > 0
                errMsg = 'Error: must be a valid X series DAQ name or FPGA RIO ID.';
            end
        end
        
        function [lvl,v,errMsg] = validateDigDaqChoice(obj,v,oldV)
            errMsg = '';
%             if ~isvarname(v);
%                 v = oldV;
%             end
            lvl = ~ismember(v,obj.digIoDevChoices);
            if lvl > 0
                errMsg = 'Error: must be a valid X series DAQ name.';
            end
        end
        
        function [lvl,v,errMsg] = validateLinscanChoice(obj,v,~)
            errMsg = '';
            v = matlab.lang.makeValidName(v);
            lvl = 1 - ismember(v,obj.linscanChoices);
            if lvl > 0
                errMsg = 'Error: must be a valid linear scanner name';
            end
        end
        
        function lutDeviceChanged(obj)
            obj.lutDev = obj.hLutDevicePopUp.String{obj.hLutDevicePopUp.Value};
        end
    end
    
    %% prop access
    methods
        function set.acqDev(obj, v)
            [tf,idx] = ismember(v,obj.hConfigEditor.availableDaqs);
            if tf
                obj.numChans = min(4,obj.hConfigEditor.daqInfo(idx).numAIs);
                obj.aisFixed = false;
                numAvailChans = obj.hConfigEditor.daqInfo(idx).numAIs;
            else
                rio = strsplit(v,' ');
                rio = rio{1};
                
                if isfield(obj.hConfigEditor.rioInfo, rio)
                    am = obj.hConfigEditor.rioInfo.(rio).adapterModule;
                    am = regexp(am,'^[^()]+','match','once');
                    if ismember(am,obj.ADAPTER_MODULE_CHANNEL_COUNT.keys)
                        obj.numChans = obj.ADAPTER_MODULE_CHANNEL_COUNT(am);
                    else
                        obj.numChans = 0;
                    end
                    obj.aisFixed = true;
                    
                    idx = find(strncmp(rio, obj.acqDaqChoices, length(rio)),1);
                    if ~isempty(idx)
                        v = obj.acqDaqChoices{idx};
                    end
                else
                    obj.numChans = 1;
                    obj.aisFixed = true;
                    v = [v ' (not found)'];
                end
            end
            
            obj.acqDev = v;
            
            % update channel table
            if obj.numChans
                dat = obj.hChannelTable.Data;
                dat(end+1:obj.numChans,2) = {false};
                dat(obj.numChans+1:end,:) = [];
                
                if obj.aisFixed
                    obj.hChannelTable.ColumnEditable = [false true];
                    obj.hChannelTable.ColumnFormat = {'char' 'logical'};
                    dat(:,1) = arrayfun(@(x)sprintf('AI%d',x),0:(obj.numChans-1),'uniformoutput',false);
                else
                    obj.hChannelTable.ColumnEditable = [true true];
                    obj.hChannelTable.ColumnFormat = {arrayfun(@(x)sprintf('AI%d',x),0:(numAvailChans-1),'uniformoutput',false) 'logical'};
                    dat(:,1) = arrayfun(@(x)sprintf('AI%d',x),0:(obj.numChans-1),'uniformoutput',false);
                end
                
                obj.hChannelTable.RowName = arrayfun(@(x)sprintf('Channel %d',x),1:obj.numChans,'uniformoutput',false);
            else
                dat = {};
                obj.hChannelTable.RowName = dat;
            end
            obj.hChannelTable.Data = dat;
        end
        
        function set.lutDev(obj,v)
            [tf,idx] = ismember(v,obj.hConfigEditor.availableDaqs);
            if tf
                obj.lutDev = v;
                ais = obj.hConfigEditor.daqInfo(idx).allAIs;
                obj.hLutChannelPopUp.String = ais;
                obj.hLutChannelPopUp.Value = 1;
            else
                obj.lutDev = '';
                obj.hLutChannelPopUp.String = {''};
                obj.hLutChannelPopUp.Value = 1;
            end
        end
    end
end


%--------------------------------------------------------------------------%
% SlmScanPage.m                                                            %
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
