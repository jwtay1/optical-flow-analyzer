clearvars
clc

I = imread('cameraman.tif');

[rowIdx, colIdx] = getBlockIdxs(size(I), [257 256]);

imshow(I);
hold on

%Draw lines
for iRow = 1:numel(rowIdx)    
    plot(xlim, [rowIdx(iRow), rowIdx(iRow)],'g')   
end

for iCol = 1:numel(colIdx)    
    plot([colIdx(iCol), colIdx(iCol)], ylim, 'g')   
end