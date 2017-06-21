image = snapshot(webcam(1));
figure('name', 'image');
imshow(image)
croppedImage = image(60:354, 230:464);
%figure('name', 'croppedImage');
BW2 = edge(croppedImage,'canny');
figure('name', 'BW2');


%imshow(croppedImage);
imshow(BW2);

%Find all the circles with radius r pixels in the range [15, 30].

[centers, radii, metric] = imfindcircles(croppedImage,[6 12], 'Sensitivity', 0.99, 'Method', 'TwoStage', 'ObjectPolarity', 'dark');
%Retain the five strongest circles according to the metric values.

centersStrong5 = centers(1,:);
radiiStrong5 = radii(1);
metricStrong5 = metric(1);
%Draw the five strongest circle perimeters over the original image.

viscircles(centersStrong5, radiiStrong5,'EdgeColor','b');