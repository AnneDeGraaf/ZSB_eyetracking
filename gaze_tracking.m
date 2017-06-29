% by Anne de Graaf and Dennis Holkema


function command = gaze_tracking(movementAxis, gameover, webcamName, calibrationLeft, calibrationRight)
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
        
%         figure('name', 'checkcheck');
%         imshow(BW3, 'InitialMagnification', 'fit');

        % making an enclosing rectangle around the eyes
        [yPos, xPos] = find( BW3 ); 
        xBorder = 15;
        xMax = min( (max(xPos) + xBorder), size(BW3, 2) );
        xMin = max( (min(xPos) - xBorder), 1 );
        yBorder = round(0.6*(xMax - xMin));
        yMax = min( (max(yPos) + yBorder), size(BW3, 1) );
        yMin = max( (min(yPos) - yBorder), 1 );

        clipImage = grayImage(yMin:yMax, xMin:xMax);
        
%         figure('name', 'clipImage');
%         imshow(clipImage, 'InitialMagnification', 'fit');
%         hold on;
      
        % change variables here
        irisRadiusRange = [8 13];
        irisCircles = 2;
        refPointsRadiusRange = [9 14];
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
            
%             viscircles(irisBestCenters, irisBestRadii,'EdgeColor','b');
%             viscircles(refPointsBestCenters, refPointsBestRadii,'EdgeColor','r');
%             hold on;


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
                
                % calculate the iris location for each eye 
                iris1 = dot((irisCenter1 - upperRefPoint1), (lowerRefPoint1 - upperRefPoint1))/...
                    sqrt(sum((lowerRefPoint1 - upperRefPoint1).^2)); 
                iris2 = dot((irisCenter2 - upperRefPoint2), (lowerRefPoint2 - upperRefPoint2))/...
                    sqrt(sum((lowerRefPoint2 - upperRefPoint2).^2)); 
                
                % translate iris locations into pong commands
                if iris1 < calibrationLeft && iris2 < calibrationRight
                    command = 'Up';
                elseif iris1 > calibrationLeft && iris2 > calibrationRight
                    command = 'Down';
                else
                    command = 'Neutral';
                end
                             
                % Draw the vectors
%                 xL1 = [upperRefPoint1(1), lowerRefPoint1(1)];
%                 yL1 = [upperRefPoint1(2), lowerRefPoint1(2)];
%                 xL2 = [upperRefPoint1(1), irisCenter1(1)];
%                 yL2 = [upperRefPoint1(2), irisCenter1(2)];
%                 xR1 = [upperRefPoint2(1), lowerRefPoint2(1)];
%                 yR1 = [upperRefPoint2(2), lowerRefPoint2(2)];
%                 xR2 = [upperRefPoint2(1), irisCenter2(1)];
%                 yR2 = [upperRefPoint2(2), irisCenter2(2)];
%                 
%                 plot(xL1, yL1, 'color', 'red');
%                 plot(xL2, yL2, 'color', 'blue');
%                 plot(xR1, yR1, 'color', 'red');
%                 plot(xR2, yR2, 'color', 'blue');

            elseif movementAxis == 'x'
                %sort the refPoints and irisses in x-direction to group the
                %left and right eye.
                refPointsBestCentersSorted = sortrows(refPointsBestCenters, 1);
                irisBestCentersSorted = sortrows(irisBestCenters, 1);

                refPointsPair1 = refPointsBestCentersSorted(1:2, :);
                refPointsPair2 = refPointsBestCentersSorted(3:4, :);
                
                irisCenter1 = irisBestCentersSorted(1,:);
                irisCenter2 = irisBestCentersSorted(2,:);
                
                % for each eye, find the left and right refPoint
                leftRefPoint1 = refPointsPair1(1,:);
                rightRefPoint1 = refPointsPair1(2,:);
                                
                leftRefPoint2 = refPointsPair2(1,:);
                rightRefPoint2 = refPointsPair2(2,:);
                
                % calculate the iris location for each eye 
                iris1 = dot((irisCenter1 - leftRefPoint1), (rightRefPoint1 - leftRefPoint1))/...
                    sqrt(sum((rightRefPoint1 - leftRefPoint1).^2)); 
                iris2 = dot((irisCenter2 - leftRefPoint2), (rightRefPoint2 - leftRefPoint2))/...
                    sqrt(sum((rightRefPoint2 - leftRefPoint2).^2)); 
                
                % translate iris locations into pong commands
                if iris1 < calibrationLeft && iris2 < calibrationRight
                    command = 'Left';
                elseif iris1 > calibrationLeft && iris2 > calibrationRight
                    command = 'Right';
                else
                    command = 'Neutral';
                end
                             
                % Draw the vectors
%                 xL1 = [leftRefPoint1(1), rightRefPoint1(1)];
%                 yL1 = [leftRefPoint1(2), rightRefPoint1(2)];
%                 xL2 = [leftRefPoint1(1), irisCenter1(1)];
%                 yL2 = [leftRefPoint1(2), irisCenter1(2)];
%                 xR1 = [leftRefPoint2(1), rightRefPoint2(1)];
%                 yR1 = [leftRefPoint2(2), rightRefPoint2(2)];
%                 xR2 = [leftRefPoint2(1), irisCenter2(1)];
%                 yR2 = [leftRefPoint2(2), irisCenter2(2)];
%                 
%                 plot(xL1, yL1, 'color', 'red');
%                 plot(xL2, yL2, 'color', 'blue');
%                 plot(xR1, yR1, 'color', 'red');
%                 plot(xR2, yR2, 'color', 'blue');
                
            else
                command = sprintf('not a valid input for argument movementAxis');
            end
            
        else
           return;
        end

    else
        command = sprinf('game over');
    end 
    time = toc
    end


