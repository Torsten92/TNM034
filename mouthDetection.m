function [corrVal, mouthImg] = mouthDetection(subImage)
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
n = 0.95 *( top./bot );

%calculate mouthmask 
mouthMap = (im2Cr.*im2Cr) .* ((im2Cr.*im2Cr) - n.*(im2Cr./im2Cb)).^2;
mouthMap = mouthMap./max(mouthMap(:));
%mouthMask = mouthMask > 0.4;
%show mask and the "cleaned" image
 

se = strel('disk', 4);
mouthImg = imdilate(mouthMap,se);

