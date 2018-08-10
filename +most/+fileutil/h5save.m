function h5save(file, dataset, value, useCreate)

if nargin < 4
    useCreate = false;
end

if ischar(file)
    if useCreate
        fileID = H5F.create(file, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');
    else
        fileID = H5F.open(file, 'H5F_ACC_RDWR', 'H5P_DEFAULT');
    end
    c = onCleanup(@()H5F.close(fileID));
else
    fileID = file;
end

if isstruct(value)
    most.fileutil.h5savestruct(fileID, dataset, value);
elseif isnumeric(value)
    if  most.idioms.isenum(value)
        value = double(value);
    end
    most.fileutil.h5savedouble(fileID, dataset, value);
elseif islogical(value)
    most.fileutil.h5savedouble(fileID, dataset, double(value));
elseif ischar(value)
    most.fileutil.h5savestr(fileID, dataset, value);
elseif iscellstr(value)
    most.fileutil.h5savestr(fileID, dataset, char(value));
elseif isobject(value) && ismethod(value,'h5save') ,
    % If it's an object that knows how to save itself to HDF5, use the
    % method
    value.h5save(fileID, dataset);    
else
    %With stack traces turned off, finding this was non-trivial, so make sure to identify the code throwing the warning. - TO022114A
    most.mimics.warning('most:h5:unsuporteddatatype', 'h5save - Unsupported data type: %s', class(value));
end

end  % function


%--------------------------------------------------------------------------%
% h5save.m                                                                 %
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
