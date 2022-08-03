clearvars
clc

I = imread('cameraman.tif');

[rowIdxs, colIdxs] = getBlockIdxs(size(I), [8 8]);

%Get an image block for testing
blockIdx = [5 4];

subImage = I(rowIdxs(blockIdx(1)):rowIdxs((blockIdx(1) + 1)), ...
    colIdxs(blockIdx(2)):colIdxs(blockIdx(2) + 1));

%Move the original image
Imoved = circshift(I, [16 20]);

%Calculate the correlation
C = normxcorr2(subImage, Imoved);

[~, maxC] = max(C, [], 'all', 'linear');
[I, J] = ind2sub(size(C), maxC);
pxShift = [I, J] - size(subImage);

offset = pxShift - [rowIdxs(blockIdx(1)), colIdxs(blockIdx(2))];


%surf(C)
%shading flat

%Blend the images to test
% correlatedImages = zeros(size(Imovec));
% correlatedImages(


