vidobj = imaq.VideoDevice('winvideo', 2);
I = step(vidobj);
A = rgb2gray(I);
croppedImage = I(60:354, 230:464);
BW1 = edge(A,'canny');

se90 = strel('line', 3, 90);
se0 = strel('line', 3, 0);

BWsdil = imdilate(BW1, [se90 se0]);



figure;
imshowpair(I,BW1,'montage')
title('Eye Localisation');

BWdfill = imfill(BWsdil, 4, 'holes');
figure, imshow(BWdfill);
title('binary image with filled holes');

BWnobord = imclearborder(BWdfill, 8);
figure, imshow(BWnobord), title('cleared border image');



clear('vidobj');
