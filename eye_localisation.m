image = snapshot(webcam(1));
A = rgb2gray(image);
croppedImage = image(60:354, 230:464);
BW1 = edge(A,'canny');

se90 = strel('line', 3, 110);
se0 = strel('line', 3, 0);

BWsdil = imdilate(BW1, [se90 se0]);


figure;
imshowpair(A,BWsdil,'montage')
title('Eye Localisation');
