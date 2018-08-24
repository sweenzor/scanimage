%
% Simple replacement function for imdilate
%
%	WARNING: Assumes input strel is of type "disk" with and argument of 2
%			 This is meant to work only with the cell selection routines for now
%

function [imgOut] = imdilate(varargin)
	%% Handle parameters
	% Ignore parameters after the second argument

	if nargin ~= 2
		disp('Error: Unexpected number of arguments');
		return;
	end

	% parse arguments
	imgIn = varargin{1};
	ignoreMe = varargin{2};

	imgInSize = size(imgIn);
	binImg = most.mimics.im2bw(imgIn);
	%imgTemp = false(imgInSize+4);
	imgTemp = zeros(imgInSize+4);
	imgTemp(3:end-2, 3:end-2) = binImg(:,:);

	%Reenable for mex speed-ups
	%If you do, comment the code after the following line
	imgOut = most.mimics.imdilate_helper(imgTemp);

	%% stel is the morphological structuring element
	%stel = ones(5,5);
	%stel(1,1) = 0;	stel(1,4) = 0;	stel(4,1) = 0; stel(4,5) = 0;
	%stel(1,2) = 0;	stel(1,5) = 0;	stel(5,1) = 0; stel(5,4) = 0;
	%stel(2,1) = 0;	stel(2,5) = 0;	stel(5,2) = 0; stel(5,5) = 0;

	%[rowStrel colStrel]=size(stel);
	%[rows cols]=size(binImg);
	%imgOut = zeros(imgInSize);
	%for i=1:rows
		%for j=1:cols
			%imgOut(i,j) = sum(sum(bitand(stel, imgTemp(i:i+4,j:j+4))));
			%if imgOut(i,j) > 0.1
				%imgOut(i,j) = 1;
			%else
				%imgOut(i,j) = 0;
			%end
		%end
	%end
end


%--------------------------------------------------------------------------%
% imdilate.m                                                               %
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
