function pxShift = computeMotion(refImg, templateImg)
%COMPUTEMOTION  Compute motion using normalized cross-correlation
%
%  OFFSET = COMPUTEMOTION(REF, TEMPLATE) returns the coordinates for the
%  best match of a template region within a reference image. The algorithm
%  works by computing the normalized 2D cross-correlation between the
%  reference and template images. The position of the maximum of the
%  cross-correlation is then used to determine the offset.

C = normxcorr2(templateImg, refImg);

[~, maxC] = max(C, [], 'all', 'linear');
[I, J] = ind2sub(size(C), maxC);
pxShift = [I, J] - size(templateImg);

% offset = pxShift - [rowIdxs(blockIdx(1)), colIdxs(blockIdx(2))];