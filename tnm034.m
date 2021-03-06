function who = tnm034(image)

image = whiteBalance(image);

[subImage, faceMask] = faceDetection(image);

[who, result] = compareToDB(subImage);

finalResult = result < 10000;

if finalResult == 1
    who = sprintf('This is person number %d', who);
else
    who = 'This person does not belong here';
end
    