function [finalResult, who] = tnm034(image)

image = whiteBalance(image);

[subImage, faceMask] = skinDetection(image);

[result, who] = compareToDB(subImage);

who = sprintf('this is person number %d', who);
finalResult = result < 100;
