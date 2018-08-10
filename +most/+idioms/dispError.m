function dispError(varargin)
% DISPERROR  Show an error to the user without throwing one 
%   The main purpose of this function is to allow itself to be overriden by 
%   a testing framework. 
%   fprintf(2,...) only displays an error but does not throw any, at least on Windows,
%   This function will replace all those instances to allow tests to catch such messages
%   but still allow the user to run most of the code without halting the program.

    assert(~isempty(varargin) && ischar(varargin{1}));
    if isempty(regexp(varargin{1},'\\n$', 'once'));
        varargin{1} = [varargin{1},'\n'];
    end    
    fprintf(2, varargin{:});
end

%--------------------------------------------------------------------------%
% dispError.m                                                              %
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
