% background = rgb2gray(snapshot(webcam(1)));
% figure('name', 'background');
% imshow(background);
% 
% anne = rgb2gray(snapshot(webcam(1))); 
% figure('name', 'anne + background');
% imshow(anne);

backgroundSubtracted = zeros(size(anne, 1), size(anne,2));
figure('name', 'black screen');
imshow(backgroundSubtracted);
for i = 1:size(anne,1)
    for j = 1:size(anne,2)
       if abs(anne(i,j) - background(i,j)) > 12
           backgroundSubtracted(i,j) = anne(i,j);
       end
    end
end

figure('name', 'background subtracted');
imshow(backgroundSubtracted, []);