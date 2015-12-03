function [corrVal, triImg] = triangulateFace(mouthImg, eyeImg, subImage)
corrVal = 0;

%find mouth center
[x, y] = meshgrid(1:size(mouthImg, 2), 1:size(mouthImg, 1));
weightedx = x .* mouthImg;
weightedy = y .* mouthImg;
xcentre = sum(weightedx(:)) / sum(mouthImg(:));
ycentre = sum(weightedy(:)) / sum(mouthImg(:));
xcentre = round(xcentre)
ycentre = round(ycentre)

%subplot into 2 images
[c,r] = imfindcircles(eyeImg,[10,20]);
viscircles(c,r);
x1 = 0;
y1 = 0;
x2 = 0;
y2 = 0;

[r k] = size(c);
c = round(c);
if(r>2)
    d = (1:r);
    eyesCenter=[xcentre ycentre;
                0 0];
    for n = 1:r
        eyesCenter(2,1) = c(n,1);
        eyesCenter(2,2) = c(n,2);
        
        d(n) = pdist(eyesCenter,'euclidean');

    end
    l = find(d == min(d));
    x1 = c(l,1)
    y1 = c(l,2)
    d(d == min(d)) =100000;
    l2 = find(d == min(d));
    x2 = c(l2,1)
    y2 = c(l2,2)
    
else
    x1 = c(1,1);
    y1 = c(2,1);
    x2 = c(2,1);
    y2 = c(2,2);
end

polygon = int32([x1 y1 x2 y2 xcentre ycentre]); 
shapeInserter = vision.ShapeInserter('Shape','Polygons','BorderColor','Custom', 'CustomBorderColor', uint8([255 0 0]));
triImg = step(shapeInserter, subImage, polygon); 