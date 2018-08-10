function testResScan2D()
    h2D = scanimage.components.scan2d.ResScan2D();
    assignin('base','h2D',h2D);
    h2D.stripeAcquiredCallback = @(src,evnt)callbackFcn(src,evnt);
    h2D.start();
    h2D.trigIssueSoftwareAcq();
end

function callbackFcn(src,evnt)
    stripeData = src.readStripeData();
    fprintf('Received stripe: frameNumberAcqMode: %d, acqNumber: %d, frameNumberAcq:%d\n',...
        stripeData.frameNumberAcqMode, stripeData.acqNumber, stripeData.frameNumberAcq);
    
    if stripeData.endOfAcquisition
        disp('end of Acquisition');
    end
    
    if stripeData.endOfAcquisitionMode
        disp('end of AcquisitionMode');
    end
    
    assignin('base','stripeData',stripeData);
end


%--------------------------------------------------------------------------%
% testResScan2D.m                                                          %
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
