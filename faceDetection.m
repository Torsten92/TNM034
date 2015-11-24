%function [massa argument] = faceDetection(image)

for i = 1:9
%image = imread(sprintf('images/DB1/db1_0%d.jpg',i));
image = imread(sprintf('images/DB1/db1_0%d.jpg',i));
image = whiteBalance(image);

[~, subImage, subFaceMask] = skinDetection(image);
[~, mouthImg] = mouthDetection(subImage);
[~, eyeImg] = eyeDetection(subImage, subFaceMask);
%[~, triImg] = triangulateFace(mouthImg, eyeImg, subImage);

%corrVal = compareToDB(subFaceMask, mouthImg, eyeImg, triImg);

figure
imshow(cat(3, mouthImg, mouthImg, mouthImg).*im2double(subImage))
%imshow(triImg)
end


%det som ligger innanför head är det gamla, ta bort