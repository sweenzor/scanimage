function lh = addweaklistener(varargin)%
% the function addweaklistener mimics the built in matlab function addlistener
% in contrast to addlistener, this function generates a listener object
% which does not add to the reference count of the owning object - it
% creates a 'weak reference'
%
% Usage
% el = ADDLISTENER(hSource, 'Eventname', Callback)
% el = ADDLISTENER(hSource, PropName, 'Eventname', Callback)
%
% review the matlab documentation page 'Listener Lifecycle' for more
% information on the topic

if length(varargin) == 3
    % mimics lh = addlistener(Hsource,EventName,callback)
    Hsource   = varargin{1};
    EventName = varargin{2};
    callback  = varargin{3};
    lh = event.listener(Hsource,EventName,callback);    
elseif length(varargin) == 4
    % mimics lh = addlistener(Hsource,property,EventName,callback)
    Hsource   = varargin{1};
    property  = varargin{2};
    EventName = varargin{3};
    callback  = varargin{4};
    % get meta property objects for given event names
    mps = cellfun(@(propname)findprop(Hsource,propname),cellstr(property),'UniformOutput',false);
    lh = event.proplistener(Hsource,mps,EventName,callback);
else
    error('Incorrect use of ''addweaklistener'': Expect 3 or 4 input arguments');
end
end

%--------------------------------------------------------------------------%
% addweaklistener.m                                                        %
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
