% by Anne de Graaf


function gaze = gaze_tracking(movementAxis, gameover, webcamName)
    tic;
    if gameover == 0
        %Take picture with camera
%         videoDevice = imaq.VideoDevice('winvideo', 1);
%         rgbImage = step(videoDevice);
        rgbImage = snapshot(webcamName);                                                                                     
        grayImage = rgb2gray(rgbImage);
  
        %sobel edge detection
        BW1 = edge(grayImage,'sobel');

        %thicken the edges and fill small gaps
        seLine90 = strel('line', 3, 120);
        seLine0 = strel('line', 3, 0);
        BWsdil = imdilate(BW1, [seLine90 seLine0]);
        BWdfill = imfill(BWsdil, 8, 'holes');

        %delete the border elements, like hair and facial hair
        BWnobord = imclearborder(BWdfill, 8);

        %take the two largest blobs
        BW2 = bwareaopen(BWnobord, 150);
        BW3 = bwareafilt(BW2,2);
        
        figure('name', 'checkcheck');
        imshow(BW3, 'InitialMagnification', 'fit');

        seRectangle = strel('rectangle', [150 2]);
        BWfinal = imdilate(BW3,seRectangle);

        %use BWfinal as clipping mask on image
        clipImage = uint8(BWfinal) .* grayImage;
        
        figure('name', 'clipImage');
        imshow(clipImage, 'InitialMagnification', 'fit');
        hold on;
      
        % change variables here
        irisRadiusRange = [8 15];
        irisCircles = 2;
        refPointsRadiusRange = [9 20];
        refPointsCircles = 4;

        % find iris and reference point circles with radius in *RadiusRange
        [irisCenters, irisRadii, irisMetric] = imfindcircles(clipImage, irisRadiusRange, ...
            'Sensitivity', 0.99, 'Method', 'TwoStage', 'ObjectPolarity', 'dark');
        [refPointsCenters, refPointsRadii, refPointsMetric] = imfindcircles(clipImage, refPointsRadiusRange, ...
            'Sensitivity', 0.99, 'Method', 'TwoStage', 'ObjectPolarity', 'bright');

        if size(irisCenters, 1) >= irisCircles && size(refPointsCenters, 1) >= refPointsCircles
            %Retain the numCirclesDrawn strongest circles according to the metric values.
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
                gaze1 = dot((irisCenter1 - upperRefPoint1), (lowerRefPoint1 - upperRefPoint1))/...
                    sqrt(sum((lowerRefPoint1 - upperRefPoint1).^2)); 
                gaze2 = dot((irisCenter2 - upperRefPoint2), (lowerRefPoint2 - upperRefPoint2))/...
                    sqrt(sum((lowerRefPoint2 - upperRefPoint2).^2)); 
                gaze = (gaze1 + gaze2) / 2;

                % Draw the vectors
                xL1 = [upperRefPoint1(1), lowerRefPoint1(1)];
                yL1 = [upperRefPoint1(2), lowerRefPoint1(2)];
                xL2 = [upperRefPoint1(1), irisCenter1(1)];
                yL2 = [upperRefPoint1(2), irisCenter1(2)];
                xR1 = [upperRefPoint2(1), lowerRefPoint2(1)];
                yR1 = [upperRefPoint2(2), lowerRefPoint2(2)];
                xR2 = [upperRefPoint2(1), irisCenter2(1)];
                yR2 = [upperRefPoint2(2), irisCenter2(2)];
                
                plot(xL1, yL1, 'color', 'red');
                plot(xL2, yL2, 'color', 'blue');
                plot(xR1, yR1, 'color', 'red');
                plot(xR2, yR2, 'color', 'blue');

            elseif movementAxis == 'x'
                xRefPoints = refPointsBestCenters(:,1);
                xLeftIndex = find(xRefPoints == min(xRefPoints));
                xRightIndex = find(xRefPoints == max(xRefPoints));
                leftRefPoint = refPointsBestCenters(xLeftIndex, :);
                rightRefPoint = refPointsBestCenters(xRightIndex, :);
                irisCenter = irisBestCenters(1,:);
                gaze = dot((irisCenter - leftRefPoint), (rightRefPoint - leftRefPoint)/...
                    sqrt(sum((rightRefPoint - leftRefPoint).^2)));
            else
                gaze = sprintf('not a valid input for argument movementAxis');
            end
            
        else
           return;
        end

    else
        gaze = sprinf('game over');
    end 
    time = toc
    end

