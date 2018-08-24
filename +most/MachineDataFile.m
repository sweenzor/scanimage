classdef MachineDataFile < handle
    % Machine Data File reader/writer class.
    % MachineDataFile knows how to read/write from/to a Machine Data File.
    %
    % Usage:
    %   mdf = MachineDataFile.getInstance();
    %   mdf.load('myMachineDataFile.txt'); % parses MDF, loads into memory
    %   if mdf.isHeading('heading1')
    %     [tf vars] = mdf.getVarsUnderHeading('heading1');
    %   else
    %     ... etc ...
    
    properties (SetAccess=private)
        fMDFName;
        fHData;
    end
    
    properties
        hConfigEditor;
    end
    
    properties (Dependent)
        fileName;
        isLoaded;
    end
    
    % Prop accessors
    methods
        % Return true if this object has a parsed/loaded MDF.
        function tf = get.isLoaded(obj)
            tf = ~isempty(obj.fHData);
        end
        function n = get.fileName(obj)
           n = obj.fMDFName;
        end
    end
    
    methods

        % Parse/load an existing MachineDataFile. If fname is not an existing file,
        % obj.unload is called. No throw.
        function load(obj,fname)
            if exist(fname,'file')~=2
                obj.unload();
                return;
            end
                            
            hd = most.MachineDataFile.read(fname);
            obj.fMDFName = fname;
            obj.fHData = hd;
        end
        
        function unload(obj)
           obj.fMDFName = '';
           obj.fHData = [];
        end   
        
        function reload(obj)
            assert(obj.isLoaded);
            obj.load(obj.fMDFName);
        end
                
        % Returns true if heading is in the currently loaded MDF.
        function tf = isHeading(obj,heading)
            assert(obj.isLoaded);
            tf = ismember(heading,{obj.fHData.heading});
        end
        
        % Attempts to read the M-code block for heading in the currently
        % loaded MachineDataFile. If successful, tf is returned as true and s is a
        % structure containing the vars/values found. If unsuccessful (eg
        % an M-file parse error), tf is false and s is indeterminate.
        function [tf, s] = getVarsUnderHeading(obj,heading)
            assert(obj.isLoaded);
            r = obj.getRowsForHeading(heading);
            assert(iscellstr(r));
            
            tf = true;
            try
                s = zlclEvalRows(r);
            catch %#ok
                tf = false;
                s = [];
            end
        end
        
        function [r, headingIdx] = getRowsForHeading(obj,heading)
            % Returns r, a cellstr of rows for heading, and headingIdx, the index of
            % heading in hdata. Returns r as -1 and headingIdx as nan if heading does
            % not exist in hdata.
            r = -1;
            headingIdx = nan;
            for c = 1:numel(obj.fHData)
                if strcmp(heading,obj.fHData(c).heading)
                    r = obj.fHData(c).rows;
                    headingIdx = c;
                    break;
                end
            end
        end

        % This updates the current MachineDataFile (both on disk and in memory) so that
        % variable varName under heading hding has the value val. An MachineDataFile
        % must currently be loaded, and hding must be an existing heading.
        % If varName is an existing variable, its value is updated. If
        % varName is not an existing variable, it is created.
        %
        % The return value is true if the variable varName had to be
        % created in the MachineDataFile, false otherwise.        
        function tfNewVar = writeVarToHeading(obj,hding,varName,val,custcmt)
            assert(obj.isLoaded);
            assert(obj.isHeading(hding));
            
            if nargin < 5
                custcmt = '';
            end
            
            if isstruct(val)
                % write as an array of struct fields
                tfNewVar = false;
                nms = fieldnames(val);
                for i = 1:numel(val)
                    for j = 1:numel(nms)
                        varnm = sprintf('%s(%d).%s',varName,i,nms{j});
                        nv = obj.writeVarToHeading(hding,varnm,val(i).(nms{j}));
                        tfNewVar = tfNewVar || nv;
                    end
                end
                
                return;
            end
            
            % Look for varName in the rows for hding
            [rows, hdingIdx] = obj.getRowsForHeading(hding);
            tfFound = false;
            for c = 1:numel(rows)
                [vName, ~, comment] = parseLine(rows{c});
                if strcmp(vName,varName)
                    tfFound = true;
                    break;
                end
            end
            
            if tfFound
                % found varName @ row c
                if isempty(custcmt)
                    cmmt = comment;
                else
                    cmmt = custcmt;
                end
                newRow = sprintf('%s = %s;%s',varName,most.util.toString(val),cmmt); % if val is unencodeable, too bad
                obj.fHData(hdingIdx).rows{c} = newRow;
            else
                % did not find varName in rows.
                newRow = sprintf('%s = %s;',varName,most.util.toString(val)); % if val is unencodeable, too bad
                obj.fHData(hdingIdx).rows{end+1,1} = newRow;
            end
            
            most.MachineDataFile.write(obj.fMDFName,obj.fHData);            
            
            tfNewVar = ~tfFound;
        end
        
        
        function tfNewVar = removeVarFromHeading(obj,hding,varName)
            assert(obj.isLoaded);
            assert(obj.isHeading(hding));
            
            % Look for varName in the rows for hding
            [rows, hdingIdx] = obj.getRowsForHeading(hding);
            pat = '^([^=]+)=([^=;]+);(.*)$'; % this is not bulletproof but okay for now (works for vals scalars numerics, strings, etc)
            tfFound = false;
            for c = 1:numel(rows)
                toks = regexp(rows{c},pat,'tokens');
                if ~(isscalar(toks) && iscell(toks))
                    % skip this row; could be a comment, or invalid matlab
                    continue;
                end
                vName = strtrim(toks{1}{1});
                if strcmp(varName,vName)
                    tfFound = true;
                    break;
                end
            end
            
            if tfFound
                % found varName @ row c. remove it
                obj.fHData(hdingIdx).rows{c} = '';
            end
            
            most.MachineDataFile.write(obj.fMDFName,obj.fHData);            
            
            tfNewVar = ~tfFound;
        end
        
        
        function removeSections(obj,hdingsToRemove)
            most.MachineDataFile.write(obj.fMDFName,obj.fHData,hdingsToRemove);
        end
        
        % This copies the contents of modelFile into the file on disk for
        % the currently loaded MachineDataFile. The new MachineDataFile is *not* reloaded
        % automatically.
        function generateDefaultSection(obj,className,customHeading)
            assert(obj.isLoaded);
            
            if nargin > 2 && ~isempty(customHeading)
                hdg = customHeading;
            else
                hdg = eval([className '.mdfHeading']);
            end
            
            s = eval([className '.mdfDefault']);
            rowData = [{['%% ' hdg]} arrayfun(@convertLine,s)]';
            
            appFHData = struct('heading',hdg,'rows',{rowData},'start',[],'stop',[]);
            
            obj.fHData = [obj.fHData;appFHData];
            obj.write(obj.fMDFName,obj.fHData);
            
            function l = convertLine(ts)
                if ~isempty(ts.name)
                    l = [ts.name ' = ' most.util.toString(ts.value) ';'];
                    if ~isempty(ts.comment)
                        l = {[l '     % ' ts.comment]};
                    else
                        l = {l};
                    end
                elseif ~isempty(ts.comment)
                    l = {['% ' ts.comment]};
                else
                    l = {''};
                end
            end
        end
                   
    end
    
    methods (Static)
        
        function obj = getInstance
            persistent x;
            if isempty(x)
                x = most.MachineDataFile;
            end
            obj = x;
        end

        % Create a new (blank) MachineDataFile in mdfpath and return the full filename.
        function [fullfname shortfname] = createNewMDF(mdfpath)
            
            shortfname = most.MachineDataFile.getDefaultMDFName;
            fullfname = fullfile(mdfpath,shortfname);
            if exist(fullfname,'file')==2
                error('MachineDataFile:MDFAlreadyExists',...
                      'A machine data file already exists at %s.',fullfname);
            end
            
            [fh fopenmsg] = fopen(fullfname,'w');
            if fh==-1
                error('MachineDataFile:cannotOpenMDF',...
                      'Error opening file ''%s''. %s.',fullfname,fopenmsg);
            end
            most.MachineDataFile.writeHeader(fh);
            fclose(fh);
        end
        
        function writeHeader(mdfFH)
            fprintf(mdfFH,'%% Most Software Machine Data File\n\n');
        end
    end
    
    methods (Access=private)
        function obj = MachineDataFile
            obj.fMDFName = [];
            obj.fHData = [];
        end
    end
        
    methods (Static,Access=private)
        
        % No throw
        function hdingData = read(mdfname)
            % This function reads an MachineDataFile and produces the data structure
            % hdingData. hdingData is a struct array, with one element per
            % "heading block" in the MachineDataFile. The contents of the MachineDataFile that
            % occur before the first heading is put into the first element
            % of hdingData, a "dummy block" with heading name
            % __ZerothHeading.
            %
            % Each hdingData has the heading name, a cellstr of rows in
            % that heading block, and the start/stop row numbers in the
            % MachineDataFile.
            
            rows = zlclGetRows(mdfname);
            headings = regexp(rows,'^%% (\w.*)','tokens');
            assert(numel(headings)==numel(rows));
            hdingData = struct('heading','__ZerothHeading','rows',[],'start',1,'stop',[]);
            
            for c = 1:numel(headings)
                hd = headings{c};
                if ~isempty(hd) % new heading
                    % finish off old one
                    hdingData(end).stop = c-1;
                    hdingData(end).rows = rows(hdingData(end).start:hdingData(end).stop);
                    % start new one
                    hdingData(end+1,1).heading = hd{1}{1}; %#ok<AGROW>
                    hdingData(end).start = c;
                else
                    % continuation of prev heading, no-op
                end
            end
            
            % finish last heading
            hdingData(end).stop = numel(rows);
            hdingData(end).rows = rows(hdingData(end).start:hdingData(end).stop);
        end     

        % Write the heading data in hddata into the specified file. This
        % overwrites anything existing in the file.
        function write(fname,hddata,hdingsToRemove)
            if nargin < 3
                hdingsToRemove = {};
            end
            
            [fh fopenmsg] = fopen(fname,'w');
            if fh==-1
                error('MachineDataFile:cannotOpenMDF',...
                    'Error opening file ''%s''. %s.',fname,fopenmsg);
            end
            
            for c=1:numel(hddata)
                if isempty(hdingsToRemove) || ~ismember(hddata(c).heading,hdingsToRemove)
                    numrows = numel(hddata(c).rows);
                    for d=1:numrows
                        row = hddata(c).rows{d};
                        fprintf(fh,'%s\n',row);
                    end
                    if numrows>0 && ~isempty(deblank(row)) % last row is not empty
                        fprintf(fh,'\n');
                    end
                end
            end
            
            fclose(fh);
        end

        function fname = getDefaultMDFName
            fname = 'Machine_Data_File.m';
        end
    end
       
