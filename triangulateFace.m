function angle = triangulateFace(leftEye, rightEye)


%get normalized vector between the eyes
normEyeVector = (rightEye-leftEye) / norm(rightEye-leftEye);

angle = acos(dot([1 0], normEyeVector));
angle = 180 * angle / pi;

if(leftEye(2) > rightEye(2)) 
    angle = -angle;
end
