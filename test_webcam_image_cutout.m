% initialize webcam
cam = webcam;

% make a snapshot
anne1 = snapshot(cam);
figure('name', 'anne1');
imshow(anne1);

% cut out the face area from snapshot
anne2 = anne1(75:335, 205:435);
figure('name', 'anne2');
imshow(anne2);

% change variables here
radiusRange = [5 12];
numCirclesDrawn = 2;

% find circles with radius in radiusRange
[centers, radii, metric] = imfindcircles(anne2, radiusRange, 'Sensitivity', 0.99, 'Method', 'TwoStage', 'ObjectPolarity', 'dark');

%Retain the numCirclesDrawn strongest circles according to the metric values.
bestCenters = centers(1:numCirclesDrawn,:);
bestRadii = radii(1:numCirclesDrawn);
bestMetric = metric(1:numCirclesDrawn);

%Draw the numCirclesDrawn strongest circle perimeters over the original image.
viscircles(centersStrong, radiiStrong,'EdgeColor','b');

