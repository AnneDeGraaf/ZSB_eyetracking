% by Anne de Graaf and Dennis Holkema

function h = Hough(im, thresh , nrho , ntheta)
edged = edge(im, 'canny', thresh);
accMatrix = zeros(nrho, ntheta);
diagonal = sqrt(size(edged,1)^2+size(edged,2)^2);
rhoDiscr = -diagonal:2*diagonal/(nrho-1):diagonal;
drho = 2*diagonal/(nrho-1);
theta = 0:pi/(ntheta-1):pi;
dtheta = pi/(ntheta-1);

notZeroMask = (edged ~= 0);
[y, x] = find(notZeroMask);

for maskIndex = 1:sum(sum(notZeroMask))
    rho = x(maskIndex).*sin(theta)-y(maskIndex).*cos(theta);
    rhoIndex = round(rho./drho + nrho./2);
    thetaIndex = round(theta./dtheta + 1);
    linIndex = sub2ind(size(accMatrix), rhoIndex, thetaIndex);
    accMatrix(linIndex) = accMatrix(linIndex) + 1;
end

h = accMatrix;

