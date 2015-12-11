function [leftEye, rightEye, eyeImg] = eyeDetection(subImage, faceMask, mouthCenter)
leftEye = 0;
rightEye = 0;

%eye map
%Minimum size of the eye is 0.063 percent of the faceMask area
[sizeX, sizeY] = size(faceMask);
nrEyePixels = round(sizeX*sizeY*0.00063);

%Convert to yCbCr color space
subImageYCbCr = rgb2ycbcr(subImage);
im2Y = im2double(subImageYCbCr(:,:,1));
im2Cb = im2double(subImageYCbCr(:,:,2));
im2Cr = im2double(subImageYCbCr(:,:,3));


%Magical equations to get eyeMapC
Cb2 = im2Cb.*im2Cb;
Cr2 = (1-im2Cr).^2;%*(1-im2Cr);
CbCr = im2Cb./im2Cr;
eyeMapC = (1/3) .* (Cb2 +Cr2+CbCr);

%histogram equalization
eyeMapHq = histeq(eyeMapC);


%Luminance eyeMapL
se = strel('disk', 4);
eyeMapL = imdilate(im2Y, se)./(imerode(im2Y,se)+1);
eyeMapL = eyeMapL/max(eyeMapL(:));


%full eyeMap
eyeMap = eyeMapHq.*eyeMapL;
se2 = strel('disk', 10);
dilatedEyeMap = imdilate(eyeMap, se2);

%find eyes as a mask by normalizing values and removing pixels outside of
%our facemask
dilatedEyeMap = (dilatedEyeMap./max(dilatedEyeMap(:))).*faceMask;


%Declare final eye image
eyeImg = 0;

%Loop though eyeImg intensity values and stop when we find two eyes.
for intensityThreshold = 0.99:-0.01:0.4
        eyeImg = dilatedEyeMap>(intensityThreshold);

        %Filter away eyes outside of a certain area defined by two circles
        %and one cone.
        innerRadius = (mouthCenter(2)*0.3)^2;
        outerRadius = (mouthCenter(2)*0.7)^2;
        [sizeX, sizeY] = size(faceMask);
        [X, Y] = meshgrid(1:sizeY, 1:sizeX);
        tempMask1 = ( (innerRadius * (Y - mouthCenter(2)) .^ 2 + innerRadius * (X - mouthCenter(1)) .^ 2) <= innerRadius^2 );
        tempMask2 = ( (outerRadius * (Y - mouthCenter(2)) .^ 2 + outerRadius * (X - mouthCenter(1)) .^ 2) <= outerRadius^2 );

        %The cone.
        c = [1 size(faceMask,2)/2 size(faceMask,2)];
        r = [size(faceMask,1)/10 size(faceMask,1) size(faceMask,1)/10];
        tempMask3 = roipoly(faceMask,c,r);

        %Final mask that represent the area where eyes may be.
        tempMask = (tempMask2-tempMask1).*tempMask3;
    
        %remove white pixels below mouth (necessary due to the nature of 
        %our cone)
        tempMask((mouthCenter(2)-20):end, : )=0;

        eyeImg = eyeImg.*tempMask;
        eyeImg = bwareaopen(eyeImg, nrEyePixels);
        [centerCoord, r] = imfindcircles(eyeImg,[10,20]);
        %Run code below if we found two eyes or more. This will end the 
        %loop using the break; command
        [sizeX ~] = size(centerCoord);
        if (sizeX) ~= 0;
            %check if points exist on both sides of the eye
            if  centerCoord(:,1) < mouthCenter(1) == 1 
            elseif centerCoord(:,1) < mouthCenter(1) == 0
            else
                if(size(centerCoord, 1) >= 2)
                    if(size(centerCoord, 1) > 2)           
                        %loop through all pointsand measure thier distance. Merge points if lower
                        %than 2*radius
                        for i = 1:size(centerCoord, 1)-1
                            for j = i+1:size(centerCoord, 1)
                                eye2eye=[centerCoord(i,:);
                                         centerCoord(j,:)];
                                distance = pdist(eye2eye,'minkowski');
                                if(distance < 2*r)
                                    centerCoord(i,1) = round( (centerCoord(i,1)+centerCoord(j,1))/2);
                                    centerCoord(i,2) = round( (centerCoord(i,2)+centerCoord(j,2))/2);

                                    %remove unwanted points by giving them
                                    %high values
                                    centerCoord(j,:) = [1000000, 1000000];
                                end
                            end
                        end
                    end
                    %Sort eye coordinates by their x position and add them
                    %to leftEye and rightEye
                    centerCoord = sortrows(centerCoord);
                    leftEye = round(centerCoord(1,:));
                    rightEye = round(centerCoord(2,:));
                    
                    break;
                end
            end
        end
end

