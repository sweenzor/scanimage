function resetDaqDevices()
hSys = dabs.ni.daqmx.System();
devNames = strsplit(hSys.devNames,', ');

success = true;
fprintf('Resetting all NI-DAQ devices... \n');
for idx = 1:length(devNames)
    devname = devNames{idx};
    try
        hDev = dabs.ni.daqmx.Device(devname);
        hDev.reset();
    catch ME
        success = false;
        most.idioms.reportError(ME);
    end
end

if success
    fprintf('\bDone!\n');
end
end

%--------------------------------------------------------------------------%
% resetDaqDevices.m                                                        %
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
