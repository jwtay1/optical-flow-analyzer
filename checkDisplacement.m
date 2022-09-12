clearvars
clc

load('D:\Projects\Research\2022-optical-flow-analyzer\processed\testV2\const_12047_1_001.mat');
file = 'D:\Projects\Research\2022-optical-flow-analyzer\data\const\const_12047_1_001.nd2';

reader = BioformatsImage(file);

vid = VideoWriter('validataionVideo.avi');
vid.FrameRate = 5;
open(vid);

for iT = 1:reader.sizeT

    I = getPlane(reader, 1, 1, iT);

    figure(99)
    imshow(I, [])
    hold on
    quiver(storeX, storeY, ...
        storeU(:, :, iT), storeV(:, :, iT))

    writeVideo(vid, getframe(gcf))
    hold off

end

close(vid)