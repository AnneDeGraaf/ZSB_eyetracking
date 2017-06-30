% by Anne de Graaf

function [leftEye, rightEye] = eye_calibration(movementAxis, webcamName)
    if movementAxis == 'y'
        sprintf('Please look at the middle of the left side of the screen and wait 5 seconds')  
    elseif movementAxis == 'x'
        sprintf('Please look at the middle of the bottom of the screen and wait 5 seconds')        
    else
        sprintf('not a valid input for argument movementAxis');
    end
    
    pause(5);
    %Take picture with camera
    %         videoDevice = imaq.VideoDevice('winvideo', 1);
    %         rgbImage = step(webcamName);
    rgbImage = snapshot(webcamName);                                                                                     
    grayImage = rgb2gray(rgbImage);

    %sobel edge detection
    BW1 = edge(grayImage,'sobel');

    %thicken the edges and fill small gaps
    seLine90 = strel('line', 3, 120);
    seLine0 = strel('line', 3, 0);
    BWsdil = imdilate(BW1, [seLine90 seLine0]);
    BWdfill = imfill(BWsdil, 18, 'holes');

    %delete the border elements, like hair and facial hair
    BWnobord = imclearborder(BWdfill, 18);

    %take the two largest blobs
    BW2 = bwareaopen(BWnobord, 150);
    BW3 = bwareafilt(BW2,2);
 
    figure('name', 'checkcheck');
    imshow(BW3, 'InitialMagnification', 'fit');

    % making an enclosing rectangle around the eyes
    [yPos, xPos] = find( BW3 ); 
    xBorder = 15;
    xMax = min( (max(xPos) + xBorder), size(BW3, 2) );
    xMin = max( (min(xPos) - xBorder), 1 );
    yBorder = round(0.6*(xMax - xMin));
    yMax = min( (max(yPos) + yBorder), size(BW3, 1) );
    yMin = max( (min(yPos) - yBorder), 1 );

    clipImage = grayImage(yMin:yMax, xMin:xMax);

    figure('name', 'clipImage');
    imshow(clipImage, 'InitialMagnification', 'fit');
    hold on;

    % change variables here
    irisRadiusRange = [28 35];
    irisCircles = 2;
    refPointsRadiusRange = [30 38];
    refPointsCircles = 4;

    % find iris and reference point circles with radius in *RadiusRange
    [irisCenters, irisRadii, irisMetric] = imfindcircles(clipImage, irisRadiusRange, ...
        'Sensitivity', 0.99, 'Method', 'TwoStage', 'ObjectPolarity', 'dark');
    [refPointsCenters, refPointsRadii, refPointsMetric] = imfindcircles(clipImage, refPointsRadiusRange, ...
        'Sensitivity', 0.99, 'Method', 'TwoStage', 'ObjectPolarity', 'bright');

    if size(irisCenters, 1) >= irisCircles && size(refPointsCenters, 1) >= refPointsCircles
    %     Retain the numCirclesDrawn strongest circles according to the metric values.
        irisBestCenters = irisCenters(1:irisCircles,:);
        irisBestRadii = irisRadii(1:irisCircles);
        refPointsBestCenters = refPointsCenters(1:refPointsCircles,:);
        refPointsBestRadii = refPointsRadii(1:refPointsCircles);

        viscircles(irisBestCenters, irisBestRadii,'EdgeColor','b');
        viscircles(refPointsBestCenters, refPointsBestRadii,'EdgeColor','r');
        hold on;

        %Find the position of the iris along axis movementAxis, 
        %relative to the two reference points
        %By defining a new coordinate frame with origin in the upper or left 
        %reference point. X pointing right, Y pointing down.
        %Next define the other reference point and the iris as vectors.
        %Take the dot product of these vectors to find the iris position.

        if movementAxis == 'y'
            %sort the refPoints and irisses in x-direction to group the
            %left and right eye.
            refPointsBestCentersSorted = sortrows(refPointsBestCenters, 1);
            irisBestCentersSorted = sortrows(irisBestCenters, 1);

            refPointsPair1 = refPointsBestCentersSorted(1:2, :);
            refPointsPair2 = refPointsBestCentersSorted(3:4, :);

            irisCenter1 = irisBestCentersSorted(1,:);
            irisCenter2 = irisBestCentersSorted(2,:);

            % for each eye, find the upper and lower refPoint
            yUpperIndex1 = find(refPointsPair1(:,2) == min(refPointsPair1(:,2)));
            yLowerIndex1 = find(refPointsPair1(:,2) == max(refPointsPair1(:,2)));
            upperRefPoint1 = refPointsPair1(yUpperIndex1, :);
            lowerRefPoint1 = refPointsPair1(yLowerIndex1, :);

            yUpperIndex2 = find(refPointsPair2(:,2) == min(refPointsPair2(:,2)));
            yLowerIndex2 = find(refPointsPair2(:,2) == max(refPointsPair2(:,2)));
            upperRefPoint2 = refPointsPair2(yUpperIndex2, :);
            lowerRefPoint2 = refPointsPair2(yLowerIndex2, :);

            % calculate the gaze for each eye 
            leftEye = dot((irisCenter1 - upperRefPoint1), (lowerRefPoint1 - upperRefPoint1))/...
                sum((lowerRefPoint1 - upperRefPoint1).^2); 
            rightEye = dot((irisCenter2 - upperRefPoint2), (lowerRefPoint2 - upperRefPoint2))/...
                sum((lowerRefPoint2 - upperRefPoint2).^2); 
            
        elseif movementAxis == 'x'
            %sort the refPoints and irisses in x-direction to group the
            %left and right eye.
            refPointsBestCentersSorted = sortrows(refPointsBestCenters, 1);
            irisBestCentersSorted = sortrows(irisBestCenters, 1);
%                 xRefPoints = refPointsBestCenters(:,1);

            refPointsPair1 = refPointsBestCentersSorted(1:2, :);
            refPointsPair2 = refPointsBestCentersSorted(2:3, :);

            irisCenter1 = irisBestCentersSorted(1,:);
            irisCenter2 = irisBestCentersSorted(2,:);

            % for each eye, find the left and right refPoint
            leftRefPoint1 = refPointsPair1(1,:);
            rightRefPoint1 = refPointsPair1(2,:);

            leftRefPoint2 = refPointsPair2(1,:);
            rightRefPoint2 = refPointsPair2(2,:);

            % calculate the iris location for each eye 
            leftEye = dot((irisCenter1 - leftRefPoint1), (rightRefPoint1 - leftRefPoint1))/...
                sum((rightRefPoint1 - leftRefPoint1).^2); 
            rightEye = dot((irisCenter2 - leftRefPoint2), (rightRefPoint2 - leftRefPoint2))/...
                sum((rightRefPoint2 - leftRefPoint2).^2); 
            
        else
            sprintf('not a valid input for argument movementAxis');
        end
        
    else
        sprintf('calibration failed, please try again');
    end
end
