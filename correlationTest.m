

image1 = imread('images/DB1/db1_03.jpg');
image2 = imread('images/DB1/db1_02.jpg');

[~, mouthImg1] = mouthDetection(image1);
[~, mouthImg2] = mouthDetection(image2);


%Extract red channel from mouth area
mouthImg1 = im2double(image1(:,:,1)).*mouthImg1;
mouthImg2 = im2double(image2(:,:,1)).*mouthImg2;


%%cuts away background
horizontalProfile = mean(mouthImg1, 1) > 0.01; % or whatever
firstColumn = find(horizontalProfile, 1, 'first');
verticalProfile = mean(mouthImg1, 2) > 0.01;
firstRow = find(verticalProfile, 1, 'first');
subImage1 = mouthImg1(firstRow:size(mouthImg1,1), firstColumn:size(mouthImg1,2));

horizontalProfile = mean(mouthImg2, 1) > 0.01;
firstColumn = find(horizontalProfile, 1, 'first');
verticalProfile = mean(mouthImg2, 2) > 0.01;
firstRow = find(verticalProfile, 1, 'first');
subImage2 = mouthImg2(firstRow:size(mouthImg2,1), firstColumn:size(mouthImg2,2));

% get common size of mouths
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

%C close to 1 means good result
temp = subImage1.*subImage2;
C = (mean(temp(:)) - mean(subImage1(:))*mean(subImage2(:)))/(std(subImage1(:))*std(subImage2(:)))


