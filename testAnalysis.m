clearvars
clc

%Load file
load('D:\Projects\Research\2022-optical-flow-analyzer\processed\const_12047_1_005.mat');

%Load the image
reader = BioformatsImage(inputFile);

I = getPlane(reader, 1, 1, 1);

%% Plot motion for CoB determination

figure(99)
imshow(I, [])

% hold on
% 
% for ii = 1:2:reader.sizeT
% 
%     quiver(storeX, storeY, storeU(:, :, ii), storeV(:, :, ii))
% 
% end
% hold off



%%

%Click to determine the center of beating
[x, y] = ginput(1);

%%
%Compute average motion towards and away from CoB - dot product?
CoBdistance = 100; %Radius around center of beating

%Find points that are within the ROI
[XX, YY] = meshgrid(storeX, storeY);

idx = find( ((XX - x).^2 + (YY - y).^2) <= CoBdistance^2 );

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

%% Find peaks

[pks, locs] = findpeaks(storeDisplacementTime, 'MinPeakProminence', 0.4);

tt = 1:numel(storeDisplacementTime);

figure(1)
plot(tt, storeDisplacementTime, tt(locs), pks, 'ro');

maxPixelVelocity = max(pks);
heartbeatRate = mean(diff(tt(locs)));

%% Find maximum displacement





%%
figure(2)
imshow(I, [])
hold on
tt = linspace(1, 2*pi, 30);
xCirc = CoBdistance * cos(tt) + x;
yCirc = CoBdistance * sin(tt) + y;
plot(xCirc, yCirc)

plot(x, y, 'ro')
hold off


%Compute the beat rate and maximum pixel displacement