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
viscircles(c,r);
eyesCenter =round(c);

polygon = int32([eyesCenter(1,1) eyesCenter(1,2) eyesCenter(2,1) eyesCenter(2,2) xcentre ycentre]); 
shapeInserter = vision.ShapeInserter('Shape','Polygons','BorderColor','Custom', 'CustomBorderColor', uint8([255 0 0]));
triImg = step(shapeInserter, subImage, polygon); 