function s = sutter_MPC200

s = struct();
s.Names = {'mpc200' 'sutter.mpc200' 'sutter.MPC200'};
s.Class = 'dabs.sutter.MPC200';
s.ListName = 'Sutter MPC200';
s.SupportFastZ = false;
s.SubType = '';
s.TwoStep.Enable = false; 
%s.TwoStep.FastLSCPropVals = struct('resolutionMode','coarse');
%s.TwoStep.SlowLSCPropVals = struct('resolutionMode','fine');
s.SafeReset = false;
s.NumDimensionsPreset = true;


%--------------------------------------------------------------------------%
% sutter_MPC200.m                                                          %
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
