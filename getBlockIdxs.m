function [rowIdxs, colIdxs] = getBlockIdxs(imgSize, blockSize)
%GETBLOCKIDXS  Divide an image into blocks
%
%  [R, C] = GETBLOCKIDXS(IMGSIZE, BLOCKSIZE) returns row and column indices
%  in R and C that divides an image into blocks of the specified size. Note
%  if the image cannot be evenly divided into blocks of the specified size,
%  parts of the image might not be included. IMGSIZE should be a 2x1 vector
%  specifying the [rows cols] of the image to be divided. BLOCKSIZE should
%  be a 2x1 vector specifying the [HEIGHT WIDTH] of the resulting blocks.

rowIdxs = 1:blockSize(1):imgSize(1);
colIdxs = 1:blockSize(1):imgSize(2);