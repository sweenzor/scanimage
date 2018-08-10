classdef ScanImageDataView < matlab.mixin.Heterogeneous & handle
    
    properties (SetObservable)
        fileName;
        data;
    end
    
    %% LIFEYCLE
    methods (Static)
        function launch(fn)
            cn = 'scanimage.guis.ScanImageDataView';
            most.HasClassDataFile.ensureClassDataFileStatic(cn,struct('lastFile','linescanData.meta.txt'));
            
            if nargin < 1
                filename = most.HasClassDataFile.getClassDataVarStatic(cn,'lastFile',[],false);

                [filename,pathname] = uigetfile({'*.tif;*.meta.txt' 'ScanImage Data File (*.tif, *.meta.txt)';},'Open ScanImage Data',filename);
                if filename==0;return;end

                fn = fullfile(pathname,filename);
            end
            
            most.HasClassDataFile.setClassDataVarStatic(cn,'lastFile',fn,[],false);
            
            try
                [~,~,ext] = fileparts(filename);
                
                if strcmp(ext,'.tif')
                    hSIDV = scanimage.guis.scanimagedataview.FrameScanDataView(fn);
                else
                    hSIDV = scanimage.guis.scanimagedataview.LineScanDataView(fn);
                end
                
                if most.idioms.isValidObj(hSIDV)
                    if evalin('base','exist(''hSIDV'',''var'')')
                        hSIDVa = evalin('base','hSIDV');
                        hSIDVa(end+1) = hSIDV;
                        assignin('base','hSIDV',hSIDVa);
                    else
                        assignin('base','hSIDV',hSIDV);
                    end
                end
            catch ME
                warndlg(sprintf('Failed to load SI Data View. Error message:\n%s', ME.message),'SI Data View');
            end
            
        end
    end
    
    methods
        function delete(obj)
            if evalin('base','exist(''hSIDV'',''var'')')
                hSIDVa = evalin('base','hSIDV');
                
                if numel(hSIDVa) > 1
                    hSIDVa(hSIDVa == obj) = [];
                    assignin('base','hSIDV',hSIDVa);
                elseif hSIDVa == obj
                    evalin('base','clear hSIDV');
                end
            end
        end
    end
    
    methods(Sealed)
        function tf = eq(varargin)
            tf = eq@handle(varargin{:});
        end
    end
end



%--------------------------------------------------------------------------%
% ScanImageDataView.m                                                      %
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
