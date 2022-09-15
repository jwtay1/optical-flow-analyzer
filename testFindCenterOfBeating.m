clearvars
clc

load('D:\Projects\Research\2022-optical-flow-analyzer\processed_increasedDisp\const_12047_1_001.mat');

reader = BioformatsImage(inputFile);

I = getPlane(reader, 1, 1, 1);


%%

imshow(I, [])
roi = drawrectangle;
wait(roi);

disp('done')

%% Find the center of beating within the region

[XX, YY] = meshgrid(storeX, storeY);

%pos = [xmin ymin width height]
xmin = roi.Position(1);
ymin = roi.Position(2);
width = roi.Position(3);
height = roi.Position(4);

xROI = linspace(xmin, xmin + width, 20);
yROI = linspace(ymin, ymin + height, 20);

idx = find(inROI(roi, XX, YY));

diffContraction = zeros(numel(yROI), numel(xROI));

for iX = 1:numel(xROI)
    for iY = 1:numel(yROI)

        x = xROI(iX);
        y = yROI(iY);
        
        storeDisplacementTime = zeros(1, reader.sizeT);
        for iT = 1:reader.sizeT

            storeDisplacements = zeros(1, numel(idx));
            for ii = 1:numel(idx)

                %For each point, determine the unit vector towards the CoB
                uvec = [XX(idx(ii)) - x, YY(idx(ii)) - y];
                uvec = uvec ./ (sqrt(uvec(1)^2 + uvec(2)^2));

                %Compute the displacement vector
                uu = storeU(:, :, iT);
                vv = storeV(:, :, iT);

                vvec = [XX(idx(ii)) - uu(idx(ii)), YY(idx(ii)) - vv(idx(ii))];

                %Compute the dot vector
                storeDisplacements(ii) = dot(vvec, uvec);
            end

            storeDisplacementTime(iT) = mean(storeDisplacements);

        end

        %Find the zero point
        zeroDisp = mode(round(storeDisplacementTime, 3, 'significant'));
        normDisp = storeDisplacementTime - zeroDisp;

        %Compute inward vs outward motion towards the point
        maxContraction = max(normDisp);
        minContraction = min(normDisp);

        diffContraction(iY, iX) = abs(maxContraction - abs(minContraction));       

    end
end
%%
%Find the center of beating
[iCoB, jCoB] = find(diffContraction == min(diffContraction, [], 'all'));

xCoB = jCoB + xmin;
yCoB = iCoB + ymin;

figure;
imshow(I, [])
hold on
plot(xCoB, yCoB, 'ro')
hold off

%%

storeDisplacementTime = zeros(1, reader.sizeT);
for iT = 1:reader.sizeT

    storeDisplacements = zeros(1, numel(idx));
    for ii = 1:numel(idx)

        %For each point, determine the unit vector towards the CoB
        uvec = [XX(idx(ii)) - xCoB, YY(idx(ii)) - yCoB];
        uvec = uvec ./ (sqrt(uvec(1)^2 + uvec(2)^2));

        %Compute the displacement vector
        uu = storeU(:, :, iT);
        vv = storeV(:, :, iT);

        vvec = [XX(idx(ii)) - uu(idx(ii)), YY(idx(ii)) - vv(idx(ii))];

        %Compute the dot vector
        storeDisplacements(ii) = dot(vvec, uvec);
    end

    storeDisplacementTime(iT) = mean(storeDisplacements);

end

plot(storeDisplacementTime)



