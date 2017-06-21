image = snapshot(webcam(1));
A = rgb2gray(image);
croppedImage = image(60:354, 230:464);
BW1 = edge(A,'canny');

figure;
imshowpair(A,BW1,'montage')
title('Eye Localisation');
