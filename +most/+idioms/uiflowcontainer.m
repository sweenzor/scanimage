% uiflowcontainer
%  A stub function for calling HG uiflowcontainer()

function h = uiflowcontainer(varargin)
persistent MATLABPre2008b

if isempty(MATLABPre2008b)    
    MATLABPre2008b = verLessThan('matlab', '7.7');
end

if MATLABPre2008b
    h = uiflowcontainer(varargin{:});
else
    h = uiflowcontainer('v0', varargin{:});
end


%--------------------------------------------------------------------------%
% uiflowcontainer.m                                                        %
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
