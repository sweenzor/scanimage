%	Assumes single-channel input image 
%	
%	requires a threshold as a second argument
%

function [imgOut] = im2bw(varargin)
	%% Handle parameters
	% Ignore parameters after the second argument
	if nargin == 1
		imgIn = varargin{1};
		thresh = 0.5;
	elseif nargin == 2
		imgIn = varargin{1};
		thresh = varargin{2};
	else
		disp('Most.Error: Unexpected number of arguments');
		return;
	end

	imgSize = size(imgIn);
	imgDim = length(imgSize);
	if imgDim > 2
		disp('Most.Error: Unexpected image structure');
		return;
	end

	imgOut = zeros(imgSize);
	for i = 1 : imgSize(1)
		for j = 1 : imgSize(2)
			if imgIn(i,j) > thresh
				imgOut(i,j) = 1;
			end
		end
	end
end


%--------------------------------------------------------------------------%
% im2bw.m                                                                  %
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
