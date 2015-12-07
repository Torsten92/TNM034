image = imread('images/db1_07.jpg');
image =rgb2ycbcr(image);
A =  reshape(image(:,:,1),[],1);
A = double(A);

img = 0.5 + (log(A)+1) ./ (5*log(35));
img = sort(img);
plot(img)
