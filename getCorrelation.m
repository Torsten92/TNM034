function [corrVal] = getCorrelation(img1, img2)

% img1 and img2 should be 2D grayscale images with unrelevant pixels set to
% 0 (black).

%cuts away black background
horizontalProfile = mean(img1, 1) > 0.01; % or whatever
firstColumn = find(horizontalProfile, 1, 'first');
lastColumn = find(horizontalProfile, 1, 'last');
verticalProfile = mean(img1, 2) > 0.01;
firstRow = find(verticalProfile, 1, 'first');
lastRow = find(verticalProfile, 1, 'last');
subImage1 = img1(firstRow:lastRow, firstColumn:lastColumn);

horizontalProfile = mean(img2, 1) > 0.01;
firstColumn = find(horizontalProfile, 1, 'first');
lastColumn = find(horizontalProfile, 1, 'last');
verticalProfile = mean(img2, 2) > 0.01;
firstRow = find(verticalProfile, 1, 'first');
lastRow = find(verticalProfile, 1, 'last');
subImage2 = img2(firstRow:lastRow, firstColumn:lastColumn);

% Resize images according to the largest image's dimensions
xDim = max(size(subImage1,1), size(subImage2,1));
yDim = max(size(subImage1,2), size(subImage2,2));
subImage1 = imresize(subImage1, [xDim yDim]);
subImage2 = imresize(subImage2, [xDim yDim]);

imshow(subImage1)
figure
imshow(subImage2)

%corrVal close to 1 means good result
temp = subImage1.*subImage2;
corrVal = (mean(temp(:)) - mean(subImage1(:))*mean(subImage2(:)))/(std(subImage1(:))*std(subImage2(:)));