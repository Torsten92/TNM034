function [corrVal, triImg] = triangulateFace(xPos, yPos, subImage,mouthCenter)
corrVal = 0;

xcentre = round(mouthCenter(1));
ycentre = round(mouthCenter(2));


polygon = int32([xPos(1) yPos(1) xPos(2) yPos(2) xcentre ycentre]);
shapeInserter = vision.ShapeInserter('Shape','Polygons','BorderColor','Custom', 'CustomBorderColor', uint8([255 0 0]));

triImg = step(shapeInserter, subImage, polygon); 

eye1 = [xPos(1) yPos(1)];
eye2 = [xPos(2) yPos(2)];

normEyeVector = (eye2-eye1) / norm(eye2-eye1);

angle = acos(dot([1 0], normEyeVector));
angle = 180 * angle / pi;

triImg = imrotate(triImg, -angle, 'bilinear');

