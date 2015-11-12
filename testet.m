im = imread('images/DB0/db0_4.jpg');

%im2 = whiteBalance(im);

im2 = rgb2ycbcr(im);

im2Y = im2double(im2(:,:,1));
im2Cb = im2double(im2(:,:,2));
im2Cr = im2double(im2(:,:,3));

faceMask = im2Cr./im2Y - im2Cb./im2Y > 0.10;

faceMask = imfill(faceMask, 'holes');


se = strel('disk', 3);
se2 = strel('disk', 9);
se3 = strel('disk', 6);

dilateFace = imerode(imdilate(imerode(faceMask, se), se2), se3);
dilateFace = imfill(dilateFace, 'holes');

im2 = im2double(im);
im2r = im2(:,:,1);
im2g = im2(:,:,2);
im2b = im2(:,:,3);
im2r(im2r > dilateFace) = 0;
im2g(im2g > dilateFace) = 0;
im2b(im2b > dilateFace) = 0;
im2 = cat(3, im2r, im2g, im2b);


horizontalProfile = mean(dilateFace, 1) > 0.01; % Or whatever.
firstColumn = find(horizontalProfile, 1, 'first');
lastColumn = find(horizontalProfile, 1, 'last');
verticalProfile = mean(dilateFace, 2) > 0.01; % Or whatever.
firstRow = find(verticalProfile, 1, 'first');
lastRow = find(verticalProfile, 1, 'last');
subImage = im(firstRow:lastRow, firstColumn:lastColumn,:);
subFaceMask = faceMask(firstRow:lastRow, firstColumn:lastColumn,:);


%%

%MouthDetection

subImageYCbCr = rgb2ycbcr(subImage);

im2Y = im2double(subImageYCbCr(:,:,1));
im2Cb = im2double(subImageYCbCr(:,:,2));
im2Cr = im2double(subImageYCbCr(:,:,3));



%calculate n, "eta"
chromaLength = size(im2Cr(:), 1);
top = ((1/chromaLength) * sum(im2Cr(:).*im2Cr(:)));
bot = ((1/chromaLength) * sum(im2Cr(:)./im2Cb(:)));
n = 0.95 *( top./bot );

%calculate mouthmask 
mouthMask = ((im2Cr.*im2Cr) .* (((im2Cr.*im2Cr) - n.*(im2Cr./im2Cb)).^2));
mouthMask = mouthMask./max(mouthMask(:));
mouthMask = mouthMask > 0.4;
%show mask and the "cleaned" image
figure

imshow(mouthMask);

se = strel('disk', 2);
se2 = strel('disk', 6);
se3 = strel('disk', 4);
dilateFace = imerode(imdilate(imerode(mouthMask, se),se2),se3);

figure
imshow(dilateFace);

%Eye Detection
%%
%Chrominance eyeMap

Cb2 = im2Cb.*im2Cb;
Cr2 = (1-im2Cr).*(1-im2Cr);
CbCr = im2Cb./im2Cr;
eyeMapC = (1/3) .* (Cb2 +Cr2+CbCr);

%Luminance eyeMap
se4 = strel('disk', 3);
eyeMapL = imdilate(im2Y, se4)./(imerode(im2Y,se4)+1);

chrominanceMap = eyeMapC>0.4;
imshow(eyeMapC>0.45);
figure
imshow(eyeMapL);


%full eyeMap
eyeMap = eyeMapC.*eyeMapL;
figure
imshow(eyeMap);
figure
imshow(eyeMap./max(eyeMap(:)));
eyeMap = eyeMap./max(eyeMap(:));

se5 = strel('disk', 8);
dilatedEyeMap = imdilate(eyeMap, se5);
figure
subFaceMask2 = subFaceMask.*chrominanceMap;
imshow(dilatedEyeMap.*subFaceMask2 > 0.55);
temp = dilatedEyeMap.*subFaceMask2;
se6 = strel('disk', 4);
se7 = strel('disk', 6);
se8 = strel('disk', 2);

temp =  imerode(imdilate(imerode(temp, se6),se7),se8)>0.55;
figure
imshow(temp)
%%

im2 = im2double(im);
im2r = im2(:,:,1);
im2g = im2(:,:,2);
im2b = im2(:,:,3);
im2r(im2r > temp) = 0;
im2g(im2g > temp) = 0;
im2b(im2b > temp) = 0;
im2 = cat(3, im2r, im2g, im2b);

figure;
imshow(im2);
%}