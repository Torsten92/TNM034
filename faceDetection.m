%function [massa argument] = faceDetection(image)
clc;
clear all
%for i = 1:9
%image = imread(sprintf('images/DB1/db1_0%d.jpg', i));
image = imread(sprintf('images/DB0/db0_%d.jpg',4));
image = whiteBalance(image);

[~, subImage, subFaceMask] = skinDetection(image);


[~, mouthImg, mouthCenter] = mouthDetection(subImage);

[xPos, yPos ,~, eyeImg] = eyeDetection(subImage, subFaceMask, mouthCenter);


figure;imshow(eyeImg)

[~, triImg] = triangulateFace(xPos,yPos,subImage,mouthCenter);

figure;imshow(triImg)
%imshow(subFaceMask)
%end