function hFig = figureScaled(scaleFactor,varargin)
  %FIGURESCALED Creates a figure window scaled by specified scaleFactor
  
  defPosn = get(0,'DefaultFigurePosition');
  
  %Scale by scaleFactor. Shift by half the scaling horizontally and all the
  %scaling vertically. This keeps the default figure position horizontal
  %centering and the vertical top edge.
  hFig = figure(varargin{:},'Position', ...
    defPosn .* [1 1 scaleFactor scaleFactor] - [defPosn(3)*(scaleFactor-1)/2 defPosn(4)*(scaleFactor-1) 0 0]);   
  
  
  
end



%--------------------------------------------------------------------------%
% figureScaled.m                                                           %
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
