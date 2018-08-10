classdef (Abstract) ValueComparable < handle
    methods (Abstract=true)
        value=isequal(self,other)
            % Custom isequal.  This generally just calls the isequalHelper()
            % method, which needs to know the name of the class.  (Where
            % "the class" means the class of the classdef containing the
            % isequal() implementation.  It seems like there should be a
            % way to determine this automatically...
    end
    
    methods (Access=protected)        
        function value=isequalHelper(self,other,className)
            % Helper for custom isequal.  Doesn't work for 3D, 4D, etc arrays.
            % This should generally _not_ be overridden.
            if ~isa(other,className) ,
                value=false;
                return
            end
            dims=size(self);
            if any(dims~=size(other))
                value=false;
                return;
            end
            n=numel(self);
            for i=1:n ,
                if ~isequalElement(self(i),other(i)) ,
                    value=false;
                    return
                end
            end
            value=true;
        end  % function
    end  % protected methods block
    
    methods (Abstract=true, Access=protected)
        value=isequalElement(self,other)  % to be implemented by subclasses
    end
    
    methods (Access=protected)
       function value=isequalElementHelper(self,other,propertyNamesToCompare)
            % Helper to test for "value equality" of two scalars.
            % propertyNamesToCompare should be a row vector of property names to compare using isequal()
            % This should generally _not_ be overridden.
            nPropertyNamesToCompare=length(propertyNamesToCompare);
            for i=1:nPropertyNamesToCompare ,
                propertyName=propertyNamesToCompare{i};
                if ~isequal(self.(propertyName),other.(propertyName)) ,
                    %keyboard
                    value=false;
                    return
                end
            end
            value=true;
       end        
    end
end


%--------------------------------------------------------------------------%
% ValueComparable.m                                                        %
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
