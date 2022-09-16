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

        function analyzeFile(file, centerOfBeatingDistance)

            %Load file
            load(file);

            %Load the image
            reader = BioformatsImage(inputFile);

            I = getPlane(reader, 1, 1, 1);

            imshow(I, [])

            roi = drawrectangle;  %roi = [xmin, ymin, width, height]
            wait(roi);

            xmin = round(roi.Position(1));
            ymin = round(roi.Position(2));
            width = round(roi.Position(3));
            height = round(roi.Position(4));

            Cx = xmin:(xmin + width);
            Cy = ymin:(ymin + height);

            [Cx, Cy] = meshgrid(Cx, Cy);


            meanMotion = zeros([size(Cx), reader.sizeT]);
            for iT = 1:reader.sizeT

                meanMotion(:, :, iT) = MFA.computeMotion(storeX, storeY, storeU(:, :, iT), storeV(:, :, iT), Cx, Cy);

            end

            %Find the center of beating
            modeContraction = mode(round(meanMotion, 5, 'significant'), 3);
            meanMotionNorm = meanMotion - modeContraction;

            %Compute the maximum value (max contraction)
            maxContraction = max(meanMotionNorm, [], 3);

            %Compute the minimum value (max dilation)
            minContraction = min(meanMotionNorm, [], 3);

            %Compute the difference in contraction values
            diffContraction = maxContraction + minContraction;

            %Find the position of the smallest difference
            





        end

%         function [maxPixelVelocity, heartbeatRate, roiCenter] = analyzeFile(file, centerOfBeatingDistance)
% 
%             %Load file
%             load(file);
% 
%             %Load the image
%             reader = BioformatsImage(inputFile);
% 
%             I = getPlane(reader, 1, 1, 1);
% 
%             imshow(I, [])
% 
%             %Click to determine the center of beating
%             [x, y] = ginput(1);
% 
%             %Find points that are within the ROI
%             [XX, YY] = meshgrid(storeX, storeY);
% 
%             idx = find( ((XX - x).^2 + (YY - y).^2) <= centerOfBeatingDistance^2 );
% 
%             storeDisplacementTime = zeros(1, reader.sizeT);
%             for iT = 1:reader.sizeT
% 
%                 storeDisplacements = zeros(1, numel(idx));
%                 for ii = 1:numel(idx)
% 
%                     %For each point, determine the unit vector towards the CoB
%                     uvec = [XX(idx(ii)) - x, YY(idx(ii)) - y];
%                     uvec = uvec ./ (sqrt(uvec(1)^2 + uvec(2)^2));
% 
%                     %Compute the displacement vector
%                     uu = storeU(:, :, iT);
%                     vv = storeV(:, :, iT);
% 
%                     vvec = [XX(idx(ii)) - uu(idx(ii)), YY(idx(ii)) - vv(idx(ii))];
% 
%                     %Compute the dot vector
%                     storeDisplacements(ii) = dot(vvec, uvec);
%                 end
% 
%                 storeDisplacementTime(iT) = mean(storeDisplacements);
% 
%             end
% 
%             meanDisp = mean(storeDisplacementTime);
% 
%             %Find peaks
%             [pks, locs] = findpeaks((storeDisplacementTime - meanDisp), 'MinPeakProminence', 0.05);
% 
%             tt = 1:numel(storeDisplacementTime);
%             plot(tt, (storeDisplacementTime - meanDisp), tt(locs), pks, 'ro');
% 
%             maxPixelVelocity = max(pks);
%             heartbeatRate = mean(diff(tt(locs)));
%             roiCenter = [x, y];
% 
%         end

        function meanMotion = computeMotion(X, Y, U, V, Cx, Cy)
            %COMPUTEMOTION  Compute the motion towards a point
            %
            %  COMPUTEMOTION(X, Y, U, V, Cx, Cy) computes the average
            %  motion of a vector field towards a point. The vector field
            %  is defined by 

            %Validate inputs
            if isvector(X) && isvector(Y)

                [X, Y] = meshgrid(X, Y);

            elseif ismatrix(X) && ismatrix(Y)

                %Do nothing

            else

                error('MotionFlowAnalyzer:computeMotion:XYIncorrectSize', ...
                    'Expected X and Y to be both vectors or matrices.')

            end

            if ~isequal(size(X), size(Y), size(U), size(V))

                error('MotionFlowAnalyzer:computeMotion:XYUVSizeMismatch', ...
                    'X, Y, U, and V have non-matching sizes.')

            end

            if ~isequal(size(Cx), size(Cy))

                error('MotionFlowAnalyzer:computeMotion:CxCySizeMismatch', ...
                    'Expected Cx and Cy to have the same size.')

            end

            %Declare output matrix
            meanMotion = zeros(size(Cx));
            
            for iPt = 1:numel(Cx)

                %Compute unit vectors from the center of each subimage to
                %the current center of beating
                Ux = X - Cx(iPt);
                Uy = Y - Cy(iPt);

                uvecMag = sqrt(Ux.^2 + Uy.^2);

                Ux = Ux ./ uvecMag;
                Uy = Uy ./ uvecMag;

                %Compute the displacement vector
                Vx = X + U;
                Vy = Y + V;

                %Compute the dot product
                dotProd = Ux .* Vx + Uy .* Vy;

                %Compute the mean displacement
                meanMotion(iPt) = mean(dotProd, 'all');

            end

        end


    end


end