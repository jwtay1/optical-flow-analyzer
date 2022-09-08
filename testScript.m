clearvars
clc

file = 'D:\Projects\Research\2022-optical-flow-analyzer\data\wnt\wnt_12345_1_001.nd2';

reader = BioformatsImage(file);

Iref = getPlane(reader, 1, 1, 1);
Imoved = getPlane(reader, 1, 1, 2);

[R, C] = getBlockIdxs(size(Iref), [16 16]);

%%

%Initialize the output displacement matrix
storeDisplacement = zeros(numel(R) - 1, numel(C) - 1);

maxDisplacement = 7;
dispVector = -maxDisplacement:maxDisplacement;

for iRow = 35
    for iCol = 35

        currTemplate = Imoved(R(iRow):(R(iRow + 1) - 1), C(iCol):(C(iCol + 1) - 1));

        %Initialize output matrix
        errScore = zeros(2 * maxDisplacement + 1);

        for dRow = 1:numel(dispVector)
            for dCol = 1:numel(dispVector)

                refRowStart = R(iRow) + dispVector(dRow);
                refRowEnd = R(iRow + 1) + dispVector(dRow) - 1;

                if refRowStart < 1
                    
                    %Crop both reference and templates
                    refRowStart = 1;
                    refRowEnd = refRowEnd - 1;

                    


                end

                if colStart 


                %Crop the reference image to the right section
                currRefSection = Iref(...
                    ():(R(iRow + 1) - 1 + dispVector(dRow)), ...
                    (C(iCol) + dispVector(dCol)):(C(iCol + 1) - 1 + dispVector(dCol)));


                %Compute the MAD score
                errScore(dRow, dCol) = immse(currRefSection, currTemplate);
            end
        end

        %Find the direction and magnitude of displacement
        [maxScore, maxIdx] = max(errScore, [], 'all');

        [I, J] = ind2sub([numel(dispVector), numel(dispVector)], maxIdx);

        storeDisplacement(iRow, iCol) = [I, J];

    end
end


















        subplot(1, 2, 1)
        imshow(Iref, [])
        subplot(1, 2, 2)
        imshow(currTemplate, [])







