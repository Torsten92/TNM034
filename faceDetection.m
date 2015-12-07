function [finalResult] = faceDetection(image)

image = whiteBalance(image);

[subImage, faceMask] = skinDetection(image);

[result, who] = compareToDB(subImage);


finalResult = result < 100;

