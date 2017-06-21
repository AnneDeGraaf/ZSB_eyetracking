% by Anne de Graaf and Emmeke Veltmeijer

function [x1, y1, x2, y2] = thetarho2endpoints(theta, rho, rows, cols)

x1=0;
y1=-rho/cos(theta);
x2=cols;
y2=(-rho+cols*sin(theta))/cos(theta);

% x1 = 1;
% y1 = (-rho+sin(theta))/cos(theta); %x = 1
% x2 = cols;
% y2 = (-rho+cols*sin(theta))/cos(theta); %x = cols

if y1<1 || y2<1
    y1=0;
    y2=rows;
    x1=rho/sin(theta);
    x2=(rho+rows*cos(theta))/sin(theta);
    
%     y1 = 1;
%     y2 = rows;
%     x1 = (rho+cos(theta))/sin(theta);
%     x2 = (rho+rows*cos(theta))/sin(theta);
end
end