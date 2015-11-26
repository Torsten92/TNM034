function [result] = compareToDB(subImage, subFaceMask, mouthImg, eyeImg, triImg)

mouthImg = rgb2gray(im2double(subImage)).*mouthImg;
eyeImg = rgb2gray(im2double(subImage)).*eyeImg;
subFaceMask = rgb2gray(im2double(subImage)).*subFaceMask;
triImg = rgb2gray(im2double(triImg));

%Get correlation value and save the best result
result = 0;
for i = 9:9
    if(i < 10)
        image = imread(sprintf('images/DB1/db1_0%d.jpg',i));
    else
        image = imread(sprintf('images/DB1/db1_%d.jpg',i));
    end
    image = whiteBalance(image);
    
    [~, subImageTemp, subFaceMaskTemp] = skinDetection(image);
    [~, mouthImgTemp, mouthCenterTemp] = mouthDetection(subImageTemp);
    [xPos, yPos ,~, eyeImgTemp] = eyeDetection(subImageTemp, subFaceMaskTemp, mouthCenterTemp);
    [~, triImgTemp] = triangulateFace(xPos,yPos,subImageTemp,mouthCenterTemp);
    
    
    mouthImgTemp = rgb2gray(im2double(subImageTemp)).*mouthImgTemp;
    eyeImgTemp = rgb2gray(im2double(subImageTemp)).*eyeImgTemp;
    subFaceMaskTemp = rgb2gray(im2double(subImageTemp)).*subFaceMaskTemp;
    triImgTemp = rgb2gray(im2double(triImgTemp));
    
    %Take average of all correlation values
    corrVal = (getCorrelation(mouthImg, mouthImgTemp) + getCorrelation(eyeImg, eyeImgTemp) + getCorrelation(subFaceMask, subFaceMaskTemp)) / 3;
    if(result < corrVal)
        result = corrVal;
    end
end