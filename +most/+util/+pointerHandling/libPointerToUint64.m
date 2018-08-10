function pointerUint64 = libPointerToUint64(myLibPointer)
if ~libisloaded('pointerHandling')
    p = fileparts(mfilename('fullpath'));
    p = fullfile(p,'dll');
    
    currentDirectory = pwd();
    try
        cd(p);
        loadlibrary('pointerHandling',@pointerHandling);
        cd(currentDirectory);
    catch ME
        cd(currentDirectory);
        rethrow(ME);
    end
end

assert(isa(myLibPointer,'lib.pointer'),'Expected input to be a lib.pointer');
myUint64Ptr = libpointer('uint64Ptr',0);
calllib('pointerHandling','libPointerToUint64',myLibPointer,myUint64Ptr);

pointerUint64 = myUint64Ptr.Value;
end




%--------------------------------------------------------------------------%
% libPointerToUint64.m                                                     %
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
