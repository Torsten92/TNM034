function [result] = tnm034(image)

image = whiteBalance(image);

[subImage, ~] = skinDetection(image);

result = compareToDB(subImage);


result = result < 10000;