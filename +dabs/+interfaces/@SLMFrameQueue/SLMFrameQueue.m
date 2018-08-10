classdef SLMFrameQueue < handle
    properties(SetAccess = private)
        length = 0;
        numBytesPerFrame = 0;
        running = false;
    end
    
    properties(Access = private)
        hFrameQueue;
    end
    
    methods
        function obj = SLMFrameQueue(slmDeviceHandle,numBytesPerFrame)
            assert(isa(slmDeviceHandle,'uint64'),'Expect slmDeviceHandle to be of type uint64');
            obj.hFrameQueue = SlmFrameQueue('make',slmDeviceHandle);
            obj.numBytesPerFrame = numBytesPerFrame;
        end
        
        function delete(obj)
            if obj.running
                obj.abort();
            end
            SlmFrameQueue('delete',obj.hFrameQueue);
        end
    end
    
    methods
        function resize(obj,length)
            assert(~obj.running,'Cannot resize Frame Queue while it is running');
            obj.length = 0;
            SlmFrameQueue('resize',obj.hFrameQueue,length,obj.numBytesPerFrame); % throws
            obj.length = length;
        end
        
        function start(obj)
            assert(obj.length>0,'Cannot start frame queue of length 0');
            assert(~obj.running,'Frame queue is already running');
            obj.running = true;
            SlmFrameQueue('start',obj.hFrameQueue);
        end
        
        function abort(obj)
            SlmFrameQueue('abort',obj.hFrameQueue);
            obj.running = false;
        end
        
        function write(obj,data)
            assert(size(data,3)<=obj.length,'Number of frames to write is larger than capacity of frame queue');
            data = data(:);
            data = typecast(data,'uint8');
            assert(numel(data)<=obj.length*obj.numBytesPerFrame,'Data size mismatch');
            SlmFrameQueue('write',obj.hFrameQueue,data);
        end
        
        function [running,iterationIdx,queueIdx] = getStatus(obj)
            [running,iterationIdx,queueIdx] = SlmFrameQueue('getStatus',obj.hFrameQueue);
            iterationIdx = iterationIdx+1;
            queueIdx = queueIdx+1;
        end
    end    
end



%--------------------------------------------------------------------------%
% SLMFrameQueue.m                                                          %
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
