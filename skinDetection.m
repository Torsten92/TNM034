function [cropSubImage, faceMask] = skinDetection(image,sumSize)

cbcrIm = rgb2ycbcr(image);

[~, skinRegion] = generate_skinmap(image);

Y = double(cbcrIm(:,:,1));
Cb = double(cbcrIm(:,:,2));
Cr = double(cbcrIm(:,:,3));


%find white parts = red dots
[rowSkinColor, colSkinColor] = find(skinRegion == 1);

%find black parts = blue dots
[rowRepColor, colRepColor] = find(skinRegion == 0);


[skinColLenth, ~] = size(rowSkinColor);
[repColLenth, ~] = size(rowRepColor);

skinColorY = zeros(skinColLenth,1);
skinColorCb = zeros(skinColLenth,1);
skinColorCr = zeros(skinColLenth,1);

repColorY = zeros(repColLenth,1);
repColorCb = zeros(repColLenth,1);
repColorCr = zeros(repColLenth,1);


%find skin color value in lightComp image with skin color positions
for i = 1:skinColLenth
        skinColorY(i,1) = Y(rowSkinColor(i),colSkinColor(i));
        skinColorCr(i,1) = Cr(rowSkinColor(i),colSkinColor(i));
        skinColorCb(i,1) = Cb(rowSkinColor(i),colSkinColor(i));
end

for i = 1:repColLenth
        repColorCb(i,1) = Cb(rowRepColor(i),colRepColor(i));
        repColorCr(i,1) = Cr(rowRepColor(i),colRepColor(i));
        repColorY(i,1) = Y(rowRepColor(i),colRepColor(i));
end


%fill holes
groupedSkinArea = imfill(skinRegion, 'holes');



se = strel('disk', 3);
se2 = strel('disk', 9);
se3 = strel('disk', 6);

%remove noise
faceMask = (imdilate(groupedSkinArea, se2));
faceMask = imfill(faceMask, 'holes');

%decide how many pixels a region must have to not be erased 
[r, c] = size(faceMask);
numbOfpixels = round(r*c*0.033);
%erase white regions if it contains less than numbOfpixels pixels, we only
%want one face region
faceMask = bwareaopen(faceMask, numbOfpixels);

%noise reduction
se = strel('disk', 20);
faceMask = imfill(faceMask, 'holes');
faceMask = imdilate(imerode(faceMask, se), se);
%masking, gives the complete mask


%find all areas of white 
centroidsOffaceMask  = regionprops(faceMask,'BoundingBox','Area');


% Select largest area you want to keep.
MaxArea = numbOfpixels; 
% Detect cells larger than some value.
centroidsOffaceMask = centroidsOffaceMask([centroidsOffaceMask.Area] > MaxArea); 


L = length(centroidsOffaceMask);

%[row, col] = find(faceMask);
   % cropSubImage  = image(min(row):max(row), min(col):max(col), :);


for n = 1:L
    
    %croppar ut alla områden i bilden till sub-bilder
    cropSubImage = imcrop(image,[centroidsOffaceMask(n).BoundingBox]);

    %generera om skinmasken på området
    [~, skinRegion] = generate_skinmap(cropSubImage);
    
    
    %fill holes
    groupedSkinArea = imfill(skinRegion, 'holes');

    se = strel('disk', 3);
    se2 = strel('disk', 9);
    se3 = strel('disk', 6);

    %remove noise
    faceMask = imerode(imdilate(imerode(groupedSkinArea, se), se2), se3);
    faceMask = imfill(faceMask, 'holes');
    %decide how many pixels a region must have to not be erased 
    [r, c] = size(faceMask);
    numbOfpixels = round(r*c*0.043);
    %erase white regions if it contains less than numbOfpixels pixels, we only
    %want one face region
    faceMask = bwareaopen(faceMask, numbOfpixels);
   
    %find all "ones" in faceMask
    [x, y] = find(faceMask);

    X = [x';
        y'];

    %ellipse mask
 
    [zt, at, bt, ~] = fitellipse(X, 'linear', 'constraint', 'trace');
    ellipseC = zt;
    r_sq = [bt, at].^2;

    [sizeX, sizeY] = size(faceMask);
    [X, Y] = meshgrid(1:sizeY, 1:sizeX);
    ellipse_mask = ((r_sq(1) * (Y - ellipseC(1)) .^ 2 + r_sq(2) * (X - ellipseC(2)) .^ 2) <= prod(r_sq));

    %makes the elips bigger, important because somtimes it cuts eyes and mouths
    se = strel('disk', 20);
    ellipse_mask = imdilate(ellipse_mask,se);
    
     
    faceMaskPlusElips = ellipse_mask;
    faceMaskPlusElips(faceMaskPlusElips > 0.1);
    faceMask = faceMaskPlusElips > 0.1;
    
    assignin('base', 'faceMask', faceMask);
    assignin('base', 'cropSubImage', cropSubImage);
    cropSubImage = im2double(cropSubImage);
    img = zeros(size(cropSubImage));
    img(:,:,1) = cropSubImage(:,:,1).*faceMask;
    img(:,:,2) = cropSubImage(:,:,2).*faceMask;
    img(:,:,3) = cropSubImage(:,:,3).*faceMask;

    [~, mouthImg, mouthCenter] = mouthDetection(cropSubImage, faceMask);
    
    if ( isnan(mouthCenter(1))==0 && isnan(mouthCenter(2)) == 0  )

        [xPos, yPos, corrVal, eyeImg] = eyeDetection(img, faceMask, mouthCenter,sumSize);
    

         [~, triImg] = triangulateFace(xPos,yPos,cropSubImage,mouthCenter);
         
    else
        %om det inte finns en mun SKA allt explodera 
        
    end
    
    
end