end

function rows = zlclGetRows(fname)
[fh fopenmsg] = fopen(fname);
if fh==-1
    error('MachineDataFile:cannotOpenMDF',...
        'Error opening file ''%s''. %s.',fname,fopenmsg);
end
rows = textscan(fh,'%s','Delimiter','\n'); % if always running on win, \n prob okay
fclose(fh);
rows = rows{1};
end

% Evalaute a cellstr containing lines of M-code. Return the
% resulting workspace in the struct s.
function s = zlclEvalRows(dont_want__clashes___rows)
for dont_want__clashes___c = 1:numel(dont_want__clashes___rows)
    eval(dont_want__clashes___rows{dont_want__clashes___c});
end
dont_want__clashes___vars = who();
dont_want__clashes___vars = setdiff(dont_want__clashes___vars,...
    {'dont_want__clashes___rows','dont_want__clashes___c','dont_want__clashes___vars'});
s = struct();
for c = 1:numel(dont_want__clashes___vars)
    s.(dont_want__clashes___vars{c}) = eval(dont_want__clashes___vars{c});
end
end

function [varName, statement, comment] = parseLine(line)
    varName = '';
    statement = '';
    comment = '';
    
    % find the var name
    ep = strfind(line,'=');

    if ~isempty(ep)
        varName = strtrim(line(1:ep(1)-1));
        stmt = strtrim(line(ep(1)+1:end));

        % find the comment
        N = length(stmt);
        inStr = false;
        comment = '';
        sc = 0;
        for i = 1:N
            if ~inStr && (stmt(i) == '%')
                comment = stmt(i-sc:end);
                statement = strtrim(stmt(1:i-1));
                break;
            elseif ~inStr && (stmt(i) == '''')
                % distinguish this from a transpose operator
                inStr = (i<2) || ~ismember(stmt(i-1),'])}1234567890.');
            elseif inStr && (stmt(i) == '''')
                inStr = false;
            end
            
            sc = (sc + 1) * isspace(stmt(i));
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% priority is unsupported %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% function sortedhddata = lclSortHeadingDataByPriority(hddata)
% % This will sort the hddata struct array by priority of the heading
% % classname. The sort should be stable (I think).
%     Nhd = numel(hddata);
%     pts = zeros(Nhd,1);
%     for c = 1:Nhd
%         try
%             prty = eval([hddata(c).heading '.mdfPriority;']);
%             if isempty(prty)
%                 prty = 5;
%             end
%             pts(c) = prty;
%         catch %#ok<CTCH>
%             warning('MachineDataFile:UnknownHeading',...
%                 'Unrecognized heading ''%s'' in machine data file.',...
%                 hddata(c).heading);
%             pts(c) = 100; % big (low) priority
%         end
%     end
%     
%     [~,i] = sort(pts);
%     sortedhddata = hddata(i);
% end




%--------------------------------------------------------------------------%
% MachineDataFile.m                                                        %
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
