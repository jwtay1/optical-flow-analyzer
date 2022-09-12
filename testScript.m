MFP = MotionFlowProcessor;
process(MFP)


% clearvars
% clc
% 
% %file = 'D:\Projects\Research\2022-optical-flow-analyzer\data\wnt\wnt_12345_1_001.nd2';
% %file = 'D:\Projects\Research\2022-optical-flow-analyzer\data\mature\mat_12345_1_001.nd2';
% file = 'D:\Projects\Research\2022-optical-flow-analyzer\data\const\const_12047_1_001.nd2';
% 
% reader = BioformatsImage(file);
% 
% Iref = getPlane(reader, 1, 1, 1);
% 
% maxDisplacement = 7;
% [R, C] = getBlockIdxs(size(Iref), [32 32], maxDisplacement);
% 
% %%
% 
% vid = VideoWriter('D:\Projects\Research\2022-optical-flow-analyzer\processed\const_12047_1_001.avi');
% vid.FrameRate = 5;
% open(vid)
% 
% for iT = 1:reader.sizeT
% 
%     Imoved = getPlane(reader, 1, 1, iT);
% 
%     %Initialize the output displacement matrix
%     storeDisplacement = cell(numel(R) - 1, numel(C) - 1);
% 
%     dispVector = -maxDisplacement:maxDisplacement;
% 
%     %Create output image
%     figure(99)
%     imshow(Imoved, [])
%     hold on
% 
%     for iRow = 1:(numel(R) - 1)
%         for iCol = 1:(numel(C) - 1)
% 
%             currTemplate = Imoved(R(iRow):(R(iRow + 1) - 1), C(iCol):(C(iCol + 1) - 1));
% 
%             %Initialize output matrix
%             errScore = zeros(2 * maxDisplacement + 1);
% 
%             for dRow = 1:numel(dispVector)
%                 for dCol = 1:numel(dispVector)
% 
%                     refRowStart = R(iRow) + dispVector(dRow);
%                     refRowEnd = R(iRow + 1) + dispVector(dRow) - 1;
% 
%                     %                 if refRowStart < 1
%                     %
%                     %                     %Missing portion is
%                     %                     diffRow = abs(refRowStart) + 1;
%                     %
%                     %                     %Crop both reference and templates
%                     %                     refRowStart = 1;
%                     %                     refRowEnd = refRowEnd;
%                     %
%                     %                 end
% 
%                     refColStart = C(iCol) + dispVector(dCol);
%                     refColEnd = C(iCol + 1) + dispVector(dCol) - 1;
% 
%                     %                 if refColStart < 1
%                     %
%                     %                     diffCol = abs(refColStart) + 1;
%                     %
%                     %                     refColStart = 1;
%                     %                     refColEnd = refColEnd;
%                     %
%                     %                 end
% 
% 
%                     %Crop the reference image to the right section
%                     currRefSection = Iref(...
%                         refRowStart:refRowEnd, ...
%                         refColStart:refColEnd);
% 
%                     %                 keyboard
% 
%                     %Compute the MAD score
%                     errScore(dRow, dCol) = immse(currRefSection, currTemplate);
%                 end
%             end
% 
%             %Find the direction and magnitude of displacement
%             [maxScore, maxIdx] = min(errScore, [], 'all');
% 
%             [I, J] = ind2sub([numel(dispVector), numel(dispVector)], maxIdx);
% 
%             storeDisplacement{iRow, iCol} = [dispVector(I), dispVector(J)];
% 
%             quiver(mean([C(iCol),(C(iCol + 1) - 1)]),...
%                 mean([R(iRow),(R(iRow + 1) - 1)]), ...
%                 dispVector(J), dispVector(I), 8);
% 
%         end
%     end
%     hold off
%     %Make a quiver plot
%     writeVideo(vid, getframe(gcf))
% 
% 
% end
% 
% close(vid)
% 
% 
% 
% 
% 
% %
% %
% %
% %
% %
% %         subplot(1, 2, 1)
% %         imshow(Iref, [])
% %         subplot(1, 2, 2)
% %         imshow(currTemplate, [])
% %
% %
% %
% 
% 
% 
% 
