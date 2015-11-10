im = imread('images/DB0/db0_4.jpg');

im2 = whiteBalance(im);

im2 = rgb2ycbcr(im2);

im2Y = im2double(im2(:,:,1));
im2Cb = im2double(im2(:,:,2));
im2Cr = im2double(im2(:,:,3));

%{
imshow(im2Cr./im2Cb);
figure;
imshow(pow2(im2Cr));
figure
imshow(im2Cr./im2Cb - pow2(im2Cr));

figure
imshow((im2Cr./im2Cb - pow2(im2Cr)).*pow2(im2Cr));

%}


[c, r] = size(im2Cr);
chromaLength = c*r;

top = ((1/chromaLength) * sum(sum( ( im2Cr(:,:).*im2Cr) )));
bot = ((1/chromaLength)* sum(sum(im2Cr(:,:)./im2Cb(:,:))));
n = 0.95 *( top./bot );

faceMask = im2Cr./im2Y - im2Cb./im2Y > 0.001;

mouthMask = ((im2Cr.*im2Cr) .* (((im2Cr.*im2Cr) - n.*(im2Cr./im2Cb)).^2))>0.001;



figure
imshow(mouthMask);

    


%faceMask = im2Cr./im2Y - im2Cb./im2Y > 0.1;
se = strel('disk', 1);
se2 = strel('disk', 4);
se3 = strel('disk', 3);

%dilateFace = imdilate(mouthMask ,se2);

dilateFace = imerode(imdilate(imerode(mouthMask, se),se2),se3);

figure
imshow(dilateFace);


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
