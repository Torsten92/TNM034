%function [massa argument] = faceDetection(image)

image = imread('images/testDB/image_0018.jpg');

image = whiteBalance(image);


[~, subImage, subFaceMask] = skinDetection(image);

[~, mouthImg] = mouthDetection(subImage);

[~, eyeImg] = eyeDetection(subImage, subFaceMask);

[~, triImg] = triangulateFace(mouthImg, eyeImg, subImage);

imshow(triImg)
