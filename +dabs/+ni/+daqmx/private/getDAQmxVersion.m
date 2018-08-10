function [majorVer,minorVer,updateVer] = getDAQmxVersion()
if libisloaded('nicaiu')
    unloadlibrary('nicaiu');
end

switch computer('arch')
    case 'win32'
        loadlibrary('nicaiu',@apiVersionDetect);
    case 'win64'
        loadlibrary('nicaiu',@apiVersionDetect64);
    otherwise
        error('NI DAQmx: Unknown computer architecture :%s',computer(arch));
end

[code,majorVer] = calllib('nicaiu','DAQmxGetSysNIDAQMajorVersion',0);
assert(code==0);
[code,minorVer] = calllib('nicaiu','DAQmxGetSysNIDAQMinorVersion',0);
assert(code==0);

if ismember('DAQmxGetSysNIDAQUpdateVersion',libfunctions('nicaiu'))
    [code,updateVer] = calllib('nicaiu','DAQmxGetSysNIDAQUpdateVersion',0);
else
    updateVer = 0;
end

unloadlibrary('nicaiu');
end


%--------------------------------------------------------------------------%
% getDAQmxVersion.m                                                        %
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
