function s = thor_pfm450

s = struct();
s.Names = {'thorlabs.pfm450' 'pfm450'};
s.Class = 'dabs.thorlabs.PFM450';
s.ListName = 'Thorlabs PFM450';
s.SupportFastZ = true;
s.SubType = '';
s.TwoStep.Enable = false; 
s.SafeReset = false;
s.NumDimensionsPreset = true;


%--------------------------------------------------------------------------%
% thor_pfm450.m                                                            %
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
