function matchingPropertyNames = findPropertiesSuchThat(objectOrClassName,varargin)
    % Returns a list of property names for the class that match for all the
    % given attributes.  E.g.
    %   findPropertiesSuchThat(obj,'Dependent',false,'GetAccess','private')
    %       => a list of all properties that are independent and have
    %          private GetAccess

    % Parse atribute, value pairs
    attributeNames=varargin(1:2:end);
    desiredAttributeValues=varargin(2:2:end);    
    nDesires=length(desiredAttributeValues);
    
    % Determine if first input is object or class name
    if ischar(objectOrClassName)
        mc = meta.class.fromName(objectOrClassName);
    elseif isobject(objectOrClassName)
        mc = metaclass(objectOrClassName);
    end

    % Initialize and preallocate
    propertyProperties=mc.PropertyList;
    propertyNames={propertyProperties.Name};
    nProperties = length(propertyProperties);
    %matchingPropertyNamesSoFar = cell(1,nProperties);
    
    % For each property, check the value of the queried attribute
    isMatch=false(1,nProperties);
    for iProperty = 1:nProperties
        % Get a meta.property object from the meta.class object
        thisPropertyProperties = propertyProperties(iProperty);

        isThisPropertyAMatchSoFar=true;
        for iDesire=1:nDesires
            attributeName=attributeNames{iDesire};
            desiredAttributeValue=desiredAttributeValues{iDesire};
            
            % Determine if the specified attribute is valid on this object
            if isempty (findprop(thisPropertyProperties,attributeName))
                error('%s is not a valid attribute name',attributeName)
            end
            attributeValue = thisPropertyProperties.(attributeName);
        
            % If the attribute is set or has the specified value,
            % save its name in cell array
            if ~isequal(attributeValue,desiredAttributeValue) ,
                isThisPropertyAMatchSoFar=false;
                break
            end
        end
        isMatch(iProperty)=isThisPropertyAMatchSoFar;
    end
    
    % Return used portion of array
    matchingPropertyNames = propertyNames(isMatch);
end


%--------------------------------------------------------------------------%
% findPropertiesSuchThat.m                                                 %
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
