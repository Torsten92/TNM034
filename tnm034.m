function [finalResult, who] = tnm034(image)

image = whiteBalance(image);

[subImage, faceMask] = skinDetection(image);

[result, who] = compareToDB(subImage);

finalResult = result < 100;

if finalResult == 1
    who = sprintf('This is person number %d', who);
else
    who = 'This person does not belong here';
end
