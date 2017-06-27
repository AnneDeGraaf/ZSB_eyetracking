% by Anne de Graaf


function gaze = gaze_tracking(movementAxis, gameover)
    if gameover == 0
        %Take picture with camera
        videoDevice = imaq.VideoDevice('winvideo', 1);
        rgbImage = step(videoDevice);
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

        seRectangle = strel('rectangle', [200 10]);
        BWfinal = imdilate(BW3,seRectangle);

        %use BWfinal as clipping mask on image
        clipImage = BWfinal .* grayImage;
        
        figure('name', 'clipImage');
        imshow(clipImage, 'InitialMagnification', 'fit');
      
        % change variables here
        irisRadiusRange = [5 9];
        irisCircles = 1;
        refPointsRadiusRange = [8 11];
        refPointsCircles = 2;

        % find iris and reference point circles with radius in *RadiusRange
        [irisCenters, irisRadii, irisMetric] = imfindcircles(clipImage, irisRadiusRange, ...
            'Sensitivity', 0.99, 'Method', 'TwoStage', 'ObjectPolarity', 'dark');
        [refPointsCenters, refPointsRadii, refPointsMetric] = imfindcircles(clipImage, refPointsRadiusRange, ...
            'Sensitivity', 0.99, 'Method', 'TwoStage', 'ObjectPolarity', 'bright');

        if size(irisCenters, 1) => irisCircles && size(refPointsCenters, 1) => refPointsCircles
            %Retain the numCirclesDrawn strongest circles according to the metric values.
            irisBestCenters = irisCenters(1:irisCircles,:);
            irisBestRadii = irisRadii(1:irisCircles);
            refPointsBestCenters = refPointsCenters(1:refPointsCircles,:);
            refPointsBestRadii = refPointsRadii(1:refPointsCircles);

            %Find the position of the iris along axis movementAxis, 
            %relative to the two reference points
            %By defining a new coordinate frame with origin in the upper or left 
            %reference point. X pointing right, Y pointing down.
            %Next define the other reference point and the iris as vectors.
            %Take the dot product of these vectors to find the iris position.

            if movementAxis == 'y'
                yRefPoints = refPointsBestCenters(:,2);
                yUpperIndex = find(yRefPoints == min(yRefPoints));
                yLowerIndex = find(yRefPoints == max(yRefPoints));
                upperRefPoint = refPointsBestCenters(yUpperIndex, :);
                irisCenter = irisBestCenters(1,:);
                lowerRefPoint = refPointsBestCenters(yLowerIndex, :);
                gaze = dot((irisCenter - upperRefPoint), (lowerRefPoint - upperRefPoint)/...
                    sqrt(sum((lowerRefPoint - upperRefPoint).^2))); 
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
           gaze = 0;


    else
        gaze = sprinf('game over');
    end 
    end


