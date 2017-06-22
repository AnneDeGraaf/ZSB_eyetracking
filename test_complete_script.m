% by Anne de Graaf

function yIris = test_complete_script(gameover = 'False')
    % make a snapshot and cut out the face area
    % % snapFace = rgb2gray(imread('5b.jpg'));
    snap = snapshot(webcam(1));
    snapFace = snap(75:335, 205:435);
    figure('name', 'snapshot');
    imshow(snapFace, 'InitialMagnification','fit');
    hold on;

    % change variables here
    irisRadiusRange = [3 12];
    irisCircles = 1;
    refPointsRadiusRange = [12 20];
    refPointsCircles = 2;

    % find circles with radius in radiusRange
    [irisCenters, irisRadii, irisMetric] = imfindcircles(snapFace, irisRadiusRange, ...
        'Sensitivity', 0.99, 'Method', 'TwoStage', 'ObjectPolarity', 'dark');
    [refPointsCenters, refPointsRadii, refPointsMetric] = imfindcircles(snapFace, refPointsRadiusRange, ...
        'Sensitivity', 0.99, 'Method', 'TwoStage', 'ObjectPolarity', 'bright');

    %Retain the numCirclesDrawn strongest circles according to the metric values.
    irisBestCenters = irisCenters(1:irisCircles,:);
    irisBestRadii = irisRadii(1:irisCircles);
    % % irisBestMetric = irisMetric(1:irisCircles);
    refPointsBestCenters = refPointsCenters(1:refPointsCircles,:);
    refPointsBestRadii = refPointsRadii(1:refPointsCircles);
    % % refPointsBestMetric = refPointsMetric(1:refPointsCircles);

    %Draw the numCirclesDrawn strongest circle perimeters over the snapFace image.
    viscircles(irisBestCenters, irisBestRadii,'EdgeColor','b');
    viscircles(refPointsBestCenters, refPointsBestRadii,'EdgeColor','r');
    hold on;

    %Find the y-position of the iris, relative to the two reference points
    %By defining a new coordinate frame with origin in the highest reference
    %point. X pointing right, Y pointing down.
    %Next define the lower refernce point and the iris as vectors.
    %Take the dot product of these vectors to find the vertical iris position.
    yRefPoints = refPointsBestCenters(:,2);
    yMinIndex = find(yRefPoints == min(yRefPoints));
    yMaxIndex = find(yRefPoints == max(yRefPoints));
    highRefPoint = refPointsBestCenters(yMinIndex, :);
    irisCenter = irisBestCenters(1,:);
    lowRefPoint = refPointsBestCenters(yMaxIndex, :); 
    yIris = dot((irisCenter - highRefPoint), (lowRefPoint - highRefPoint)/...
        sqrt(sum((lowRefPoint - highRefPoint).^2))); 

    % Draw the vectors
    x1 = [highRefPoint(1), lowRefPoint(1)];
    y1 = [highRefPoint(2), lowRefPoint(2)];
    x2 = [highRefPoint(1), irisCenter(1)];
    y2 = [highRefPoint(2), irisCenter(2)];
    plot(x1, y1, 'color', 'red');
    plot(x2, y2, 'color', 'blue');
    % viscircles(highRefPoint, yIris,'EdgeColor','g');
    
    return yIris
end


