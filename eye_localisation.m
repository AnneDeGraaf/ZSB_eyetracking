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


seD = strel('diamond',8);
BWfinal = imerode(BW3,seD);
BWfinal = imerode(BWfinal,seD);

imshow(BWfinal);

% find circles with radius in radiusRange
[centers, radii, metric] = imfindcircles(BWfinal, [10 20], 'Sensitivity', 0.999, 'Method', 'TwoStage');

%Retain the numCirclesDrawn strongest circles according to the metric values.
bestCenters = centers(1,:);
bestRadii = radii(1);
bestMetric = metric(1);

%Draw the numCirclesDrawn strongest circle perimeters over the original image.
viscircles(bestCenters, bestRadii,'EdgeColor','b');

 r    = bestRadii(1);
 r_y = r;
 r_x = r * 3;
 xCtr = ceil(bestCenters(2));
 yCtr = ceil(bestCenters(1));
 x1 = r_x + xCtr;
 y1 = yCtr - r_y;
 
 
 x2 = r_x + xCtr;
 y2 = r_y + yCtr;
 
 x3 = xCtr - r_x;
 y3 = r_y + yCtr;
 
 

%s  = regionprops(BWfinal,'BoundingBox');
%
%boxes = cat(1, s.BoundingBox);
%
%[M,Index] = max(boxes);
%
%row_index = int8(Index(4));
%eye_box_x = ceil(boxes(row_index,1)) -10;
%eye_box_y = ceil(boxes(row_index,2)) -30;
%eye_box_dx = ceil(boxes(row_index,3)) ;
%eye_box_dy = ceil(boxes(row_index,4)) ;
%
%eye_box_new_x = eye_box_x + 180;
%eye_box_new_y = eye_box_y + 120;

croppedImage = I(y1:y2,x3:x2);

imshowpair(I,croppedImage,'montage');
