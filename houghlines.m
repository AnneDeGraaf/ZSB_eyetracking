% by Anne de Graaf and Emmeke Veltmeijer

function lines = houghlines(im,h,thresh) 
%deze functie neemt de originele afbeelding en de Hough transform plus de 
%grootte van de dilation, geeft de homogene lijncoördinaten en plot deze 
%over de afbeelding
%150 is de gewenste threshold
%De rho en theta uit de thetarho2endpoints moeten in de forloop worden
%verwerkt, en ergens moeten de rho/thetacoördinaten terug worden gebracht
%naar de x/ycoördinaten van de oorspronkelijke afbeelding.

SE = strel('square', thresh);
im2 = imdilate(h, SE);
maxima = (h==im2) & h>10; %geeft 1 als waarde bij lokaal maximum, lage pixelwaarden niet meegenomen

[x,y] = find(maxima==1);
countmaxima = length(x);
testlines = zeros(countmaxima,4);

for n = 1:length(x) %x en y in [x,y] zijn omgedraaid
    theta=(y(n)-1)*(pi/(size(h,2)));
    rho=(x(n)-(size(h,1)./2))* (2*sqrt(size(im,1)^2+size(im,2)^2)/(size(h,1)));
    [x1, y1, x2, y2] = thetarho2endpoints(theta, rho, size(im,1), size(im,2));
    testlines(n,1) = x1;
    testlines(n,2) = x2;
    testlines(n,3) = y1;
    testlines(n,4) = y2;
end

    lines = zeros(countmaxima,3);
    for k = 1:countmaxima
        lines(k,[1,2,3])=cross([testlines(k,1),testlines(k,3),1],[testlines(k,2),testlines(k,4),1]);
    end
    figure('name','houghlines');
    imshow(im,[],'InitialMagnification','fit');
    hold on
    %set(gca, 'YDir', 'reverse'); 
    for i=1:length(x)
        line([testlines(i,1),testlines(i,2)],[testlines(i,3), testlines(i,4)])
    end
%line([1,500],[100,500])
    %line([testlines(8,1),testlines(8,2)],[testlines(8,3),testlines(8,4)])
   % line(linesnonhom(:,1),linesnonhom(:,2));
    hold off

end