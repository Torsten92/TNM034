im = imread('images/DB0/db0_1.jpg');

im2 = whiteBalance(im);

im2 = rgb2ycbcr(im2);

im2Y = im2double(im2(:,:,1));
im2Cb = im2double(im2(:,:,2));
im2Cr = im2double(im2(:,:,3));

imshow(im2Cb./im2Y);
figure;
imshow(im2Cr./im2Y);

faceMask = im2Cr./im2Y - im2Cb./im2Y > 0.1;

se = strel('disk', 3);
se2 = strel('disk', 9);
se3 = strel('disk', 6);

dilateFace = imerode(imdilate(imerode(faceMask, se), se2), se3);

im2 = im2double(im);
im2r = im2(:,:,1);
im2g = im2(:,:,2);
im2b = im2(:,:,3);
im2r(im2r > dilateFace) = 0;
im2g(im2g > dilateFace) = 0;
im2b(im2b > dilateFace) = 0;
im2 = cat(3, im2r, im2g, im2b);

figure;
imshow(im2);
