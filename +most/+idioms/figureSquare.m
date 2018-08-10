function hFig = figureSquare(varargin)
%FIGURESQUARE Creates a square figure window

defPosn = get(0,'DefaultFigurePosition');
squareSize = mean(defPosn(3:4));
squarePosn = [defPosn(1)+(defPosn(3)-squareSize) defPosn(2)+(defPosn(4)-squareSize) squareSize squareSize];
hFig = figure(varargin{:},'Position',squarePosn);



end



%--------------------------------------------------------------------------%
% figureSquare.m                                                           %
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
