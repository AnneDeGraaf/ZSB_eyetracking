% takes xy coordinates of origanal image and their mapping coordinates uv
% and returns a projection matrix that projects the xy coordinates on the
% uv coordinates
function projMatrix = createProjectionMatrix(xy,uv)
    % iteration variable
    j = 1;
    
    % calculate A matrix, for Am = 0 svd approximation
    A = zeros(8,9);
    xyHomogeen = [xy, ones(size(xy, 1),1)];
    for i=1:4
        A(j,:) = [xyHomogeen(i,:),0,0,0,-uv(i,1)*xyHomogeen(i,:)];
        j = j + 1;
        A(j,:) = [0,0,0,xyHomogeen(i,:),-uv(i,2)*xyHomogeen(i,:)];
        j = j + 1;
    end
    [u,s,v] = svd(A);
    
    % reshape vector to output matrix
    projMatrix = reshape(v(:,9),[3,3])';
end

