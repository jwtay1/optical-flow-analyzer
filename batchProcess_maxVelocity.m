clearvars
clc

baseDir = 'D:\Projects\Research\2022-optical-flow-analyzer\processed';

wntFiles = dir(fullfile(baseDir, 'wnt*.mat'));

for iFile = 1:numel(wntFiles)

    load(fullfile(wntFiles(iFile).folder, wntFiles(iFile).name))

    displacements = sqrt(storeU.^2 + storeV.^2);

    %Find maximum pixel velocity
    maxDispWnt(iFile) = max(displacements, [], 'all');
end

constFiles = dir(fullfile(baseDir, 'const*.mat'));

for iFile = 1:numel(constFiles)

    load(fullfile(constFiles(iFile).folder, constFiles(iFile).name))

    displacements = sqrt(storeU.^2 + storeV.^2);

    %Find maximum pixel velocity
    maxDispConst(iFile) = max(displacements, [], 'all');
end

matFiles = dir(fullfile(baseDir, 'mat*.mat'));

for iFile = 1:numel(matFiles)

    load(fullfile(matFiles(iFile).folder, matFiles(iFile).name))

    displacements = sqrt(storeU.^2 + storeV.^2);

    %Find maximum pixel velocity
    maxDispMat(iFile) = max(displacements, [], 'all');
end


plot(maxDispWnt, 'o')
hold on
plot(maxDispConst, 'o')
plot(maxDispMat, 'o')
hold off

legend('Wnt', 'Const', 'Mat')