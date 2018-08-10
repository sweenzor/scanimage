function s = newport_xps

s = struct();
s.Names = {'newport.xps'};
s.Class = 'dabs.newport.XPS';
s.ListName = 'Newport XPS';
s.SupportFastZ = false;
s.SubType = '';
s.TwoStep.Enable = true;
s.TwoStep.FastLSCPropVals = struct(); %Velocity is switched between fast/slow, but determined programatically for each stage type
s.TwoStep.SlowLSCPropVals = struct(); %Velocity is switched between fast/slow, but determined programatically for each stage type
s.TwoStep.InitSlowLSCProps = false;
s.SafeReset = false;
s.NumDimensionsPreset = true;


%--------------------------------------------------------------------------%
% newport_xps.m                                                            %
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
