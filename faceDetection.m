
image = imread('images/DB1/db1_02.jpg');

image = whiteBalance(image);

[subImage, faceMask] = skinDetection(image);

result = compareToDB(subImage);