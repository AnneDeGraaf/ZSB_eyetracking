background = rgb2gray(snapshot(webcam(1)));
figure('name', 'background');
imshow(background);

anne = rgb2gray(snapshot(webcam(1))); 
figure('name', 'anne + background');
imshow(anne);

backgroundSubtracted = anne - background;
figure('name', 'background subtracted');
imshow(backgroundSubtracted, []);