clear all;
close all;
clc;

sumSize = 0;
n = 1;
N = 4;

image = cell(N,1);
for i = n:N
    image{i} = imread(sprintf('images/DB2/bl_0%d.jpg', i));
    %image = imread(sprintf('images/DB0/db0_%d.jpg',2));
    
    [r c ~] = size(image{i});
    sumSize = sumSize + r * c;
end

for i = n:N
    image{i} = whiteBalance(image{i});

    [~, ~] = skinDetection(image{i},sumSize);

    
end

