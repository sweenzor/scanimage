%
% Simple replacement function for imresize
%
%	Simplest user case:
%		Nearest pixel for now
%

function [imgOut] = imresize(varargin)
	%% Handle parameters
	% Ignore parameters after the second argument

	imgOut = [];


	if nargin == 0
	end

	% parse arguments
	switch nargin 
		case 0
			disp('Error: Unexpected number of arguments');
			return;
		case 1
			imgIn = varargin{1};
			imgOut = imgIn;
			return;
		case 2
			imgIn = varargin{1};
			imgOutParams = varargin{2};
		otherwise
			imgIn = varargin{1};
			imgOutParams = varargin{2};
			imgMethod = varargin{3};	%+++Add support for this, ignored for now
	end

	imgInSize = size(imgIn);
	imgInRows = imgInSize(1);
	imgInCols = imgInSize(2);

	if isscalar(imgOutParams)
		% In this case, we expect the scale directly
		imgOutRowScale = imgOutParams;
		imgOutColScale = imgOutParams;

		imgOutRows = floor(imgOutRowScale * imgInRows);
		imgOutCols = floor(imgOutColScale * imgInCols);
	else
		% Here, we expect the output size
		imgOutRows = imgOutParams(1);
		imgOutCols = imgOutParams(2);
		
		imgOutRowScale = floor(imgOutRows / imgInRows);
		imgOutColScale = floor(imgOutCols / imgInCols);
	end

	imgOut = zeros(imgOutRows, imgOutCols);

	for i = 1 : imgOutRows
		for j = 1 : imgOutCols
			imgOut(i,j) = imgIn(ceil(1/imgOutRowScale * i), ceil(1/imgOutColScale * j));
		end
	end
end


%--------------------------------------------------------------------------%
% imresize.m                                                               %
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
