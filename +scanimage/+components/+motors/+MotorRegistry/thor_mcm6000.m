function s = thor_mcm6000

s = struct();
s.Names = {'mcm6000' 'thorlabs.mcm6000'};
s.Class = 'dabs.thorlabs.MCM6000';
s.ListName = 'Thorlabs MCM6000';
s.SupportFastZ = false;
s.SubType = '';
s.TwoStep.Enable = false;
s.SafeReset = true;
s.NumDimensionsPreset = true;

%--------------------------------------------------------------------------%
% thor_mcm6000.m                                                           %
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
