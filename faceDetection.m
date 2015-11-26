clear all

sumSize = 0;
N = 9;
image = cell(N,1);
for i = 1:N
    image{i} = imread(sprintf('images/DB1/db1_0%d.jpg', i));
    %image = imread(sprintf('images/DB0/db0_%d.jpg',2));
    
    [r c ~] = size(image{i});
    sumSize = sumSize + r * c;
end

for i = 1:N
    image{i} = whiteBalance(image{i});

    [cropImage, faceMask] = skinDetection(image{i});

    [~, mouthImg, mouthCenter] = mouthDetection(cropImage, faceMask);

    [xPos, yPos ,~, eyeImg] = eyeDetection(cropImage, faceMask, mouthCenter, sumSize);
    
    [~, triImg] = triangulateFace(xPos,yPos,cropImage,mouthCenter);

    %corrVal = compareToDB(subImage, subFaceMask, mouthImg, eyeImg, triImg);
    figure;
    imshow(triImg)
end



