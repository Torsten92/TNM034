function [corrVal, triImg] = triangulateFace(mouthImg, eyeImg, subImage)
corrVal = 0;

%find mouth center
[x, y] = meshgrid(1:size(mouthImg, 2), 1:size(mouthImg, 1));
weightedx = x .* mouthImg;
weightedy = y .* mouthImg;
xcentre = sum(weightedx(:)) / sum(mouthImg(:));
ycentre = sum(weightedy(:)) / sum(mouthImg(:));
xcentre = round(xcentre);
ycentre = round(ycentre);

%subplot into 2 images
[c,r] = imfindcircles(eyeImg,[10,20]);
viscircles(c, r);
%figure;imshow(eyeImg);

x1 = 1;
y1 = 1;
x2 = 2;
y2 = 2;

[row ~] = size(c);
c = round(c);
boolFlag = 0;
%check if all eyes are below mouth
for n = 1:row
    if (c(n,2) > ycentre)
        boolFlag = boolFlag+1;
    end
end
if(boolFlag ~= row)
    %if there are more than 2 eyes
    if(r>2)
        d = (1:row);
        eyesCenter=[xcentre ycentre;
                    1 1];
        %check distance to each eye
        for n = 1:row
            eyesCenter(2,1) = c(n,1);
            eyesCenter(2,2) = c(n,2);
            lengthToPoint = pdist(eyesCenter,'minkowski');
            %if eye are below mouth set as a high index
            if(lengthToPoint > 30 && c(n,2) < ycentre)
               d(n) = lengthToPoint;
            else
               d(n) = 1000000;
            end
        
        end
        %check smallest distance
        l = find(d == min(d));
        x1 = c(l,1);
        y1 = c(l,2);
        d(d == min(d)) = 1000000;
        l2 = find(d == min(d));
        x2 = c(l2,1);
        y2 = c(l2,2);

    else
        %if there are only 2 eyes
        x1 = c(1,1);
        y1 = c(2,1);
        x2 = c(2,1);
        y2 = c(2,2);
    end
end
    polygon = int32([x1 y1 x2 y2 xcentre ycentre]); 
    shapeInserter = vision.ShapeInserter('Shape','Polygons','BorderColor','Custom', 'CustomBorderColor', uint8([255 0 0]));

    triImg = step(shapeInserter, subImage, polygon); 



