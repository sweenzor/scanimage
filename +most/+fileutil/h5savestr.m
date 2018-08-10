function h5savestr(file, dataset, value, useCreate)
%H5SAVESTR Create an H5 string dataset and write the value.
%
%   Must be a vector string.

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

if isempty(value)
    dims = 1;
    fileType = H5T.copy ('H5T_FORTRAN_S1');
    H5T.set_size (fileType, 'H5T_VARIABLE');
    memType = H5T.copy ('H5T_C_S1');
    H5T.set_size (memType, 'H5T_VARIABLE');
else
    dims = size(value, 1);
    SDIM = size(value, 2) + 1;
    
    fileType = H5T.copy('H5T_FORTRAN_S1');
    H5T.set_size (fileType, SDIM - 1);
    memType = H5T.copy('H5T_C_S1');
    H5T.set_size (memType, SDIM - 1);
end

dataspace = H5S.create_simple (1, fliplr(dims), []);

if size(value, 2) > 1
    value = value';
end

most.fileutil.h5savevalue(fileID, dataset, fileType, value, dataspace, memType);

H5T.close(fileType);


%--------------------------------------------------------------------------%
% h5savestr.m                                                              %
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
