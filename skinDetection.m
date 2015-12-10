function [img, faceMask] = faceDetection(image)

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
%masking, gives the complete mask


%find all areas of white 
centroidsOffaceMask  = regionprops(faceMask,'BoundingBox','Area');


% Decide min area for faces to be detected
[r c] = size(image);
MinArea = 0.02*r*c; 
L = length(centroidsOffaceMask);
%[row, col] = find(faceMask);
   % cropSubImage  = image(min(row):max(row), min(col):max(col), :);


for n = 1:L
    if centroidsOffaceMask(n).Area > MinArea
        %croppar ut alla områden i bilden till sub-bilder
        cropSubImage = imcrop(image,[centroidsOffaceMask(n).BoundingBox]);

        %generera om skinmasken på området
        [~, skinRegion] = generate_skinmap(cropSubImage);

        %fill holes
        groupedSkinArea = imfill(skinRegion, 'holes');

        se = strel('disk', 3);
        se2 = strel('disk', 9);
        se3 = strel('disk', 6);

        %remove noise
        faceMask = imerode(imdilate(imerode(groupedSkinArea, se), se2), se3);
        faceMask = imfill(faceMask, 'holes');
        %decide how many pixels a region must have to not be erased 
        [r, c] = size(faceMask);
        numbOfpixels = round(r*c*0.043);
        %erase white regions if it contains less than numbOfpixels pixels, we only
        %want one face region
        faceMask = bwareaopen(faceMask, numbOfpixels);

        %find all "ones" in faceMask
        [x, y] = find(faceMask);

        X = [x';
            y'];

        %ellipse mask
        try
            [zt, at, bt, ~] = fitellipse(X, 'linear');
            ellipseC = zt;
            r_sq = [bt, at].^2;

            [sizeX, sizeY] = size(faceMask);
            [X, Y] = meshgrid(1:sizeY, 1:sizeX);

            ellipse_mask = ((r_sq(1) * (Y - ellipseC(1)) .^ 2 + r_sq(2) * (X - ellipseC(2)) .^ 2) <= prod(r_sq));

            %makes the ellipse bigger, important because somtimes it cuts eyes and mouths
            se = strel('disk', 20);
            ellipse_mask = imdilate(ellipse_mask,se);

            faceMaskPlusElips = ellipse_mask;
            faceMaskPlusElips = (faceMaskPlusElips > 0.1);

        catch 
            faceMaskPlusElips = faceMask;
        end
        
        faceMask = faceMaskPlusElips > 0.1;

        cropSubImage = im2double(cropSubImage);
        img = zeros(size(cropSubImage));

        img = cropSubImage;

        %Mouth detection
        [~, ~, mouthCenter] = mouthDetection(cropSubImage, faceMask);
        if ( isnan(mouthCenter(1)) == 0 )
            %Detect eyes and rotate image to align them to the horizontal plane
            [leftEye, rightEye, ~] = eyeDetection(img, faceMask, mouthCenter);
            try
                
                [angle, ~] = triangulateFace(leftEye,rightEye,img,mouthCenter);

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
                %faceMask2  = faceMask2(min(row):max(row), min(col):max(col));
                img = img(min(row):max(row), min(col):max(col),:);
                img = rgb2ycbcr(img);
                %Normalize illumination
                %img = 0.1 + (log(A)+1) ./ (10*log(35));

                img(:,:,1) = 0.01 + (log(img(:,:,1))+1) ./ (0.94*log(35));

                img = ycbcr2rgb(img);
                figure;imshow(img)

            catch
                return;
            end
        end 
    end
end
