%Authors: Torsten Gustafsson and Marcus Lilja
%Calculate eigenface weigths, principal component analysis and the average
%of our database images into the file 'EigenfacesDB.mat' which is then used
%by our compareToDB function.

%Set image dimensions
w = 64; h = 64;

images = zeros(w*h, 16);
for i = 1:16
    if(i < 10)
        image = imread(sprintf('images/DB1/db1_0%d.jpg',i));
    else
        image = imread(sprintf('images/DB1/db1_%d.jpg',i));
    end
    
    %resize so that every image is same size. Convert to grayscale for correct
    %calculations
    [~, subImageTemp, ~] = skinDetection(image);
    subImageTemp = imresize(rgb2gray(im2double(whiteBalance(subImageTemp))), [w, h]);
    
    images(:, i) = subImageTemp(:);
end

%Get the average of database images
avgImg = sum(images, 2) ./ 16;

phiImg = zeros(w*h, 16);
for i = 1:16
    phiImg(:,i) = images(:,i) - avgImg;
end

%Perform PCA (Principal Component Analysis) on the data

%Calculate covariance and obtain eigenvalue & eigenvector 
[V,D] = eig(cov(phiImg));

% eig() saves the principal components backwards
V = fliplr(V); 

PCA = phiImg*V;

weight = zeros(16, 16);
for i = 1:16
    weight(:,i) = PCA' * phiImg(:,i);
end


save('EigenfacesDB.mat', 'avgImg', 'PCA', 'weight');

