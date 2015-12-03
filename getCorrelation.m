function [corrVal] = getCorrelation(img1, img2)

% img1 och img2 ska helst vara gråskalebilder med dess orelevanta pixlar
% helsvarta.

%cuts away black background
horizontalProfile = mean(img1, 1) > 0.01; % or whatever
firstColumn = find(horizontalProfile, 1, 'first');
verticalProfile = mean(img1, 2) > 0.01;
firstRow = find(verticalProfile, 1, 'first');
subImage1 = img1(firstRow:size(img1,1), firstColumn:size(img1,2));

horizontalProfile = mean(img2, 1) > 0.01;
firstColumn = find(horizontalProfile, 1, 'first');
verticalProfile = mean(img2, 2) > 0.01;
firstRow = find(verticalProfile, 1, 'first');
subImage2 = img2(firstRow:size(img2,1), firstColumn:size(img2,2));

z = zeros(10000, 10000);
z(1:size(subImage1, 1), 1:size(subImage1, 2)) = subImage1;
subImage1 = z;
z = zeros(10000, 10000);
z(1:size(subImage2, 1), 1:size(subImage2, 2)) = subImage2;
subImage2 = z;

% get common size of images
horizontalProfile = mean(subImage1, 1) > 0.01;
lastColumn = find(horizontalProfile, 1, 'last');
horizontalProfile = mean(subImage2, 1) > 0.01;
lastColumn = int32(max(find(horizontalProfile, 1, 'last'), lastColumn));

verticalProfile = mean(subImage1, 2) > 0.01;
lastRow = find(verticalProfile, 1, 'last');
verticalProfile = mean(subImage2, 2) > 0.01;
lastRow = int32(max(find(verticalProfile, 1, 'last'), lastRow));
subImage1 = subImage1(1:lastRow, 1:lastColumn);
subImage2 = subImage2(1:lastRow, 1:lastColumn);

imshow(subImage1)
figure
imshow(subImage2)

%corrVal close to 1 means good result
temp = subImage1.*subImage2;
corrVal = (mean(temp(:)) - mean(subImage1(:))*mean(subImage2(:)))/(std(subImage1(:))*std(subImage2(:)));
