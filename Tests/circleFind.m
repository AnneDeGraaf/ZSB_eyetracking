image = 'D:\000Minor\ZoekenSturenBewegen\afbeeldingen\ogen_blauw.jpg';
greyImage = rgb2gray(imread(image));
% edgedImage = edge(greyImage, 'canny', []);
% imshow(edgedImage);
radiusRange = [10 50];
[centers, radii, metric] = imfindcircles(greyImage,radiusRange, 'Sensitivity',0.90, 'EdgeThreshold', 0.5);

numCircleShow = 3
centersStrong5 = centers(1:numCircleShow,:);
radiiStrong5 = radii(1:numCircleShow);
metricStrong5 = metric(1:numCircleShow);

imshow(greyImage);
viscircles(centersStrong5, radiiStrong5,'EdgeColor','b');