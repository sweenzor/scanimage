function h5savevalue(fileID, dataset, fileType, value, dataspaceID, memtype)
%H5SAVEVALUE Create an H5 dataset and write the value.

if nargin < 5 || isempty(dataspaceID)
    if isempty(value)
        dims = [1 1];
    else
        dims = size(value);
    end
    
    dataspaceID = H5S.create_simple(2, fliplr(dims), []);
end

datasetID = H5D.create(fileID, dataset, fileType, dataspaceID, 'H5P_DEFAULT');

if ~isempty(value)
    if nargin < 6
        memtype = 'H5ML_DEFAULT';
    end
    H5D.write(datasetID, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', value);
end

H5D.close(datasetID);
H5S.close(dataspaceID);


%--------------------------------------------------------------------------%
% h5savevalue.m                                                            %
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
