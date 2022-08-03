function [rowIdx, colIdx] = getBlockIdxs(sizeIn, numBlocks)
%GETBLOCKDXS  Get indices to divide a matrix into blocks 
%
%  [ROW, COL] = GETBLOCKIDXS(SIZE_M, NUMBLOCKS) will generate a series of
%  indices to divide a matrix of size SIZE_M = [numRows, numCols] into the
%  number of mostly equal sized blocks. NUMBLOCKS should be a 2x1 vector
%  specifying the number of sub-blocks desired.
%
%  The algorithm works by dividing the image into equal sized blocks,
%  except for the last 

if any(numBlocks > sizeIn)
    
    error('Number of blocks specified is larger than image size.');
    
end


rowIdx = floor(linspace(1, sizeIn(1), numBlocks(1) + 1));

if rowIdx(end) ~= sizeIn(1)
    rowIdx(end) = sizeIn(1);
end

colIdx = floor(linspace(1, sizeIn(2), numBlocks(2) + 1));

if colIdx(end) ~= sizeIn(2)
    colIdx(end) = sizeIn(2);
end