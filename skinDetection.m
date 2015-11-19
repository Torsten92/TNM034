function [corrVal, subImage, subFaceMask] = skinDetection(image)
corrVal = 0;

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
faceMask = imerode(imdilate(imerode(groupedSkinArea, se), se2), se3);
faceMask = imfill(faceMask, 'holes');

%%cuts away background
horizontalProfile = mean(faceMask, 1) > 0.01; % Or whatever.
firstColumn = find(horizontalProfile, 1, 'first');
lastColumn = find(horizontalProfile, 1, 'last');
verticalProfile = mean(faceMask, 2) > 0.01; % Or whatever.
firstRow = find(verticalProfile, 1, 'first');
lastRow = find(verticalProfile, 1, 'last');
subImage = image(firstRow:lastRow, firstColumn:lastColumn,:);
subFaceMask = faceMask(firstRow:lastRow, firstColumn:lastColumn,:);


[sizeX, sizeY] = size(subFaceMask);

[x, y] = find(subFaceMask);


X = [x';
    y'];

%ellipse mask
[zt, at, bt, alphat] = fitellipse(X, 'linear', 'constraint', 'trace');
ellipseC = zt;
r_sq = [bt, at].^2;
[X, Y] = meshgrid(1:sizeY, 1:sizeX);
ellipse_mask = ((r_sq(1) * (Y - ellipseC(1)) .^ 2 + r_sq(2) * (X - ellipseC(2)) .^ 2) <= prod(r_sq));

%sphere mask


subFaceMask = ellipse_mask+subFaceMask;

subFaceMask=  subFaceMask>0.1;



