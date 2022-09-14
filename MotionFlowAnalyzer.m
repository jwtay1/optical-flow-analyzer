classdef MotionFlowAnalyzer

    properties

        centerOfBeatingDistance = 100;

    end

    methods

        function analyze(obj, files, outputFN)

            storeMaxPxVel = zeros(1, numel(files));
            storeHeartbeatRate = zeros(1, numel(files));

            for iFile = 1:numel(files)

                [storeMaxPxVel(iFile), storeHeartbeatRate(iFile), roiCenter] = ...
                    MotionFlowAnalyzer.analyzeFile(...
                    fullfile(files(iFile).folder, files(iFile).name), ...
                    obj.centerOfBeatingDistance);

            end

            save(outputFN, 'storeMaxPxVel', 'storeHeartbeatRate', ...
                'roiCenter');

        end

    end

    methods (Static)

        function [maxPixelVelocity, heartbeatRate, roiCenter] = analyzeFile(file, centerOfBeatingDistance)

            %Load file
            load(file);

            %Load the image
            reader = BioformatsImage(inputFile);

            I = getPlane(reader, 1, 1, 1);

            imshow(I, [])

            %Click to determine the center of beating
            [x, y] = ginput(1);

            %Find points that are within the ROI
            [XX, YY] = meshgrid(storeX, storeY);

            idx = find( ((XX - x).^2 + (YY - y).^2) <= centerOfBeatingDistance^2 );

            storeDisplacementTime = zeros(1, reader.sizeT);
            for iT = 1:reader.sizeT

                storeDisplacements = zeros(1, numel(idx));
                for ii = 1:numel(idx)

                    %For each point, determine the unit vector towards the CoB
                    uvec = [XX(idx(ii)) - x, YY(idx(ii)) - y];
                    uvec = uvec ./ (sqrt(uvec(1)^2 + uvec(2)^2));

                    %Compute the displacement vector
                    uu = storeU(:, :, iT);
                    vv = storeV(:, :, iT);

                    vvec = [XX(idx(ii)) - uu(idx(ii)), YY(idx(ii)) - vv(idx(ii))];

                    %Compute the dot vector
                    storeDisplacements(ii) = dot(vvec, uvec);
                end

                storeDisplacementTime(iT) = mean(storeDisplacements);

            end

            meanDisp = mean(storeDisplacementTime);

            %Find peaks
            [pks, locs] = findpeaks((storeDisplacementTime - meanDisp), 'MinPeakProminence', 0.05);

            tt = 1:numel(storeDisplacementTime);
            plot(tt, (storeDisplacementTime - meanDisp), tt(locs), pks, 'ro');

            maxPixelVelocity = max(pks);
            heartbeatRate = mean(diff(tt(locs)));
            roiCenter = [x, y];

        end


    end


end