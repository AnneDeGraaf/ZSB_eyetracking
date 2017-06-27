% by Anne de Graaf

function gaze = gaze_tracking(movementAxis, gameover, webcam_name)
    if gameover == 0

        % make a snapshot and cut out the face area
        snap = snapshot(webcam_name);
        snapFace = snap(75:335, 205:435);

        % change variables here
        irisRadiusRange = [5 9];
        irisCircles = 1;
        refPointsRadiusRange = [8 11];
        refPointsCircles = 2;

        % find circles with radius in radiusRange
        [irisCenters, irisRadii, irisMetric] = imfindcircles(snapFace, irisRadiusRange, ...
            'Sensitivity', 0.99, 'Method', 'TwoStage', 'ObjectPolarity', 'dark');
        [refPointsCenters, refPointsRadii, refPointsMetric] = imfindcircles(snapFace, refPointsRadiusRange, ...
            'Sensitivity', 0.99, 'Method', 'TwoStage', 'ObjectPolarity', 'bright');

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
        
        if movementAxis == y
            yRefPoints = refPointsBestCenters(:,2);
            yUpperIndex = find(yRefPoints == min(yRefPoints));
            yLowerIndex = find(yRefPoints == max(yRefPoints));
            upperRefPoint = refPointsBestCenters(yUpperIndex, :);
            irisCenter = irisBestCenters(1,:);
            lowerRefPoint = refPointsBestCenters(yLowerIndex, :);
            gaze = dot((irisCenter - upperRefPoint), (lowerRefPoint - upperRefPoint)/...
                sqrt(sum((lowerRefPoint - upperRefPoint).^2))); 
        elseif movementAxis == x
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
        gaze = sprinf('game over');
    end 
end


