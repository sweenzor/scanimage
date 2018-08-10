function pauseTight(delayInterval)
%PAUSETIGHT A command that completely blocks Matlab execution access for specified delay. Unlike the built-in pause() command, callbacks are also prevented from firing.
%
%% NOTES
%   The pauseTight() function is primarily intended as a fully blocking delay, in contrast to the built-in pause() command, which allows callbacks to fire.
%   This function can be useful when polling hardware -- i.e. as a means for airtight polling for a hardware event without talking to the hardware at a very high rate
%
%% CHANGES
%   VI041111A: Handle case of empty delayInterval value as specifying no delay (matches native pause() behavior)
%
%% CREDITS
%   Created 3/30/10, by Vijay Iyer
%% ******************************************************

h1 = tic();

%%%VI041111A
if isempty(delayInterval)
    return;
end

while true
    if toc(h1) > delayInterval
        break;
    end
end

end



%--------------------------------------------------------------------------%
% pauseTight.m                                                             %
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
