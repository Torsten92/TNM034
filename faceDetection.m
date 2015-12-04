function [result] = faceDetection(image)

image = whiteBalance(image);

[subImage, faceMask] = skinDetection(image);

result = compareToDB(subImage);


finalResult = result < 10000;
