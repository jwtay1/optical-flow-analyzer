clearvars
clc

inputFile = 'D:\Work\Motion UI\data\const_12047_1_001.nd2';

reader = BioformatsImage(inputFile);
Iref = getPlane(reader, 1, 1, 1);
Inext = getPlane(reader, 1, 1, 5);

%%
numBlocks = [20 20];
[rowIdxs, colIdxs] = getBlockIdxs(size(Iref), numBlocks);

storeCentersX = zeros(numBlocks);
storeCentersY = zeros(numBlocks);
storeMotionX = zeros(numBlocks);
storeMotionY = zeros(numBlocks);

for iRow = 1:(numel(rowIdxs) - 1)
    for iCol = 1:(numel(colIdxs) - 1)
        
        currBlock = Iref(rowIdxs(iRow):rowIdxs(iRow + 1), ...
            colIdxs(iCol):colIdxs(iCol + 1));
        
        pxShift = computeMotion(Inext, currBlock);
        
        offset = pxShift - [rowIdxs(iRow), colIdxs(iCol)];      
        
        %Todo: Move this outside the loop - i.e., collect info and plot
        %later
        
        %Generate a plot
        %Find center of image block
        blockCenterY = (rowIdxs(iRow) + rowIdxs(iRow + 1))/2;
        blockCenterX = (colIdxs(iCol) + colIdxs(iCol + 1))/2;
        
        storeCentersX(iRow, iCol) = blockCenterX;
        storeCentersY(iRow, iCol) = blockCenterY;
        
        storeMotionX(iRow, iCol) = offset(1);
        storeMotionY(iRow, iCol) = offset(2);

    end
end


%%
imshow(Iref, [])
hold on
quiver(storeCentersX(:), storeCentersY(:), -storeMotionX(:), -storeMotionY(:), ...
    'AutoScale', 'on', ...
    'AutoScaleFactor', 30, ...
    'LineWidth', 1);
hold off

%%
figure(2)
imshow(Iref, []);
hold on

%Draw lines
for iRow = 1:numel(rowIdxs)    
    plot(xlim, [rowIdxs(iRow), rowIdxs(iRow)],'g')   
end

for iCol = 1:numel(colIdxs)    
    plot([colIdxs(iCol), colIdxs(iCol)], ylim, 'g')   
end
hold off
