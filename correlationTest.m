
%image1 = imread('images/testDB/image_0018.jpg');
%image2 = imread('images/testDB/image_0019.jpg');
image1 = imread(sprintf('images/DB1/db1_0%d.jpg',9));
image2 = imread(sprintf('images/DB1/db1_0%d.jpg',6));


[~, mouthImg1] = mouthDetection(image1);
[~, mouthImg2] = mouthDetection(image2);


%Extract red channel from mouth area
mouthImg1 = im2double(image1(:,:,1)).*mouthImg1;
mouthImg2 = im2double(image2(:,:,1)).*mouthImg2;

%getCorrelation(im2double(image1(:,:,1)), im2double(image2(:,:,1)))
getCorrelation(mouthImg1, mouthImg2)

%{
function [result] = compareToDB(subFaceMask, mouthImg, eyeImg, triImg)
%Get correlation value and save the best result
result = 0;
for i = 1:16
    if(i < 10)
        image = imread(sprintf('images/DB1/db1_0%d.jpg',i));
    else
        image = imread(sprintf('images/DB1/db1_%d.jpg',i));
    end
    [~, subImageTemp, subFaceMaskTemp] = skinDetection(image);
    [~, mouthImgTemp] = mouthDetection(subImageTemp);
    [~, eyeImgTemp] = eyeDetection(subImageTemp, subFaceMaskTemp);
    [~, triImgTemp] = triangulateFace(mouthImgTemp, eyeImgTemp, subImageTemp);
    
    %Take average of all correlation values
    corrVal = (getCorrelation(mouthImg, mouthImgTemp) +
               getCorrelation(eyeImg, eyeImgTemp) +
               getCorrelation(subFaceMask, subFaceMaskTemp) ) +
               getCorrelation(triImg, triImg) / 4
    if(result < corrVal)
        result = corrVal;
    end
end
%}