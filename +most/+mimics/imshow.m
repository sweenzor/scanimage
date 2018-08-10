%
% Simple replacement function for imshow
% 

function [imRef] = imshow(varargin)
	%% Handle parameters
	rendParams = [];
	if nargin == 0
		disp('Error: Unexpected number of arguments');
		return;
	end

	idx = 1;
	rendParams = ['varargin{' num2str(idx) '}'];

	%% In imagesc, this should be the last argument
	if mod(nargin, 2) == 0
		idx = idx + 1;
	end

	idx = idx + 1;
	while (idx <= nargin)
		if isstr(varargin{idx}) && (strcmp(varargin{idx},'Border') || strcmp(varargin{idx},'tight'))
			idx = idx + 2; 
			% Matlab doesn't allow this in for loops, which kind of makes 
			% considering scope differences with C++
			continue;
		end
		rendParams = [rendParams  ', varargin{' num2str(idx) '}'];
		idx = idx + 1;
	end

	%if ~isempty(lastArg)
	if mod(nargin, 2) == 0
		rendParams = [rendParams  ', varargin{2}'];
	end

	eval(['imRef = imagesc(' rendParams ');']);
end


%--------------------------------------------------------------------------%
% imshow.m                                                                 %
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
