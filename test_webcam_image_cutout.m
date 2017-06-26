% initialize webcam
% % cam = webcam;

% make a snapshot

anne1 = step(imaq.VideoDevice('winvideo', 2));


%anne1 = snapshot(webcam(1));

figure('name', 'anne1');
%imshow(anne1);

% cut out the face area from snapshot
anne2 = anne1(75:185, 205:435);
figure('name', 'anne2');
imshow(anne1);

% change variables here
radiusRange = [20 30];
numCirclesDrawn = 2;

% find circles with radius in radiusRange
[centers, radii, metric] = imfindcircles(anne1, radiusRange, 'Sensitivity', 0.99, 'Method', 'TwoStage', 'ObjectPolarity', 'dark');

%Retain the numCirclesDrawn strongest circles according to the metric values.
bestCenters = centers(1:numCirclesDrawn,:);
bestRadii = radii(1:numCirclesDrawn);
bestMetric = metric(1:numCirclesDrawn);

%Draw the numCirclesDrawn strongest circle perimeters over the original image.
viscircles(bestCenters, bestRadii,'EdgeColor','b');

