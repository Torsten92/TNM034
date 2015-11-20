%function [massa argument] = faceDetection(image)
%for i = 1:9
  %imageName = sprintf('images/DB1/db1_0%d.jpg',i)
  %image = imread(imageName);
  image = imread('images/DB1/db1_05.jpg');

    image = whiteBalance(image);

    [~, subImage, subFaceMask] = skinDetection(image);

    [~, mouthImg] = mouthDetection(subImage);
    
    [~, eyeImg] = eyeDetection(subImage, subFaceMask);
    figure;imshow(eyeImg)

    [~, triImg] = triangulateFace(mouthImg, eyeImg, subImage);

    figure;imshow(triImg)
%end