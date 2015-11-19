im = imread('images/DB1/db1_10.jpg');
shapeInserter = vision.ShapeInserter('Shape','Polygons','BorderColor','Custom', 'CustomBorderColor', uint8([255 0 0]));
lightingCompImg = whiteBalance(im);

%lightingCompImg = imag_improve_rgb(im);

cbcrIm = rgb2ycbcr(lightingCompImg);

[out bin] = generate_skinmap(lightingCompImg);



Y = double(cbcrIm(:,:,1));
Cb = double(cbcrIm(:,:,2));
Cr = double(cbcrIm(:,:,3));



%imshow(im);
%figure; imshow(lightingCompImg);

skinRegion = bin;




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

%figure
%imshow(skinColorCr/255)

for i = 1:repColLenth
    repColorCb(i,1) = Cb(rowRepColor(i),colRepColor(i));
    repColorCr(i,1) = Cr(rowRepColor(i),colRepColor(i));
    repColorY(i,1) = Y(rowRepColor(i),colRepColor(i));
end


figure
plot3(skinColorCb,skinColorCr,skinColorY,'.r');
xlabel('Cb') % x-axis label
ylabel('Cr') % y-axis label
zlabel('Y') % y-axis label

hold on

plot3(repColorCb,repColorCr,repColorY,'.b');

figure
plot(skinColorCb./skinColorY,skinColorCr./skinColorY,'.r');
xlabel('Cb') % x-axis label
ylabel('Cr') % y-axis label

hold on

plot(repColorCb./repColorY,repColorCr./repColorY,'.b');

%fill holes like eyse
groupedSkinArea = imfill(skinRegion, 'holes');


se = strel('disk', 3);
se2 = strel('disk', 9);
se3 = strel('disk', 6);

%remove noise
faceMask = imerode(imdilate(imerode(groupedSkinArea, se), se2), se3);
faceMask = imfill(faceMask, 'holes');

im2 = im2double(im);
im2r = im2(:,:,1);
im2g = im2(:,:,2);
im2b = im2(:,:,3);
im2r(im2r > faceMask) = 0;
im2g(im2g > faceMask) = 0;
im2b(im2b > faceMask) = 0;
im2 = cat(3, im2r, im2g, im2b);


%%cuts away background
horizontalProfile = mean(faceMask, 1) > 0.01; % Or whatever.
firstColumn = find(horizontalProfile, 1, 'first');
lastColumn = find(horizontalProfile, 1, 'last');
verticalProfile = mean(faceMask, 2) > 0.01; % Or whatever.
firstRow = find(verticalProfile, 1, 'first');
lastRow = find(verticalProfile, 1, 'last');
subImage = im(firstRow:lastRow, firstColumn:lastColumn,:);
subFaceMask = faceMask(firstRow:lastRow, firstColumn:lastColumn,:);



figure
x = linspace(-5,5);
y1 = sin(x);
subplot(2,2,1)
imshow(skinRegion);
title('skinRegion')

y2 = sin(2*x);
subplot(2,2,2)
imshow(groupedSkinArea);
title('groupedSkinArea')

y3 = sin(4*x);
subplot(2,2,3)
imshow(faceMask);
title('faceMask')

y4 = sin(6*x);
subplot(2,2,4)
imshow(subFaceMask);
title('subFaceMask')


%%  mouth map
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
 

se = strel('disk', 1);
se2 = strel('disk', 4);
se3 = strel('disk', 3);
dilateFace = imdilate(mouthMap,se2);

%find mouth center
detectMouth = dilateFace > 0.3;
detectMouth = bwareaopen(detectMouth, 600);
figure;imshow(detectMouth)

[x, y] = meshgrid(1:size(detectMouth, 2), 1:size(detectMouth, 1));
weightedx = x .* detectMouth;
weightedy = y .* detectMouth;
xcentre = sum(weightedx(:)) / sum(detectMouth(:));
ycentre = sum(weightedy(:)) / sum(detectMouth(:));
xcentre = round(xcentre);
ycentre = round(ycentre);





CrDCb = im2Cr./im2Cb;
norm = max(max(CrDCb));
CrDCb = CrDCb./norm;

CrMCr = im2Cr.*im2Cr;
norm = max(max(CrMCr));
CrMCr = CrMCr./norm;

figure
x = linspace(-5,5);
y1 = sin(x);
subplot(2,2,1)
imshow(CrDCb);
title('Cr/Cb')

y2 = sin(2*x);
subplot(2,2,2)
imshow(CrMCr);
title('(Cr)²')

y3 = sin(4*x);
subplot(2,2,3)
imshow(mouthMap);
title('mouthMap')

y4 = sin(6*x);
subplot(2,2,4)
imshow(dilateFace);
title('dilated & masked')



%%


%Eye Detection
%Chrominance eyeMapC

Cb2 = im2Cb.*im2Cb;
Cr2 = (1-im2Cr).^2;%*(1-im2Cr);
CbCr = im2Cb./im2Cr;
eyeMapC = (1/3) .* (Cb2 +Cr2+CbCr);

%histogram equalization
eyeMapHq = histeq(eyeMapC);



%Luminance eyeMapL
se4 = strel('disk', 4);
eyeMapL = imdilate(im2Y, se4)./(imerode(im2Y,se4)+1);
eyeMapL = eyeMapL/max(eyeMapL(:));


%full eyeMap
eyeMap = eyeMapHq.*eyeMapL;
%imshow(eyeMap);
se5 = strel('disk', 10);
dilatedEyeMap = imdilate(eyeMap, se5);

%find eyes as a mask
norm = max(max(dilatedEyeMap));
dilatedEyeMap = dilatedEyeMap./norm;
detectEye = dilatedEyeMap>0.85;
detectEye = bwareaopen(detectEye.*subFaceMask, 170);
figure;imshow(detectEye)

%subplot into 2 images
[c,r] = imfindcircles(detectEye,[10,20]);
figure;imshow(detectEye);
viscircles(c,r);
eyesCenter =round(c);

polygon = int32([eyesCenter(1,1) eyesCenter(1,2) eyesCenter(2,1) eyesCenter(2,2) xcentre ycentre]); 
J = step(shapeInserter, subImage, polygon);
figure;imshow(J); 

figure
x = linspace(-5,5);
y1 = sin(x);
subplot(2,2,1)
imshow(eyeMapHq);
title('eyeMapC')

y2 = sin(2*x);
subplot(2,2,2)
imshow(eyeMapL);
title('eyeMapL')

y3 = sin(4*x);
subplot(2,2,3)
imshow(eyeMap);
title('eyeMap')

y4 = sin(6*x);
subplot(2,2,4)
imshow((dilatedEyeMap));
title('dilated and masked')

%%

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
%}