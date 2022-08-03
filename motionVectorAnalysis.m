clearvars
clc

inputFile = 'D:\Work\Motion UI\data\const_12047_1_001.nd2';

%Parameters
numBlocks = [5, 7];

%% Begin code

reader = BioformatsImage(inputFile);
Iref = getPlane(reader, 1, 1, 1);
Inext = getPlane(reader, 1, 1, 2);

%Divide the image into sub-blocks
colIdxs = 1:floor(reader.width/numBlocks(1)):reader.width;
if colIdxs(end) ~= reader.width
    colIdxs = [colIdxs, reader.width];
end

rowIdxs = 1:floor(reader.height/numBlocks(1)):reader.height;
if rowIdxs(end) ~= reader.height
    rowIdxs = [rowIdxs, reader.width];
end

%Begin optical flow analysis
for iCol = 3
    for iRow = 3
        
        currSubImage = Iref(rowIdxs(iRow):(rowIdxs(iRow + 1) - 1), ...
            colIdxs(iCol):(colIdxs(iCol + 1) - 1));
                
        %Find the displacement
        cc = xcorr2(Inext, currSubImage);
        [max_cc, imax] = max(abs(cc(:)));
        [ypeak, xpeak] = ind2sub(size(cc),imax(1));
        corr_offset = [(ypeak - size(currSubImage,1)) (xpeak - size(currSubImage,2))];
        
        %Display to check
        figure(1)
        imshow(Inext, [])
        hold on
        plot(corr_offset(2), corr_offset(1), 'xr')
        hold off
                
        figure(2)
        imshow(currSubImage, [])
    end
end



