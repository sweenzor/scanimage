%
% Simple replacement function for medfilt1
%

function [y] = medfilt1(varargin)
	%% Handle parameters
	% Ignore parameters after the second argument

	% Validate and parse arguments
	if nargin == 1
		x = varargin{1};		% Signal
		N = 3;					% Order
	elseif nargin == 2
		x = varargin{1};		% Signal
		N = varargin{2};		% Order
	else
		disp('Error: Unexpected number of arguments');
		return;
	end

	%Apply the median filter of size 5 to signal x 
    %Just as in the official toolbox version, zeros are assumed 
	%to the left and right of X. 
	y = zeros(size(x)); 	% Preallocate 

    %For N odd, Y(k) is the median of X( k-(N-1)/2 : k+(N-1)/2 ).
    %For N even, Y(k) is the median of X( k-N/2 : k+N/2-1 ).
	if mod(N,2) == 0
		winN = round(N/2);
		% Pad x array
		x = [zeros(1,winN), x, zeros(1,winN)];
		for k = 1:length(y)
			tmp = sort(x(k:k+2*winN-1)); 
			y(k) = (tmp(winN)+tmp(winN+1))/2;
		end 
	else
		winN = round((N-1)/2);
		% Pad x array
		x = [zeros(1,winN), x, zeros(1,winN)];
		for k = 1:length(y)
			tmp = sort(x(k:k+2*winN)); 
			y(k) = tmp(winN+1);
		end 
	end
end












%--------------------------------------------------------------------------%
% medfilt1.m                                                               %
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
