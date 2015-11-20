%function [massa argument] = faceDetection(image)
%for i = 1:9
%image = imread(sprintf('images/DB1/db1_0%d.jpg', i));
image = imread(sprintf('images/DB1/db1_16.jpg'));
image = whiteBalance(image);

[~, subImage, subFaceMask] = skinDetection(image);
[~, mouthImg] = mouthDetection(subImage);
[~, eyeImg] = eyeDetection(subImage, subFaceMask);
[~, triImg] = triangulateFace(mouthImg, eyeImg, subImage);

figure
imshow(mouthImg)
%end