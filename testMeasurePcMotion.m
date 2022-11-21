clearvars
clc

dataDir = 'D:\Projects\Research\2022-optical-flow-analyzer\processed_increasedDisp';
outputDir = 'D:\Projects\Research\2022-optical-flow-analyzer\final';

files = dir(fullfile(dataDir, '*.mat'));

motionTh = 10;

for iFile = 1:numel(files)

    load(fullfile(dataDir, files(iFile).name));

    %Compute the absolute motion over time
    sumMotion = sum(abs(storeU + storeV), 3);

    %Compute area of motion
    numMotion = nnz(sumMotion > motionTh);

    pcMoving = (numMotion / (numel(storeU(:, :, 1)))) * 100;

    storeData(iFile).File = files(iFile).name;
    storeData(iFile).pcMoving = pcMoving;

end

plot([storeData.pcMoving])