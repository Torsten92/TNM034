function [corrVal, mouthImg, mouthCenter] = mouthDetection(subImage)
corrVal = 0;

% mouth map
subImageYCbCr = rgb2ycbcr(subImage);

im2Y = im2double(subImageYCbCr(:,:,1));
im2Cb = im2double(subImageYCbCr(:,:,2));
im2Cr = im2double(subImageYCbCr(:,:,3));


%calculate n, "eta"
chromaLength = size(im2Cr(:), 1);
top = ((1/chromaLength) * sum(im2Cr(:).*im2Cr(:)));
bot = ((1/chromaLength) * sum(im2Cr(:)./im2Cb(:)));
n = 0.97 *( top./bot );

%calculate mouthmask 
mouthMap = (im2Cr.*im2Cr) .* ((im2Cr.*im2Cr) - n.*(im2Cr./im2Cb)).^2;
mouthMap = mouthMap./max(mouthMap(:));
%mouthMask = mouthMask > 0.4;
%show mask and the "cleaned" image


a = round(sum(size(mouthMap))*0.3)
mouthImg = mouthMap > 0.35;
mouthImg = bwareaopen(mouthImg, a);


%Dilate first to fill lips. Erode to remove artefacts
a = round(a/70);
se = strel('disk', a);
mouthImg = imerode(imdilate(mouthImg, se), se);
mouthImg = imfill(mouthImg, 'holes');
mouthImg = imdilate(imerode(mouthImg,se),se);

%find mouth center
[x, y] = meshgrid(1:size(mouthImg, 2), 1:size(mouthImg, 1));
weightedx = x .* mouthImg;
weightedy = y .* mouthImg;
xcentre = sum(weightedx(:)) / sum(mouthImg(:));
ycentre = sum(weightedy(:)) / sum(mouthImg(:));
xcentre = round(xcentre);
ycentre = round(ycentre);
mouthCenter = [xcentre, ycentre]
    

