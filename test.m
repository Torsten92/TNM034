clear all
for i = 1:16
    if(i < 10)
        image = imread(sprintf('images/DB1/db1_0%d.jpg',i));
    else
        image = imread(sprintf('images/DB1/db1_%d.jpg',i));
    end
    
    %resize so that every image is same size. Convert to grayscale for correct
    %calculations

    
    images{i} = image;
end
%%

%luminance test
for i = 1:16
        
    image = images{i};
    im = rgb2ycbcr(image);
    im(:,:,1)=im(:,:,1)*1.3;
    image = ycbcr2rgb(im);
    [w] = tnm034(image);
    w
end

%%
%rotation test
for i = 1:16
        
    image = images{i};
    im = imrotate(image, 5);
    [w] = tnm034(im);
    w
end