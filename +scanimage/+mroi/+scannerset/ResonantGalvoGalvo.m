classdef ResonantGalvoGalvo < scanimage.mroi.scannerset.ScannerSet

    properties
        fillFractionSpatial;
        resonantLimitedFovMode = false;
        angularRange;
        modifiedTimebaseSecsPerSec = 1;
    end
    
    properties (Hidden)
        CONSTRAINTS = struct(...
            'scanimage_mroi_scanfield_ImagingField',...
              {{@scanimage.mroi.constraints.maxHeight @scanimage.mroi.constraints.maxWidth @scanimage.mroi.constraints.positiveWidth...
                @scanimage.mroi.constraints.sameWidth @scanimage.mroi.constraints.yCenterInRange @scanimage.mroi.constraints.sameRotation...
                @scanimage.mroi.constraints.samePixelsPerLine @scanimage.mroi.constraints.evenPixelsPerLine}}...
            );
    end
    
    properties (Constant)
        optimizableScanners = {'G','Z'};
    end

    methods(Static)
        function obj=default()
            %% Construct a default version of this scanner set for testing
            r=scanimage.mroi.scanners.Resonant.default();
            g=scanimage.mroi.scanners.Galvo.default();
            z=scanimage.mroi.scanners.FastZ.default();
            obj=scanimage.mroi.scannerset.ResonantGalvoGalvo(r,g,g,z);
            obj.refToScannerTransform = eye(3);
        end
    end
    
    methods
        function obj = ResonantGalvoGalvo(name,resonantx,galvox,galvoy,beams,fastz,fillFractionSpatial)
            %% Describes a resonant-galvo-galvo scanner set.
            obj = obj@scanimage.mroi.scannerset.ScannerSet(name,beams,fastz);
            
            scanimage.mroi.util.asserttype(resonantx,'scanimage.mroi.scanners.Resonant');
            if ~isempty(galvox)
                scanimage.mroi.util.asserttype(galvox,'scanimage.mroi.scanners.Galvo');
                obj.CONSTRAINTS.scanimage_mroi_scanfield_ImagingField{end+1} = @scanimage.mroi.constraints.xCenterInRange;
            else
                obj.CONSTRAINTS.scanimage_mroi_scanfield_ImagingField{end+1} = @scanimage.mroi.constraints.centeredX;
            end
            scanimage.mroi.util.asserttype(galvoy,'scanimage.mroi.scanners.Galvo');
            
            obj.name = name;
            obj.scanners={resonantx,galvox,galvoy};
            obj.fillFractionSpatial = fillFractionSpatial;
        end
        
        function path_FOV = refFovToScannerFov(obj,path_FOV)
            % transform to scanner space
            % assumes there is no rotation and pathFOV.R is unique (except for NANs)
            
            path_FOV.R = path_FOV.R * obj.refToScannerTransform(1);
            path_FOV.G = scanimage.mroi.util.xformPoints(path_FOV.G,obj.refToScannerTransform);
            
            % ensure we are scanning within the angular range of the scanners
            tol = 0.0001; % tolerance to account for rounding errors
            
            rng = obj.scanners{1}.fullAngleDegrees;
            assert(all(path_FOV.R >= 0-tol) && all(path_FOV.R <= rng+tol), 'Attempted to scan outside resonant scanner FOV.');
            path_FOV.R(path_FOV.R < 0) = 0;
            path_FOV.R(path_FOV.R > rng) = rng;
            
            if isempty(obj.scanners{2})
                rng = zeros(1,2);
            else
                rng = obj.scanners{2}.travelRange;
            end
            assert(all(path_FOV.G(:,1) >= rng(1)-tol) && all(path_FOV.G(:,1) <= rng(2)+tol), 'Attempted to scan outside X galvo scanner FOV.');
            path_FOV.G(path_FOV.G(:,1) < rng(1),1) = rng(1);
            path_FOV.G(path_FOV.G(:,1) > rng(2),1) = rng(2);
            
            rng = obj.scanners{3}.travelRange;
            assert(all(path_FOV.G(:,2) >= rng(1)-tol) && all(path_FOV.G(:,2) <= rng(2)+tol), 'Attempted to scan outside Y galvo scanner FOV.');
            path_FOV.G(path_FOV.G(:,2) < rng(1),2) = rng(1);
            path_FOV.G(path_FOV.G(:,2) > rng(2),2) = rng(2);
        end
        
        function ao_volts = pathFovToAo(obj,path_FOV)
            % transform to scanner space
            path_FOV = obj.refFovToScannerFov(path_FOV);
            
            % scanner space to volts
            ao_volts.R = obj.degrees2volts(path_FOV.R,1);
            ao_volts.G(:,1) = obj.degrees2volts(path_FOV.G(:,1),2);
            ao_volts.G(:,2) = obj.degrees2volts(path_FOV.G(:,2),3);
            
            if obj.hasBeams
                bIDs = obj.beams.beamIDs;
                for i = 1:numel(bIDs)
                    ao_volts.B(:,i) = obj.beams.powerFracToVoltageFunc(bIDs(i),path_FOV.B(:,i));
                    if obj.hasPowerBox
                        ao_volts.Bpb(:,i) = obj.beams.powerFracToVoltageFunc(bIDs(i),path_FOV.Bpb(:,i));
                    end
                end
            end
            
            if obj.hasFastZ
                ao_volts.Z = obj.fastz.refPosition2Volts(path_FOV.Z);
            end
        end
            
        function [path_FOV, seconds] = scanPathFOV(obj,scanfield,roi,zPowerReference,actz,dzdt,zActuator,maxPtsPerSf)
            %% Returns struct. Each field has ao channel data in column vectors
            % 
            % ao_volts.R: resonant amplitude
            % ao_volts.G: galvo (columns are X,Y)
            % ao_volts.B: beams (columns are beam1,beam2,...,beamN)
            %
            % Output should look like:
            % 1.  Resonant_amplitude is constant.  Set for width of scanned
            %     field
            % 2.  Galvo_x is constant at center of scanned field
            % 3.  Galvo_y is continuously moving down the field.
            assert(isa(scanfield,'scanimage.mroi.scanfield.ScanField'));
            seconds=obj.scanTime(scanfield);
            
            if obj.scanners{3}.useScannerTimebase
                secondsG = seconds * obj.modifiedTimebaseSecsPerSec;
            else
                secondsG = seconds;
            end
            
            rsamples=round(secondsG*obj.scanners{1}.sampleRateHz);
            gsamples=round(secondsG*obj.scanners{3}.sampleRateHz);
            
            rfov = scanfield.sizeXY(1) * ones(rsamples,1);
            
            gfov(:,1)= scanfield.centerXY(1) * ones(gsamples,1);

            hysz = scanfield.sizeXY(2)/2;
            gfov(:,2)=linspace(scanfield.centerXY(2)-hysz,scanfield.centerXY(2)+hysz,gsamples);
            
            path_FOV.R = round(rfov * 1000000 / obj.fillFractionSpatial) / 1000000;
            path_FOV.G(:,1) = gfov(:,1);
            path_FOV.G(:,2) = gfov(:,2);
            
            %% Beams AO
            if obj.hasBeams
                hBm = obj.beams;
                
                % determine number of samples
                [~,lineAcquisitionPeriod] = obj.linePeriod(scanfield);
                bExtendSamples = floor(hBm.beamClockExtend * 1e-6 * hBm.sampleRateHz);
                bSamplesPerLine = ceil(lineAcquisitionPeriod*hBm.sampleRateHz) + 1 + bExtendSamples;
                nlines = scanfield.pixelResolution(2);
                
                % get roi specific beam settings
                [powers, pzAdjust, Lzs, interlaceDecimation, interlaceOffset] = obj.getRoiBeamProps(...
                    roi, 'powers', 'pzAdjust', 'Lzs', 'interlaceDecimation', 'interlaceOffset');

                % determine which beams need decimation
                ids = find(interlaceDecimation ~= 1);

                % start with nomimal power fraction sample array for single line
                powerFracs = repmat(powers,bSamplesPerLine,1);
                
                % zero last sample of line if blanking flyback. beam decimation requires blanking
                if hBm.flybackBlanking || numel(ids)
                    powerFracs(end,:) = 0;
                    powerFracs(end,logical(pzAdjust)) = NaN;
                end
                
                % replicate for n lines
                powerFracs = repmat(powerFracs,nlines,1);

                % mask off lines if decimated
                for i = 1:numel(ids)
                    lineMask = zeros(1,interlaceDecimation(ids(i)));
                    lineMask(1+interlaceOffset(ids(i))) = 1;
                    lineMask = repmat(lineMask, bSamplesPerLine, ceil(nlines/interlaceDecimation(ids(i))));
                    lineMask(:,nlines+1:end) = [];
                    lineMask = reshape(lineMask,[],1);
                    powerFracs(:,ids(i)) = powerFracs(:,ids(i)) .* lineMask;
                end
                
                % apply power boxes
                powerFracsPb = powerFracs;
                for pb = obj.beams.powerBoxes
                    ry1 = pb.rect(2);
                    ry2 = pb.rect(2)+pb.rect(4);
                    
                    % correct for sinusoidal velocity
                    xs = ([pb.rect(1) pb.rect(1)+pb.rect(3)] - .5) * 2 * obj.scanners{1}.fillFractionSpatial;
                    tts = asin(xs) / asin(obj.scanners{1}.fillFractionSpatial);
                    xs = (tts + 1) / 2;
                    
                    lineSamps = bSamplesPerLine-1;
                    smpStart = ceil(max(1,min(lineSamps,lineSamps*xs(1))));
                    smpEnd = ceil(max(1,min(lineSamps,lineSamps*xs(2))));
                    lineStart = floor(min(nlines-1,max(0,nlines * ry1)));
                    lineEnd = floor(min(nlines-1,max(0,nlines * ry2)));
                    
                    for ln = lineStart:lineEnd
                        md = mod(ln+1,2)>0;
                        if (md && pb.oddLines) || ((~md) && pb.evenLines)
                            if obj.scanners{1}.bidirectionalScan && mod(ln,2)
                                se = bSamplesPerLine - smpStart;
                                ss = bSamplesPerLine - smpEnd;
                            else
                                ss = smpStart;
                                se = smpEnd;
                            end
                            powerFracsPb(bSamplesPerLine*ln+ss:bSamplesPerLine*ln+se,:) = repmat(pb.powers,se-ss+1,1);
                        end
                    end
                end

                if any(pzAdjust)
                    % create array of z position corresponding to each sample

                    if dzdt ~= 0
                        lineSampleTimes = nan(bSamplesPerLine,nlines);
                        lineSampleTimes(1,:) = linspace(0,obj.linePeriod(scanfield)*(nlines-1),nlines);
                        lineSampleTimes(1,:) = lineSampleTimes(1,:) + 0.25*((1-obj.scanners{1}.fillFractionTemporal) * obj.scanners{1}.scannerPeriod);
                        for i = 1:nlines
                            lineSampleTimes(:,i) = linspace(lineSampleTimes(1,i), lineSampleTimes(1,i) + (bSamplesPerLine-1)/hBm.sampleRateHz, bSamplesPerLine);
                        end
                        lineSampleZs = actz + lineSampleTimes * dzdt;
                        lineSampleZs = reshape(lineSampleZs,[],1);
                    else
                        lineSampleZs = actz * ones(size(powerFracs,1),1);
                    end

                    % scale power fracs using Lz
                    adj = find(pzAdjust == true);
                    for beamIdx = adj                        
                        LzArray = repmat(Lzs(beamIdx), bSamplesPerLine*nlines,1);
                        
                        nanMask = isnan(powerFracs(:,beamIdx));
                        nanMaskPb = isnan(powerFracsPb(:,beamIdx));
                       
                        powerFracs(:,beamIdx) = obj.beams.powerDepthCorrectionFunc(beamIdx,powerFracs(:,beamIdx), zPowerReference, lineSampleZs, LzArray);
                        if obj.hasPowerBox
                            powerFracsPb(:,beamIdx) = obj.beams.powerDepthCorrectionFunc(beamIdx,powerFracsPb(:,beamIdx), zPowerReference, lineSampleZs, LzArray);
                        end
                        
                        powerFracs(nanMask,beamIdx) = 0;
                        powerFracsPb(nanMaskPb,beamIdx) = 0;
                        
                    end
                end
                
                % IDs of the beams actually being used in this acq
                bIDs = hBm.beamIDs;
                
                % convert fracs to voltage
                for i = 1:numel(bIDs)
                    path_FOV.B(:,i) = min(powerFracs(:,bIDs(i)),hBm.powerLimits(bIDs(i))) / 100;
                    if obj.hasPowerBox
                        pFs = powerFracsPb(:,bIDs(i));
                        path_FOV.Bpb(:,i) = min(pFs,hBm.powerLimits(bIDs(i))) / 100;
                        path_FOV.Bpb(isnan(pFs),i) =  path_FOV.B(isnan(pFs),i);
                    end
                end
            end
            
            if obj.hasFastZ
                if strcmp(zActuator,'slow')
                    actz = 0;
                end
                if obj.fastz.useScannerTimebase
                    seconds = secondsG;
                    dzdt = dzdt / obj.modifiedTimebaseSecsPerSec;
                end
                path_FOV.Z = obj.fastz.scanPathFOV(obj,zPowerReference,actz,dzdt,seconds,path_FOV.G);
            end
        end
        
        function calibrateScanner(obj,scanner,hWb)
            if nargin < 3 || isempty(hWb)
                hWb = [];
            end
            
            switch upper(scanner)
                case 'G'
                    if ~isempty(obj.scanners{2})
                        obj.scanners{2}.hDevice.calibrate(hWb);
                    end
                    obj.scanners{3}.hDevice.calibrate(hWb);
                case 'Z'
                    obj.fastz.hDevice.calibrate();
                otherwise
                    error('Cannot optimized scanner %s', scanner);
            end
        end
        
        %% Optimization Functions
        %%
        function position_FOV = mirrorsActiveParkPosition(obj)
            position_FOV=zeros(1,3);
            position_FOV(:,1) = NaN; % we can't really calculate that here. the resonant scanner amplitude should not be touched for the flyback. NaN makes sure that nobody accidentally tries to use this value.
            if ~isempty(obj.scanners{2})
                position_FOV(:,2) = obj.scanners{2}.parkAngleDegrees;
            else
                position_FOV(:,2) = 0;
            end
            position_FOV(:,3) = obj.scanners{3}.parkAngleDegrees;
            position_FOV(:,2:3) = scanimage.mroi.util.xformPoints(position_FOV(:,2:3),obj.scannerToRefTransform);
        end

        function path_FOV = interpolateTransits(obj,path_FOV,tuneZ,zWaveformType)
            if nargin < 3
                tuneZ = true;
            end
            if nargin < 4
                zWaveformType = '';
            end
            
            if ~isempty(obj.scanners{2})
                xrg = diff(obj.scanners{2}.travelRange);
            else
                xrg = 0;
            end
            
            pts = [xrg diff(obj.scanners{3}.travelRange)];
            pts = [-pts; pts] * .5;
            pts = scanimage.mroi.util.xformPoints(pts,obj.scannerToRefTransform);
            
            xGalvoRg = [pts(1,1) pts(2,1)];
            yGalvoRg = [pts(1,2) pts(2,2)];
            
            path_FOV.R(:,1) = scanimage.mroi.util.interpolateCircularNaNRanges(path_FOV.R);
            path_FOV.G(:,1) = scanimage.mroi.util.interpolateCircularNaNRanges(path_FOV.G(:,1),xGalvoRg);
            path_FOV.G(:,2) = scanimage.mroi.util.interpolateCircularNaNRanges(path_FOV.G(:,2),yGalvoRg);
            
            % beams ao
            if obj.hasBeams
                hBm = obj.beams;
                bIDs = hBm.beamIDs;
                if hBm.flybackBlanking || any(hBm.interlaceDecimation(bIDs) > 1)
                    for ctr = 1:numel(bIDs)
                        path_FOV.B(isnan(path_FOV.B(:,ctr)),ctr) = 0;
                    end
                else
                    for ctr = 1:numel(bIDs)
                        path_FOV.B(:,ctr) = scanimage.mroi.util.expInterpolateCircularNaNRanges(path_FOV.B(:,ctr),hBm.Lzs(bIDs(ctr)));
                        path_FOV.B(end,ctr) = 0;
                    end
                end
                
                if obj.hasPowerBox
                    if hBm.flybackBlanking || any(hBm.interlaceDecimation(bIDs) > 1)
                        for ctr = 1:numel(bIDs)
                            path_FOV.Bpb(isnan(path_FOV.Bpb(:,ctr)),ctr) = 0;
                        end
                    else
                        for ctr = 1:numel(bIDs)
                            path_FOV.Bpb(:,ctr) = scanimage.mroi.util.expInterpolateCircularNaNRanges(path_FOV.Bpb(:,ctr),hBm.Lzs(bIDs(ctr)));
                            path_FOV.Bpb(end,ctr) = 0;
                        end
                    end
                end
            end
            
            if obj.hasFastZ
                path_FOV.Z = obj.fastz.interpolateTransits(obj,path_FOV.Z,tuneZ,zWaveformType);
            end
        end

        function [path_FOV, dt] = transitNaN(obj,scanfield_from,scanfield_to)
            assert(scanimage.mroi.util.transitArgumentTypeCheck(scanfield_from,scanfield_to));
            
            dt = obj.transitTime(scanfield_from,scanfield_to);
            if isnan(scanfield_to)
                dt = 0; % flyback time is added in padFrameAO
            end      
            
            rsamples = round(dt*obj.scanners{1}.sampleRateHz);
            path_FOV.R = nan(rsamples,1);
            
            gsamples = round(dt*obj.scanners{3}.sampleRateHz);
            path_FOV.G = nan(gsamples,2);
            
            if obj.hasBeams
                hBm = obj.beams;
                [lineScanPeriod,lineAcquisitionPeriod] = obj.linePeriod([]);
                bExtendSamples = floor(hBm.beamClockExtend * 1e-6 * hBm.sampleRateHz);
                bSamplesPerLine = ceil(lineAcquisitionPeriod*hBm.sampleRateHz) + 1 + bExtendSamples;
                nlines = round(dt/lineScanPeriod);
                path_FOV.B = nan(bSamplesPerLine*nlines,numel(hBm.beamIDs));
                if obj.hasPowerBox
                    path_FOV.Bpb = path_FOV.B;
                end
            end
            
            if obj.hasFastZ
                path_FOV.Z = obj.fastz.transitNaN(obj,dt);
            end
        end
        
        function path_FOV = zFlybackFrame(obj, frameTime)
            frameTimeRTB = frameTime * obj.modifiedTimebaseSecsPerSec;
            
            if obj.scanners{3}.useScannerTimebase
                path_FOV.R = nan(round(obj.nsamples(obj.scanners{1},frameTimeRTB)),1);
                path_FOV.G = nan(round(obj.nsamples(obj.scanners{3},frameTimeRTB)),2);
            else
                path_FOV.R = nan(round(obj.nsamples(obj.scanners{1},frameTime)),1);
                path_FOV.G = nan(round(obj.nsamples(obj.scanners{3},frameTime)),2);
            end
            
            % Beams AO
            if obj.hasBeams
                hBm = obj.beams;
                [lineScanPeriod,lineAcquisitionPeriod] = obj.linePeriod([]);
                bExtendSamples = floor(hBm.beamClockExtend * 1e-6 * hBm.sampleRateHz);
                bSamplesPerLine = ceil(lineAcquisitionPeriod*hBm.sampleRateHz) + 1 + bExtendSamples;
                nlines = round(frameTime/lineScanPeriod);
                
                if hBm.flybackBlanking
                    path_FOV.B = zeros(bSamplesPerLine*nlines,numel(hBm.beamIDs));
                else
                    path_FOV.B = NaN(bSamplesPerLine*nlines,numel(hBm.beamIDs));
                end
                if obj.hasPowerBox
                    path_FOV.Bpb = path_FOV.B;
                end
            end
            
            if obj.hasFastZ
                if obj.fastz.useScannerTimebase
                    frameTime = frameTimeRTB;
                end
                path_FOV.Z = obj.fastz.zFlybackFrame(obj,frameTime);
            end
        end
        
        function path_FOV = padFrameAO(obj, path_FOV, frameTime, flybackTime, zWaveformType)
            waveformTime = frameTime + flybackTime;
            waveformTimeRTB = waveformTime * obj.modifiedTimebaseSecsPerSec;
            
            if obj.scanners{3}.useScannerTimebase
                % 40us gap between waveforms to allow for period drift
                % and scan phase adjustments
                marg = 40e-6 * obj.scanners{3}.sampleRateHz;
                Ns = ceil(obj.nsamples(obj.scanners{3},waveformTimeRTB)-marg);
            else
                Ns = ceil(obj.nsamples(obj.scanners{3},frameTime + flybackTime/2));
            end
            padSamples = Ns - size(path_FOV.G,1); % cut off half of the flyback time to leave some breathing room to receive the next frame trigger
            if padSamples > 0
                path_FOV.R(end+1:end+padSamples,:) = NaN;
                path_FOV.G(end+1:end+padSamples,:) = NaN;
            end
            
            % Beams AO
            if obj.hasBeams
                hBm = obj.beams;
                [lineScanPeriod,lineAcquisitionPeriod] = obj.linePeriod([]);
                bExtendSamples = floor(hBm.beamClockExtend * 1e-6 * hBm.sampleRateHz);
                bSamplesPerLine = ceil(lineAcquisitionPeriod*hBm.sampleRateHz) + 1 + bExtendSamples;
                nlines = round(frameTime/lineScanPeriod);
                nTotalSamples = bSamplesPerLine * nlines;
                padSamples = nTotalSamples - size(path_FOV.B,1);
                if padSamples > 0
                    path_FOV.B(end+1:end+padSamples,:) = NaN;
                    if obj.hasPowerBox
                        path_FOV.Bpb(end+1:end+padSamples,:) = NaN;
                    end
                end
            end
            
            if obj.hasFastZ
                if obj.fastz.useScannerTimebase
                    waveformTime = waveformTimeRTB - 1/obj.fastz.sampleRateHz;
                end
                path_FOV.Z = obj.fastz.padFrameAO(obj, path_FOV.Z, waveformTime, zWaveformType);
            end
        end
        
        function v = frameFlybackTime(obj)
            v = obj.scanners{3}.flybackTimeSeconds;
        end

        function seconds = scanTime(obj,scanfield)
            %% Returns the time required to scan the scanfield in seconds
            if isa(scanfield,'scanimage.mroi.scanfield.fields.IntegrationField')
                seconds = 0;
            else
                numLines = scanfield.pixelResolution(2);
                seconds = (numLines/2^(obj.scanners{1}.bidirectionalScan))*obj.scanners{1}.scannerPeriod; %eg 512 lines / (7920 lines/s)
                % dont coerce to galvo sample rate
