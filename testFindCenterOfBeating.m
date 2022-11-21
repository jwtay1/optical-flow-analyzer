clearvars
clc

% dataDir = 'D:\Projects\Research\2022-optical-flow-analyzer\processed_increasedDisp';
% outputDir = 'D:\Projects\Research\2022-optical-flow-analyzer\final';

dataDir = 'D:\Projects\Research\2022-optical-flow-analyzer\data\Cindy Xinyi Fu\processed';
outputDir = 'D:\Projects\Research\2022-optical-flow-analyzer\data\Cindy Xinyi Fu\processed';

files = dir(fullfile(dataDir, '*.mat'));

for iFile = 1:numel(files)

    %load('D:\Projects\Research\2022-optical-flow-analyzer\processed_increasedDisp\wnt_12345_2_005.mat');
    load(fullfile(dataDir, files(iFile).name));

    reader = BioformatsImage(inputFile);

%     I = getPlane(reader, 1, 1, 1);

%     imshow(I, [])
%     roi = drawrectangle;
%     wait(roi);
% 
%     disp('done')

    roi.Position = [1 1 reader.width, reader.height];

    %% Find the center of beating within the region

    [XX, YY] = meshgrid(storeX, storeY);

    %pos = [xmin ymin width height]
    xmin = roi.Position(1);
    ymin = roi.Position(2);
    width = roi.Position(3);
    height = roi.Position(4);

    xROI = linspace(xmin, xmin + width, 20);
    yROI = linspace(ymin, ymin + height, 20);

    %idx = find(inROI(roi, XX, YY));
    idx = 1:numel(XX);

    diffContraction = zeros(numel(yROI), numel(xROI));

    for iX = 1:numel(xROI)
        for iY = 1:numel(yROI)

            x = xROI(iX);
            y = yROI(iY);

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

            %Find the zero point
            zeroDisp = mode(round(storeDisplacementTime, 3, 'significant'));
            normDisp = storeDisplacementTime - zeroDisp;

            %Compute inward vs outward motion towards the point
            maxContraction = max(normDisp);
            minContraction = min(normDisp);

            diffContraction(iY, iX) = abs(maxContraction - abs(minContraction));

        end
    end
    %%
    %Find the center of beating
    [iCoB, jCoB] = find(diffContraction == max(diffContraction, [], 'all'));

    %Need to include XX and YY somehow

    xCoB = xROI(jCoB);
    yCoB = yROI(iCoB);

    figure(1);
%     imshow(I, [])
%     hold on
%     plot(xCoB, yCoB, 'ro')
%     plot(xmin, ymin, 'x')
%     hold off

    %Make a video to validate the CoB
    [~, fn] = fileparts(inputFile);

    vid = VideoWriter(fullfile(outputDir, [fn, '_CoB.avi']));
    vid.FrameRate = 5;
    open(vid)

    for iT = 1:reader.sizeT

        I = double(getPlane(reader, 1, 1, iT));
        I = (I - min(I(:)))/(max(I(:)) - min(I(:)));

        I = insertShape(I, 'circle', [xCoB, yCoB, 5]);
        writeVideo(vid, I);
    end


    close(vid)

    %% Compute beating
    storeDisplacementTime = zeros(1, reader.sizeT);
    for iT = 1:reader.sizeT

        storeDisplacements = zeros(1, numel(idx));
        for ii = 1:numel(idx)

            %For each point, determine the unit vector towards the CoB
            uvec = [XX(idx(ii)) - xCoB, YY(idx(ii)) - yCoB];
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

    % figure(2)
    % plot(storeDisplacementTime)

    %Find the zero point
    zeroDisp = mode(round(storeDisplacementTime, 3, 'significant'));
    normDisp = storeDisplacementTime - zeroDisp;

    %Compute inward vs outward motion towards the point
    maxContraction = max(normDisp);
    minContraction = min(normDisp);

    %Normalize beating to integrated area
    fprintf([files(iFile).name, ' \n'])
    disp([xCoB, yCoB])
    disp(max(abs([maxContraction, minContraction])))

    %Add 


end

%TODO:
% * Measure motion around CoB
% * Compute average motion
% * 


