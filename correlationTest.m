
image1 = imread('images/testDB/image_0018.jpg');
image2 = imread('images/testDB/image_0019.jpg');

[~, mouthImg1] = mouthDetection(image1);
[~, mouthImg2] = mouthDetection(image2);


%Extract red channel from mouth area
mouthImg1 = im2double(image1(:,:,1)).*mouthImg1;
mouthImg2 = im2double(image2(:,:,1)).*mouthImg2;

getCorrelation(im2double(image1(:,:,1)), im2double(image2(:,:,1)))
%getCorrelation(mouthImg1, mouthImg2)

