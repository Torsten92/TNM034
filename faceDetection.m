
image = imread('images/db1_01_rotated.jpg');

image = whiteBalance(image);

[subImage, faceMask] = skinDetection(image);

result = compareToDB(subImage);


finalResult = result < 10000;