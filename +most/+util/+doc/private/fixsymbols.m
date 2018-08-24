function outstr = fixsymbols(instr)

% Convert < and > to html-friendly characters; but do not convert them
% if they are part of an html tag, because then they will show up as
% symbols rather than links inside the Help browser.  So, we need to first
% split the string up so that we don't look at the html tags when replacing
% the symbols with the html-friendly characters.

%   Copyright 2007-2012 The MathWorks, Inc.

instr  = strrep(instr, '&', '&amp;');
expr = '<a\shref\s?=\s?.*?>.*?</a>';
[startpos, endpos, matches] = regexp(instr, expr,'start','end','match');

if ~isempty(startpos)
    startpos = [startpos-1 length(instr)];
    endpos = [1 endpos+1];
    outstr = '';
    for i=1:length(startpos)
        % convert < and > to html-friendly characters
        segment = instr(endpos(i):startpos(i));
        segment = strrep(segment, '<', '&lt;');
        segment = strrep(segment, '>', '&gt;'); 
                
        if i<=length(matches)
            % if there are any help links, convert them to helpwin
            outstr  = [outstr segment regexprep(matches{i}, '\<matlab:help\>', 'matlab:helpwin')];
        else
            % append the rest of the help text
            outstr = [outstr segment];
        end
    end
else
    instr  = strrep(instr, '<', '&lt;');
    outstr = strrep(instr, '>', '&gt;'); 
end



%--------------------------------------------------------------------------%
% fixsymbols.m                                                             %
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
