function rioList = findFlexRios
    % initialize NI system configuration session
    [~,~,~,experthandle,sessionhandle] = nisyscfgCall('NISysCfgInitializeSession','localhost','','',1033,false,100,libpointer,libpointer);

    % find hardware
    [~,~,~,resEn] = nisyscfgCall('NISysCfgFindHardware',sessionhandle,1,libpointer,'',libpointer);

    rioList = struct();
    
    % go through list
    succ = true;
    while succ
        try
            [~,~,res] = nisyscfgCall('NISysCfgNextResource',sessionhandle, resEn, libpointer('voidPtrPtr'));

            try
                chr = libpointer('string',blanks(100000));
                nisyscfgCall('NISysCfgGetResourceProperty', res, 'NISysCfgResourcePropertyProvidesLinkName', chr);
                addr = chr.Value;
            catch
                addr = '';
            end

            try
                chr = libpointer('string',blanks(100000));
                nisyscfgCall('NISysCfgGetResourceProperty', res, 'NISysCfgResourcePropertyConnectsToLinkName', chr);
                parAddr = chr.Value;
            catch
                parAddr = '';
            end

            if strncmp(addr,'RIO',3) || strncmp(parAddr,'RIO',3)
                % this will find flex rios and digitizers
                try
                    chr = libpointer('string',blanks(100000));
                    nisyscfgCall('NISysCfgGetResourceProperty', res, 'NISysCfgResourcePropertyProductName', chr);
                    nm = chr.Value;
                catch
                    nm = '';
                end

                if strncmp(addr,'RIO',3)
                    rioList.(addr).productName = nm;
                    rioList.(addr).pxiNumber = str2double(parAddr(4:end));
                else
                    rioList.(parAddr).adapterModule = nm;
                end
            else
                % this will find oscilloscopes
                % get number of experts
                try
                    v = libpointer('uint32Ptr',0);
                    nisyscfgCall('NISysCfgGetResourceProperty', res, 'NISysCfgResourcePropertyNumberOfExperts', v);
                    n = v.Value;
                catch
                    n = 0;
                end
                
                % look for the ni-rio expert
                for jj = 1:n
                    try
                        chr = libpointer('string',blanks(100000));
                        nisyscfgCall('NISysCfgGetResourceIndexedProperty', res, 'NISysCfgIndexedPropertyExpertName', jj, chr);
                        nm = chr.Value;
                    catch
                        nm = '';
                    end
                    
                    if strcmp(nm, 'ni-rio')
                        try
                            chr = libpointer('string',blanks(100000));
                            nisyscfgCall('NISysCfgGetResourceIndexedProperty', res, 'NISysCfgIndexedPropertyExpertResourceName', jj, chr);
                            rio = chr.Value;
                        catch
                            rio = '';
                        end
                        
                        if ~isempty(rio)
                            try
                                chr = libpointer('string',blanks(100000));
                                nisyscfgCall('NISysCfgGetResourceProperty', res, 'NISysCfgResourcePropertyProductName', chr);
                                nm = chr.Value;
                            catch
                                nm = '';
                            end
                            
                            if strncmp(rio,'RIO',3)
                                rioList.(rio).productName = nm;
                                rioList.(rio).pxiNumber = str2double(parAddr(4:end));
                            end
                        end
                    end
                end
            end

            nisyscfgCall('NISysCfgCloseHandle',res);
        catch
            succ = false;
        end
    end

    % close the enumerator
    nisyscfgCall('NISysCfgCloseHandle',resEn);

    % close session and expert handle
    nisyscfgCall('NISysCfgCloseHandle',sessionhandle);
    nisyscfgCall('NISysCfgCloseHandle',experthandle);
end


%--------------------------------------------------------------------------%
% findFlexRios.m                                                           %
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
