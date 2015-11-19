%function [massa argument] = faceDetection(image)

image = imread('images/DB1/db1_09.jpg');

image = whiteBalance(image);


[~, subImage, subFaceMask] = skinDetection(image);

[~, mouthImg] = mouthDetection(subImage);

[~, eyeImg] = eyeDetection(subImage, subFaceMask);

[~, triImg] = triangulateFace(mouthImg, eyeImg, subImage);
