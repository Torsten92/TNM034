%function [result] = faceDetection(image)

image = imread('images/db1_03.jpg');

image = whiteBalance(image);

[subImage, faceMask] = skinDetection(image);

result = compareToDB(subImage);


finalResult = result < 10000;