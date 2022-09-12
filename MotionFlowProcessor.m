classdef MotionFlowProcessor

    properties

        maxDisplacement = 7;
        blockSize = [32 32];

    end

    methods

        function process(obj, varargin)

            %Handle input files
            if numel(varargin) >= 1

                inputFiles = varargin{1};

                if ~iscell(inputFiles)
                    inputFiles = {inputFiles};
                end

            else

                [files, fpath] = uigetfile({'*.nd2', 'Nikon ND2 File (*.nd2)'; ...
                    '*.*', 'All Files (*.*)'}, ...
                    'MultiSelect', 'on');

                %Cancel button was clicked
                if isequal(files, 0)
                    return
                end

                if ~iscell(files)

                    inputFiles = {fullfile(fpath, files)};

                else
                    for ii = 1:numel(files)

                        inputFiles{ii} = fullfile(fpath, files{ii});

                    end
                end

            end

            if numel(varargin) >= 2

                outputDir = varargin{2};

            else

                %Get output directory
                outputDir = uigetdir('', 'Select output directory');

                if isequal(outputDir, 0)
                    return
                end

            end

            if ~exist(outputDir, 'dir')
                mkdir(outputDir)
            end

            %Generate a structure to store options
            opts.maxDisplacement = obj.maxDisplacement;
            opts.blockSize = obj.blockSize;

            %Process files
            for iF = 1:numel(inputFiles)

                MotionFlowProcessor.processFile(inputFiles{iF}, outputDir, opts)

            end

        end

    end

    methods (Static)

        function processFile(inputFile, outputDir, opts)
            %PROCESSFILE  Process a single movie file
            %
            %  PROCESSFILE(FN, OUTDIR) will process the timelapse file FN
            %  specified. After processing, several output files will be
            %  generated and saved to the folder OUTPUTDIR.

            %Create a new BioformatsImage object to read in the file
            reader = BioformatsImage(inputFile);

            %Generate output filename
            [~, outputFN] = fileparts(inputFile);

            %Generate row and column indices to divide the image
            [R, C] = getBlockIdxs([reader.height, reader.width], opts.blockSize, opts.maxDisplacement);

            %Generate a vector of displacements
            dispVector = -opts.maxDisplacement:opts.maxDisplacement;

            %Create a video file
            vid = VideoWriter(fullfile(outputDir, [outputFN, '.avi']));
            vid.FrameRate = 5;
            open(vid)

            %---Start processing---

            %Compute X and Y vectors
            storeX = zeros(numel(C) - 1, 1);
            for xx = 1:(numel(C) - 1)
                storeX(xx) = mean([C(xx),(C(xx + 1) - 1)]);
            end

            storeY = zeros(numel(R) - 1, 1);
            for yy = 1:(numel(R) - 1)
                storeY(yy) = mean([R(yy),(R(yy + 1) - 1)]);
            end

            %Initialize matrices for storage
            storeU = zeros(numel(R) - 1, numel(C) - 1, reader.sizeT);
            storeV = storeU;

            %storeDisplacement = cell(numel(R) - 1, numel(C) - 1, reader.sizeT);

            %Read in first frame as the reference
            Iref = getPlane(reader, 1, 1, 1);

            for iT = 1:reader.sizeT

                %Read in the next frame
                Imoved = getPlane(reader, 1, 1, iT);

                %Create output image
                figure(99)
                imshow(Imoved, [])
                hold on

                for iRow = 1:(numel(R) - 1)
                    for iCol = 1:(numel(C) - 1)

                        %Read in the current template
                        currTemplate = Imoved(R(iRow):(R(iRow + 1) - 1), C(iCol):(C(iCol + 1) - 1));

                        %Initialize matrix for error score
                        errScore = zeros(2 * opts.maxDisplacement + 1);

                        for dRow = 1:numel(dispVector)
                            for dCol = 1:numel(dispVector)

                                refRowStart = R(iRow) + dispVector(dRow);
                                refRowEnd = R(iRow + 1) + dispVector(dRow) - 1;

                                refColStart = C(iCol) + dispVector(dCol);
                                refColEnd = C(iCol + 1) + dispVector(dCol) - 1;

                                %Crop the reference image to the right section
                                currRefSection = Iref(...
                                    refRowStart:refRowEnd, ...
                                    refColStart:refColEnd);

                                %Compute the MAD score
                                errScore(dRow, dCol) = immse(currRefSection, currTemplate);
                            end
                        end

                        %Find the direction and magnitude of the maximum displacement
                        [~, maxIdx] = min(errScore, [], 'all');

                        %Store the displacement
                        [I, J] = ind2sub([numel(dispVector), numel(dispVector)], maxIdx);

                        storeU(iRow, iCol, iT) = -dispVector(J);
                        storeV(iRow, iCol, iT) = -dispVector(I);

                    end
                end

                %Generate the output image - add arrows
                quiver(storeX, storeY, storeU(:, :, iT), storeV(:, :, iT))
                hold off

                %Write to video
                writeVideo(vid, getframe(gcf))

                Iref = Imoved;

            end

            close(vid)

            %Save the data
            save(fullfile(outputDir, [outputFN, '.mat']), 'store*', 'inputFile', 'opts')

        end

        function getBlockIdxs(imgSize, blockSize, varargin)
            %GETBLOCKIDXS  Divide an image into blocks
            %
            %  [R, C] = GETBLOCKIDXS(IMGSIZE, BLOCKSIZE) returns row and column indices
            %  in R and C that divides an image into blocks of the specified size. Note
            %  if the image cannot be evenly divided into blocks of the specified size,
            %  parts of the image might not be included. IMGSIZE should be a 2x1 vector
            %  specifying the [rows cols] of the image to be divided. BLOCKSIZE should
            %  be a 2x1 vector specifying the [HEIGHT WIDTH] of the resulting blocks.

            if ~isempty(varargin)
                numPixelBuffer = varargin{1};
            else
                numPixelBuffer = 0;
            end

            rowIdxs = (1 + numPixelBuffer):blockSize(1):(imgSize(1) - numPixelBuffer);
            colIdxs = (1 + numPixelBuffer):blockSize(2):(imgSize(2) - numPixelBuffer);
        end

    end



end