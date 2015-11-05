%function [image] = detectFace(im)
im = imread('images\DB0\db0_1.jpg');
[row, col] = size(im);
hsvImage = rgb2hsv(im);
luminanceImage = hsvImage(:,:,3);
saturationImage = hsvImage(:,:,2);
colorImage = hsvImage(:,:,1);

%{
imshow(hsvImage)
figure
imshow((hsvImage(:,:,1)))
figure
imshow((hsvImage(:,:,2)))
figure
imshow((hsvImage(:,:,2)))
%}
luminanceImage2 = luminanceImage;

luminanceImage2(luminanceImage2 < 0.95*max(max(luminanceImage2)));

meanLuma = mean(mean(luminanceImage2(luminanceImage2~=0)));

luminanceImage = luminanceImage*(1/0.85);



luminanceImage(luminanceImage > 1) = 1;

luminanceImage2 = (luminanceImage);

luminanceImage2(luminanceImage2 < 0.95*max(max(luminanceImage2))) = 0;



hsvImage(:,:,3) = luminanceImage2;

image = hsv2rgb(hsvImage);
imshow(image(:,:,1))