% by Anne de Graaf and Emmeke Veltmeijer

function l = line_through_points(points) % input arg points

%     points = [2, 3, 1; 1, 4, 1; 0, 6, 1; 4,0,1]; % x,y,z

    centroid = [mean(points(:,1)) , mean(points(:,2)), 0];
    diffMatrix = points - centroid;
    covMatrix = cov(diffMatrix);
    [vec, val] = eig(covMatrix);
    [~, eigMax] = find(max(max(val))==val);
    eigVector = vec(:,eigMax);
    
%     figure('name', 'total least squares fit ')
%     x = linspace(min(points(:,1))-1,max(points(:,1))+1,10);
%     scatter(points(:,1),points(:,2));
%     hold all
%     y = eigVector(2)/eigVector(1) .* x + (-eigVector(2)*centroid(1) + centroid(2)*eigVector(1))/eigVector(1);
%     plot(x,y, 'blue');
%     hold off;
%     grid on;
    
    l = [eigVector(2)/eigVector(1), -1, (-eigVector(2)*centroid(1) + centroid(2)*eigVector(1))/eigVector(1)];
   
end