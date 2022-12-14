%Script for bulk processing
% 
% folders = {'D:\Projects\Research\2022-optical-flow-analyzer\data\const', ...
%     'D:\Projects\Research\2022-optical-flow-analyzer\data\mature', ...
%     'D:\Projects\Research\2022-optical-flow-analyzer\data\wnt'};

folders = {'D:\Projects\Research\2022-optical-flow-analyzer\data\wnt'};

baseOutputDir = 'D:\Projects\Research\2022-optical-flow-analyzer\processed_increasedDisp';

for iFolder = 1:numel(folders)

    files = dir(fullfile(folders{iFolder}, 'wnt_12345_*.nd2'));

    fileList = {};
    for iFile = 1:numel(files)

        fileList{iFile} = fullfile(files(iFile).folder, files(iFile).name);

    end

    MFP = MotionFlowProcessor;
    MFP.maxDisplacement = 15;
    process(MFP, fileList, baseOutputDir);

end