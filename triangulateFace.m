function [angle, triImg] = triangulateFace(leftEye, rightEye, subImage, mouthCenter)

xcentre = round(mouthCenter(1));
ycentre = round(mouthCenter(2));


polygon = int32([leftEye rightEye xcentre ycentre]);
shapeInserter = vision.ShapeInserter('Shape','Polygons','BorderColor','Custom', 'CustomBorderColor', uint8([255 0 0]));

triImg = step(shapeInserter, subImage, polygon); 

%get normalized vector between the eyes
normEyeVector = (rightEye-leftEye) / norm(rightEye-leftEye);

angle = acos(dot([1 0], normEyeVector));
angle = 180 * angle / pi;

if(leftEye(2) > rightEye(2)) 
    angle = -angle;
end
