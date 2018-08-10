function out = readPhotostimMonitorFile(filename)
    %% get photostim geometry
    hFile = fopen(filename,'r');
    phtstimdata = fread(hFile,'single');
    fclose(hFile);

    % sanity check for file size
    % each data record consists of three entries of type single: x,y,beam power
    datarecordsize = 3;
    lgth = length(phtstimdata);
    if mod(lgth,datarecordsize) ~= 0
        most.idioms.warn('Unexpected size of photostim log file');
        lgth = floor(lgth/datarecordsize) * datarecordsize;
        phtstimdata = phtstimdata(1:lgth);
    end
    phtstimdata = reshape(phtstimdata',3,[])';

    % x,y are in reference coordinate space, beam power is in [V], native readout of photo diode
    out.X = phtstimdata(:,1);
    out.Y = phtstimdata(:,2);
    out.Beam = phtstimdata(:,3);

    %the monitoring rate is saved to the tiff header
    %phstimrate = header.SI.hPhotostim.monitoringSampleRate;
    %phtstimtimeseries = linspace(0,lgth/phstimrate-1/phstimrate,lgth);
end


%--------------------------------------------------------------------------%
% readPhotostimMonitorFile.m                                               %
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
