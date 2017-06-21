Image = imread('6.jpg');
A = rgb2gray(Image);

imshow(A)

%Find all the circles with radius r pixels in the range [15, 30].

[centers, radii, metric] = imfindcircles(A,[60 100], 'Sensitivity', 0.99, 'Method', 'TwoStage', 'ObjectPolarity', 'dark');
%Retain the five strongest circles according to the metric values.

centersStrong5 = centers(1:2,:);
radiiStrong5 = radii(1:2);
metricStrong5 = metric(1:2);
%Draw the five strongest circle perimeters over the original image.

viscircles(centersStrong5, radiiStrong5,'EdgeColor','b');