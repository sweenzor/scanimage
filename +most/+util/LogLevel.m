classdef (Sealed = true) LogLevel < double
    %LogLevel Enumeration of command line and log file verbosity levels.
    %
    %   Log levels are fairly self explanatory.  Although MATLAB supports builtin
    %   warning and error functionality, log levels of Warn and Error allow logging
    %   or output classes to send warning or error information to log files or other
    %   destinations other than the command line.
    %
    %   The enumeration is ordered with the assumption that typically functionality
    %   using this enumeration would output the information at its log level and
    %   any level below it (i.e., in order of increasing detail/diagnostic value).
    %
    %   See also most.Diagnostics.
    
    enumeration
        Silent(0); %Do not generate any output.
        Info(1);   %Output general diagnostic information.
        Warn(2);   %Output warnings.  Could be used to suppress all most or most-derived app warnings rather than having to tweak several individual warning identifiers.
        Error(3);  %Output errors.
        Debug(4);  %Output debugging-specific information.
        Trace(5);  %Output information sufficient for detailed function and behavior tracing.
    end
end


%--------------------------------------------------------------------------%
% LogLevel.m                                                               %
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
