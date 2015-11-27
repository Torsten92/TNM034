function [result] = compareToDB(subImage)

%Set image dimensions
w = 64; h = 64;

subImage = imresize(rgb2gray(im2double(whiteBalance(subImage))), [w, h]);

load('EigenfacesDB.mat');

weigthInput = PCA' * (subImage(:) - avgImg);

eucDist = zeros(16, 1);
for i = 1:16
    eucDist(i) = norm(weight(:,i)-weigthInput)^2;
end

result = min(eucDist);