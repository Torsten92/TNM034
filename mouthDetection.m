function [corrVal, mouthImg, mouthCenter] = mouthDetection(cropImage, faceMask)
corrVal = 0;

% mouth map
subImageYCbCr = rgb2ycbcr(cropImage);

im2Y = im2double(subImageYCbCr(:,:,1));
im2Cb = im2double(subImageYCbCr(:,:,2));
im2Cr = im2double(subImageYCbCr(:,:,3));

%fallowing the equation from "face detection in color image"
%calculate n, "eta"
chromaLength = size(im2Cr(:), 1);
top = ((1/chromaLength) * sum(im2Cr(:).*im2Cr(:)));
bot = ((1/chromaLength) * sum(im2Cr(:)./im2Cb(:)));
n = 0.97 *( top./bot );

%calculate mouthmask 
mouthMap = (im2Cr.^2) .* ((im2Cr.^2) - n.*(im2Cr./im2Cb)).^2;
mouthMap = mouthMap./max(mouthMap(:));

%masking, gives the compleate mouthMap
finalMouthMap = faceMask.* mouthMap;

%dilation
se2 = strel('disk', 8);
mouthImg = imdilate(finalMouthMap, se2);


%invert color, necessary when we subtract dilatedEyeMap with faceMask
%mouthMap = imcomplement(mouthMap);





%set the over half of the img to black
[sizeX sizeY] = size(mouthImg);
mouthImg(1:round(6*sizeX/10),:) = 0;



%if the pixel value is greater than 38% set pixel value to 1 the rest is 0
mouthImg = mouthImg > 0.38;
%mouthImg = imfill(mouthImg,[3 3],8)
%assignin('base', 'stats', stats);



[r c] = size(mouthMap);

%decide how many pixels a region must have to not be erased 
%we decided that regions that are has less than 0.23% pixels of the image will be erased (empriskt) 
numbOfpixels = round(r*c*0.0028);

assignin('base', 'mouthMap', mouthImg);

%Remove small regions
se = strel('disk',1);        
mouthImg = imerode(mouthImg,se);

se2 = strel('disk', 2);
mouthImg = imdilate(mouthImg, se2);




%Find connected components (regions) in binary image
cc = bwconncomp(mouthImg); 
stats = regionprops(cc, 'Area','Eccentricity'); 



%images mouth region must be bigger than 100 pixels and it's Eccentricity
%must be greater than 0.84 (empiriskt)
%Eccentricity is the ratio of the distance between the foci of the ellipse
%and its major axis lengths, scalar
%{
idx = find([stats.Area] > 100 & [stats.Eccentricity] > 0.84); 
%check labelmatrix(cc) elements that are members of idx
mouthImg = ismember(labelmatrix(cc), idx);
assignin('base', 'labelmatrix', labelmatrix(cc));
assignin('base', 'idx', idx);
assignin('base', 'stats', stats);

%}




%erase white regions if it contains less than numbOfpixels pixels, we only
%want one mouth region
mouthImg = bwareaopen(mouthImg, numbOfpixels);


%Dilate first to fill lips

numbOfpixels = round(numbOfpixels/70);

se = strel('disk', numbOfpixels);
mouthImg = imerode(imdilate(mouthImg, se), se);
L = imfill(mouthImg, 'holes');


%find mouth center
xcentre = 1;
ycentre = 1;
[x, y] = meshgrid(1:size(L, 2), 1:size(L, 1));
weightedx = x .* L;
weightedy = y .* L;
xcentre = sum(weightedx(:)) / sum(L(:));
ycentre = sum(weightedy(:)) / sum(L(:));
xcentre = round(xcentre);
ycentre = round(ycentre);
mouthCenter = [xcentre, ycentre];


