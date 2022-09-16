clearvars
clc

file = 'D:\Projects\Research\2022-optical-flow-analyzer\processed_increasedDisp\const_12047_1_001.mat';

load(file);

MFA = MotionFlowAnalyzer;

%Pick an ROI
reader = BioformatsImage(inputFile);

I = getPlane(reader, 1, 1, 1);



%%
imshow(I, [])

roi = drawrectangle;  %roi = [xmin, ymin, width, height]
wait(roi);

xmin = round(roi.Position(1));
ymin = round(roi.Position(2));
width = round(roi.Position(3));
height = round(roi.Position(4));

Cx = xmin:(xmin + width);
Cy = ymin:(ymin + height);

[Cx, Cy] = meshgrid(Cx, Cy);

%%

meanMotion = zeros([size(Cx), reader.sizeT]);
for iT = 1:reader.sizeT

    meanMotion(:, :, iT) = MFA.computeMotion(storeX, storeY, storeU(:, :, iT), storeV(:, :, iT), Cx, Cy);

end

%% Find the center of beating

modeContraction = mode(round(meanMotion, 5, 'significant'), 3);
meanMotionNorm = meanMotion - modeContraction;

%Compute the maximum value (max contraction)
maxContraction = max(meanMotionNorm, [], 3);

%Compute the minimum value (max dilation)
minContraction = min(meanMotionNorm, [], 3);

diffContraction = maxContraction + minContraction;



%%
plot(reshape(meanMotionNorm(100, 100, :), 1, []))




