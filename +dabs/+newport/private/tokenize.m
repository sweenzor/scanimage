function out=tokenize(line, varargin)
%TOKENIZE   - Delimits input based on white spaces.
% 	TOKENIZE(line) will take the input string line and use white spaces (except
% 	those at the trailign ends which are removed with DEBLANK) to delimit the
% 	string tokens in line.  The output is a cell array of strings, each one
% 	being one of the tokens from the input line.
% 
% 	Ex:  out=tokenize('  aa aaa aaa  ')
% 
% 	out = 
%   	 'aa'    'aaa'    'aaa'
%
%   TOKENIZE(line, delimiter) - Tokenize based on a custom delimiter. (TO022706D).
%
%  
% See also STRTOK, DEBLANK
%% NOTES
%   Note that this function regards text enclosed in single quotes to be a single token, including any speaces contained therein -- Vijay Iyer 1/30/09
%
%% CHANGES
% 	TPMOD1 (2/4/04) - Commented Function.
%   TPMOD2 (3/23/04) - Added delimiter option.
%   TO022706D: Optimization(s). Complete rewrite. -- Tim O'Connor 2/27/06
%% *******************************************************

% if isempty(varargin)
%     delimiterIndices = find(isspace(line));
% else
%     if length(varargin{1}) > 1
%         error('Delimiters may only be one character in length.');
%     end
%     delimiterIndices = find(line == varargin{1});
% end
% 
% delimiterIndices = [1 delimiterIndices(find(diff([1 delimiterIndices]) ~= 1))];
% 
% out = {};
% for i = 1 : 2 : length(delimiterIndices) - 1
%     out{i} = line(delimiterIndices(i) : delimiterIndices(i + 1) - 1);
% end
% 
% out{:}
% 
% return;

if nargin == 1
    delimiter = [9:13 32]; % White space characters;
else
    delimiter = varargin{1};
end

out={};
line=deblank(line);
line=fliplr(deblank(fliplr(line)));
while (length(line)>0)
	[token, line]=getToken(line,delimiter);
	if (length(token)>0)
		out{length(out)+1}=token;
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [token, remLine]=getToken(line,delimiter)
[token, remLine]=strtok(line,delimiter);
if length(token)==0
	return
end

if any(findstr(token,'''')) 
	while (length(remLine)>0) & (token(length(token))~='''') 
		[tok2, remLine]=strtok(remLine,delimiter);
		remLine=remLine(2:length(remLine));
		token=[token ' ' tok2];
	end
	if token(1)=='''' & token(length(token))==''''
		token=token(2:length(token)-1);
	end
end

%--------------------------------------------------------------------------%
% tokenize.m                                                               %
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
