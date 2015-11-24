clear all
for i = 1:4
    image = imread(sprintf('images/DB0/db0_%d.jpg', i));
    %image = imread(sprintf('images/DB0/db0_%d.jpg',2));
    image = whiteBalance(image);

    [~, subImage, subFaceMask] = skinDetection(image);


    [~, mouthImg, mouthCenter] = mouthDetection(subImage);

    [xPos, yPos ,~, eyeImg] = eyeDetection(subImage, subFaceMask, mouthCenter);

    [~, triImg] = triangulateFace(xPos,yPos,subImage,mouthCenter);

    figure;imshow(triImg)
    %imshow(subFaceMask)
end