%                 numSamples = round(seconds * obj.scanners{3}.sampleRateHz);
%                 seconds = numSamples / obj.scanners{3}.sampleRateHz;
            end
        end

        function [lineScanPeriod,lineAcquisitionPeriod] = linePeriod(obj,scanfield)
            % Definition of lineScanPeriod:
            %   * scanPeriod is lineAcquisitionPeriod + includes the turnaround time for MROI scanning
            % Definition of lineAcquisitionPeriod:
            %   * lineAcquisitionPeriod is the period that is actually used for the image acquisition

            % These are set to the line scan period of the resonant scanner. Since the resonant scanner handles image
            % formation, these parameters do not have the same importance as in Galvo Galvo scanning.
            lineScanPeriod = obj.scanners{1}.scannerPeriod / 2^(obj.scanners{1}.bidirectionalScan);
            lineAcquisitionPeriod = obj.scanners{1}.scannerPeriod / 2 * obj.scanners{1}.fillFractionTemporal;
        end

        function [startTimes, endTimes] = acqActiveTimes(obj,scanfield)
            % TODO: implement this
            startTimes = NaN;
            endTimes   = NaN;
        end

        function seconds = transitTime(obj,scanfield_from,scanfield_to)
            %% Returns the estimated time required to position the scanners when
            % moving from scanfield to scanfield.
            % Must be a multiple of the line time
            assert(scanimage.mroi.util.transitArgumentTypeCheck(scanfield_from,scanfield_to));

            % FIXME: compute estimated transit time for reals
            % caller should constraint this to be an integer number of periods
            if isnan(scanfield_from)
                seconds = 0; % do not scan first flyto in plane
            elseif isnan(scanfield_to)
                seconds = max(obj.scanners{3}.flybackTimeSeconds,obj.scanners{3}.flybackTimeSeconds);
            else
                seconds = max(obj.scanners{3}.flytoTimeSeconds,obj.scanners{3}.flytoTimeSeconds);
            end
        end
        
        function samplesPerTrigger = samplesPerTriggerForAO(obj,outputData)
            % input: unconcatenated output for the stack
            samplesPerTrigger.G = max( cellfun(@(frameAO)size(frameAO.G,1),outputData) );
            
            if obj.hasBeams
                hBm = obj.beams;
                [~,lineAcquisitionPeriod] = obj.linePeriod([]);
                bExtendSamples = floor(hBm.beamClockExtend * 1e-6 * hBm.sampleRateHz);
                samplesPerTrigger.B = ceil( lineAcquisitionPeriod * hBm.sampleRateHz ) + 1 + bExtendSamples;
            end
            
            if obj.hasFastZ
                samplesPerTrigger.Z = obj.fastz.samplesPerTriggerForAO(obj,outputData);
            end
        end
        
        function cfg = beamsTriggerCfg(obj)
            cfg = struct();
            if obj.hasBeams
                cfg.triggerType = 'lineClk';
                cfg.requiresReferenceClk = false;
            else
                cfg.triggerType = '';
                cfg.requiresReferenceClk = [];
            end
        end
        
        function v = resonantScanFov(obj, roiGroup)
            % returns the resonant fov that will be used to scan the
            % roiGroup. Assumes all rois will have the same x fov
            if ~isempty(roiGroup.activeRois) && ~isempty(roiGroup.activeRois(1).scanfields)
                %avoid beam and fast z ao generation
                b = obj.beams;
                z = obj.fastz;
                obj.beams = {};
                obj.fastz = {};
                
                try
                    [path_FOV,~] = obj.scanPathFOV(roiGroup.activeRois(1).scanfields(1),roiGroup.activeRois(1),0,0,0,'');
                    path_FOV = obj.refFovToScannerFov(path_FOV);
                    v = path_FOV.R(1) / obj.scanners{1}.fullAngleDegrees;
                catch ME
                    obj.beams = b;
                    obj.fastz = z;
                    ME.rethrow;
                end
                
                obj.beams = b;
                obj.fastz = z;
            else
                v = 0;
            end
        end
        
        function v = resonantScanVoltage(obj, roiGroup)
            % returns the resonant voltage that will be used to scan the
            % roiGroup. Assumes all rois will have the same x fov
            if ~isempty(roiGroup.activeRois) && ~isempty(roiGroup.activeRois(1).scanfields)
                %avoid beam and fast z ao generation
                b = obj.beams;
                z = obj.fastz;
                obj.beams = {};
                obj.fastz = {};
                
                try
                    [path_FOV,~] = obj.scanPathFOV(roiGroup.activeRois(1).scanfields(1),roiGroup.activeRois(1),0,0,0);
                    ao_volts = obj.pathFovToAo(path_FOV);
                    v = ao_volts.R(1);
                catch ME
                    obj.beams = b;
                    obj.fastz = z;
                    ME.rethrow;
                end
                
                obj.beams = b;
                obj.fastz = z;
            else
                v = 0;
            end
        end
    end

    methods
        function volts=degrees2volts(obj,fov,iscanner)
            s=obj.scanners{iscanner};
            if isa(s,'scanimage.mroi.scanners.Resonant')
                u_fov = unique(fov);
                u_fov(isnan(u_fov)) = [];
                volts = fov; %preallocate, copy nan's
                for i = 1:numel(u_fov)
                    volts(fov == u_fov(i)) = s.fov2VoltageFunc(u_fov(i) / s.fullAngleDegrees);
                end
            elseif (iscanner == 2) && isempty(s)
                volts = fov;
            else
                volts = s.position2Volts(fov);
            end
        end
    end
    
    %% Property access methods
    methods
        function v = get.angularRange(obj)
            if obj.resonantLimitedFovMode || isempty(obj.scanners{2})
                v = [obj.scanners{1}.fullAngleDegrees diff(obj.scanners{3}.travelRange)];
            else
                v = [obj.scanners{1}.fullAngleDegrees+diff(obj.scanners{2}.travelRange) diff(obj.scanners{3}.travelRange)];
            end
        end
    end
end


%--------------------------------------------------------------------------%
% ResonantGalvoGalvo.m                                                     %
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
