classdef DAQmxTestClass < hgsetget
    %TESTCLASS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess=private)
        hTask;
        hChan;
        aProp = 3;
        
    end
    
    properties (Hidden,SetAccess=private)
       collectedFirstSample; 
    end
    
    properties (Constant)
        deviceName = 'Dev1';
        chanID = 0;
        sampRate = 1e5; %Hz
        acqDuration = 5; %seconds
        callbackPeriod = 1; %seconds               
    end
    
    methods
        
        function obj = DAQmxTestClass()
            
            import dabs.ni.daqmx.*
            
            obj.hTask = Task('a task');
            obj.hChan = obj.hTask.createAIVoltageChan(obj.deviceName,obj.chanID);
            
            obj.hTask.cfgSampClkTiming(obj.sampRate, 'DAQmx_Val_FiniteSamps', round(obj.acqDuration * obj.sampRate));
            obj.hTask.everyNSamplesEventCallbacks = @obj.demoCallback1;
            obj.hTask.everyNSamples = round(obj.sampRate * obj.callbackPeriod);
            
            %obj.hTask.doneEventCallbacks = (@(src,evnt)obj.demoCallback2(src,evnt)); %This works too
            obj.hTask.registerDoneEvent(@obj.demoCallback2);
            
            obj.hTask.registerSignalEvent(@obj.demoCallback3, 'DAQmx_Val_SampleCompleteEvent'); %This will get invoked on /every/ sample -- very wasteful, but demonstrate anyway
        end
        
        function delete(obj)
           delete(obj.hTask);
        end       
        
        function start(obj)            
            if obj.hTask.isTaskDone()                               
                obj.hTask.stop();
                
                obj.collectedFirstSample = false;
                obj.hTask.start();
            else
                disp('Task already started');
            end                
        end
        
        
        
    end
    
    methods (Access=private)
       
        function demoCallback1(obj,src,evnt)
            hTask = src;
            fprintf(1,'TaskID: %d; Task Name: %s\n',hTask.taskID, hTask.taskName);            
            fprintf(1,'Value of ''aProp'': %d\n',obj.aProp);
        end
        
        function demoCallback2(obj,src,evnt)
           disp('Task is OVAH!'); 
        end
        
        function demoCallback3(obj,src,evnt)   
            if ~obj.collectedFirstSample 
                disp('Task collected its first sample.');
                obj.collectedFirstSample = true;
            end
        end
    end
    
end



%--------------------------------------------------------------------------%
% DAQmxTestClass.m                                                         %
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
