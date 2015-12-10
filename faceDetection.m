function [img, faceMask] = skinDetection(image)

img = 0;

[~, skinRegion] = generate_skinmap(image);

%fill holes
groupedSkinArea = imfill(skinRegion, 'holes');

%remove noise
se = strel('disk', 9);
faceMask = (imdilate(groupedSkinArea, se));
faceMask = imfill(faceMask, 'holes');


%decide how many pixels a region must have to not be erased 
[r, c] = size(faceMask);
numbOfpixels = round(r*c*0.033);

%erase white regions if it contains less than numbOfpixels pixels, we only
%want one face region

faceMask = bwareaopen(faceMask, numbOfpixels);

%noise reduction

se = strel('disk', 20);
faceMask = imfill(faceMask, 'holes');
faceMask = imdilate(imerode(faceMask, se), se);

%find all areas of white 
centroidsOffaceMask  = regionprops(faceMask,'BoundingBox','Area');


% Decide min area for faces to be detected
[r c] = size(image);
MinArea = 0.02*r*c; 
L = length(centroidsOffaceMask);

for n = 1:L
    if centroidsOffaceMask(n).Area > MinArea
        %crop all detected faces into subimages
        img = imcrop(image,[centroidsOffaceMask(n).BoundingBox]);

        %generate a new skinmap for the cropped image
        [~, skinRegion] = generate_skinmap(img);

        %fill holes
        groupedSkinArea = imfill(skinRegion, 'holes');

        se = strel('disk', 3);
        se2 = strel('disk', 9);
        se3 = strel('disk', 6);

        %remove noise
        faceMask = imerode(imdilate(imerode(groupedSkinArea, se), se2), se3);
        faceMask = imfill(faceMask, 'holes');
        %decide how many pixels a region must have to not be erased 
        [row, col] = size(faceMask);
        numbOfpixels = round(row*col*0.043);
        %erase white regions if it contains less than numbOfpixels pixels, we only
        %want one face region
        faceMask = bwareaopen(faceMask, numbOfpixels);

        %find all "ones" in faceMask
        [x, y] = find(faceMask);

        X = [x'; y'];
        try
            %calculate coefficient a and b and the center point
            [z, a, b, ~] = fitellipse(X, 'linear', 'constraint', 'trace');

            %the ellipses center coords
            h = z(1);
            k = z(2);

            %meshgrid uses x and y coords, we want rows represent y and x
            %represent cols
            [Y, X] = meshgrid(1:col, 1:row);

            % An ellipse centered at (h,k) is defined by (x-h)^2/a^2 + (y-k)^2/b^2 = 1 
            a2 = a^2;
            b2 = b^2;
            a2b2 = a2*b2;

            ellipse_mask = (b2*(X-h).^2 + a2*(Y-k).^2 <= a2b2);

            %makes the ellipse bigger, important because somtimes it cuts eyes and mouths
            se = strel('disk', 20);
            ellipse_mask = imdilate(ellipse_mask,se);
        catch 
            faceMask = ellipse_mask;
        end
        
        img = im2double(img);

        %Mouth detection
        [~, ~, mouthCenter] = mouthDetection(img, faceMask);
        if ( isnan(mouthCenter(1)) == 0 )
            %Detect eyes and rotate image to align them to the horizontal plane

            [leftEye, rightEye, ~] = eyeDetection(img, faceMask, mouthCenter);
            try
                angle = triangulateFace(leftEye,rightEye);
                
                %rotate all
                img = imrotate(img, angle, 'bilinear');
                faceMask = imrotate(faceMask, angle, 'bilinear');

                %redo all calculations for the rotated image
                %Mouth detection
                [~, ~, mouthCenter] = mouthDetection(img, faceMask);

                %Detect eyes and rotate image to align them to the horizontal plane
                [leftEye, rightEye, ~] = eyeDetection(img, faceMask, mouthCenter);       

                xSize = round(0.2*abs(rightEye(1,1)-leftEye(1,1)));
                ySize = round(0.2*abs(rightEye(1,2)-mouthCenter(1,2)));

                %calculate new mask
                c = [leftEye(1,1)-xSize rightEye(1,1)+xSize rightEye(1,1)+xSize leftEye(1,1)-xSize];
                r = [leftEye(1,2)-ySize rightEye(1,2)-ySize mouthCenter(1,2)+ySize mouthCenter(1,2)+ySize];
                faceMask2 = roipoly(faceMask,c,r);

                %recalculate and crop image with new mask
                img(:,:,1) = img(:,:,1).*faceMask2;
                img(:,:,2) = img(:,:,2).*faceMask2;
                img(:,:,3) = img(:,:,3).*faceMask2;
                
                [row, col] = find(faceMask2);

                img = img(min(row):max(row), min(col):max(col),:);
                
                %Normalize illumination
                img = rgb2ycbcr(img);
                img(:,:,1) = histeq(img(:,:,1));
                img = ycbcr2rgb(img);

            catch
                return;
            end
        end 
    end
end
