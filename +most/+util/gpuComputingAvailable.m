function [tf,gpu] = gpuComputingAvailable()
tf = false;
gpu = [];

toolboxinstalled = most.util.parallelComputingToolboxAvailable();

if toolboxinstalled && gpuDeviceCount > 0
    try
        startTic = tic();
        gpu = gpuDevice();
        tf = true;
        duration = toc(startTic);
        if duration > 5
            url = 'https://www.mathworks.com/matlabcentral/answers/309235-can-i-use-my-nvidia-pascal-architecture-gpu-with-matlab-for-gpu-computing';
            disp(['Note: The initialization of the GPU device seems is unusually slow. Please visit this <a href = "matlab:web(''' url ''',''-browser'')">Mathworks Forum thread</a> for a solution.';]);
        end
    catch ME
        most.idioms.warn('Initializing GPU failed');
        most.idioms.reportError(ME);
    end
end
end 

%--------------------------------------------------------------------------%
% gpuComputingAvailable.m                                                  %
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
