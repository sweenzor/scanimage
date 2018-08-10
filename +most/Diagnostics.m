classdef Diagnostics < handle
    %Diagnostics Control diagnostic output at the command line and in log files.
    %
    %   The Diagnostics class can be used to provide control over the vebosity of
    %   diagnostic output at the command line and in log files for most classes and
    %   derived applications.  Functions and class methods can query the LogLevel to
    %   determine how much information to display, if any.  Applications can also
    %   set and change the LogLevel at any time.
    %
    %   
    %   See also most.util.LogLevel.
    
    properties
        LogLevel = most.util.LogLevel.Info; %Specifies the verbosity of command line and log file output.
    end
    
    methods (Access = private)
        function self = Diagnostics()
            %Diagnostics Default class constructor.
            %
            %   Diagnostics is a singleton class per MATLAB instance and therefore has a
            %   private constructor.
        end
    end
    
    methods
        function set.LogLevel(self, value)
            validateattributes(value, {'numeric', 'logical', 'most.util.LogLevel'}, {'scalar'});
            
            if ~isa(value, 'most.util.LogLevel')
                value = most.util.LogLevel(value);
            end
            
            self.LogLevel = value;
        end
    end
    
    methods (Static = true)
        function out = shareddiagnostics()
            %shareddiagnostics Return Diagnostics class singleton.
            
            persistent sharedInstance;
            if isempty(sharedInstance)
                sharedInstance = most.Diagnostics();
            end
            out = sharedInstance;
        end
    end
end


%--------------------------------------------------------------------------%
% Diagnostics.m                                                            %
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
