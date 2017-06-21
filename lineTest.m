% by Anne de Graaf and Emmeke Veltmeijer

close all;

shapes = rgb2gray(imread('shapes.png'));
houghLines = Hough(shapes, [], 1200, 2000);
figure('name','hough space');
imshow(houghLines, []);
imStrel = strel('disk', 50);
imDilate = imdilate(houghLines, imStrel);
maxRegions = imregionalmax(imDilate);
centroids = regionprops(maxRegions,'Centroid');

figure('name','hough detected lines');
imshow(shapes, []);
hold all
for i = 1:length(centroids)
    theta = centroids(i).Centroid(1);
    rho = centroids(i).Centroid(2);
    xValues = 1:size(shapes,2);
    yValues = (-rho + xValues.*sin(theta)) ./ cos(theta);
    plot(xValues, yValues, 'green');
end
hold off


