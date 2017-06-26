vidobj = imaq.VideoDevice('winvideo', 2);
I = step(vidobj);
A = rgb2gray(I);
clear('vidobj');
BW1 = edge(A,'canny');

se90 = strel('line', 3, 120);
se0 = strel('line', 3, 0);

BWsdil = imdilate(BW1, [se90 se0]);

BWdfill = imfill(BWsdil, 8, 'holes');

BWnobord = imclearborder(BWdfill, 8);

BW2 = bwareaopen(BWnobord, 150);

BW3 = bwareafilt(BW2,2);
imshowpair(I,BW3,'montage');

seD = strel('diamond',8);
BWfinal = imerode(BW3,seD);
BWfinal = imerode(BWfinal,seD);
figure, imshow(BWfinal), title('segmented image');

s  = regionprops(BWfinal,'BoundingBox');

boxes = cat(1, s.BoundingBox);

[M,Index] = max(boxes);

row_index = int8(;
eye_box_x = ceil(boxes(row_index,1)) -20;
eye_box_y = ceil(boxes(row_index,2)) -20;
eye_box_dx = ceil(boxes(row_index,3)) +20;
eye_box_dy = ceil(boxes(row_index,4)) +10;

eye_box_new_x = eye_box_x + eye_box_dx;
eye_box_new_y = eye_box_y + eye_box_dy;

croppedImage = I(eye_box_y:eye_box_x, eye_box_new_y:eye_box_new_x);

imshow(croppedImage)
hold on
plot(boxes(:,1),boxes(:,2), 'b*')
hold off


