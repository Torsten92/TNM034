function [mouthCenter] = mouthDetection(cropImage, faceMask)

% mouth map
subImageYCbCr = rgb2ycbcr(cropImage);

im2Cb = im2double(subImageYCbCr(:,:,2));
im2Cr = im2double(subImageYCbCr(:,:,3));

%fallowing the equation from "face detection in color image"
%calculate n, "eta"
chromaLength = size(im2Cr(:), 1);
top = ((1/chromaLength) * sum(im2Cr(:).*im2Cr(:)));
bot = ((1/chromaLength) * sum(im2Cr(:)./im2Cb(:)));
n = 0.97 *( top./bot );

%calculate mouthmask 
mothMap = (im2Cr.^2) .* ((im2Cr.^2) - n.*(im2Cr./im2Cb)).^2;
mothMap = mothMap./max(mothMap(:));

%masking, gives the compleate mouthMap
faceMask = mothMap.* faceMask;

%dilation
se2 = strel('disk', 8);
mouthImg = imdilate(faceMask, se2);

%set the over half of the img to black
[sizeX, sizeY] = size(mouthImg);
mouthImg(1:round(sizeX.*0.6),:) = 0;

%decide how many pixels a region must have to not be erased 
%we decided that regions that are has less than 0.23% pixels of the image will be erased (empriskt)
[row, col] = size(faceMask);
minMouthArea = round(row*col*0.0028);


for mouthIntensity = 0.4:-0.01:0.1

    %if the pixel value is greater than mouthIntensity set pixel value to 1 the rest is 0
    mouthRegion = mouthImg > mouthIntensity;

    %Remove small regions
    se = strel('disk',1);        
    mouthRegion = imerode(mouthRegion,se);

    se2 = strel('disk', 2);
    mouthRegion = imdilate(mouthRegion, se2);
    
    %if the white mouthRegion is greater than minMouthArea, break
    if(nnz(mouthRegion) > minMouthArea)
        break;
    end

end

%erase white regions if it contains less than numbOfpixels pixels, we only
%want one mouth region
mouthRegion = bwareaopen(mouthRegion, minMouthArea);

minMouthArea = round(minMouthArea/70);

se = strel('disk', minMouthArea);
mouthRegion = imerode(imdilate(mouthRegion, se), se);
L = imfill(mouthRegion, 'holes');


%find mouth center
[x, y] = meshgrid(1:size(L, 2), 1:size(L, 1));
weightedx = x .* L;
weightedy = y .* L;
xcentre = sum(weightedx(:)) / sum(L(:));
ycentre = sum(weightedy(:)) / sum(L(:));
xcentre = round(xcentre);
ycentre = round(ycentre);
mouthCenter = [xcentre, ycentre];

