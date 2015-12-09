function [finalResult, who, eucDist] = tnm034(image)

image = whiteBalance(image);

[subImage, faceMask] = faceDetection(image);
figure;imshow(subImage)
[result, who, eucDist] = compareToDB(subImage);

finalResult = result < 10000;

if finalResult == 1
    who = sprintf('This is person number %d', who);
else
    who = 'This person does not belong here';
end
    