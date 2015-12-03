function [xPos, yPos, corrVal, eyeImg] = eyeDetection(subImage, subFaceMask, mouthCenter, sumSize)


[sizeX sizeY] = size(subFaceMask);
%eye map


nrEyePixels = round(sizeX*sizeY*0.00063);

subImageYCbCr = rgb2ycbcr(subImage);

im2Y = im2double(subImageYCbCr(:,:,1));
im2Cb = im2double(subImageYCbCr(:,:,2));
im2Cr = im2double(subImageYCbCr(:,:,3));


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

%find eyes as a mask
norm2 = max(dilatedEyeMap(:));
dilatedEyeMap = dilatedEyeMap./norm2;

eyeImg = dilatedEyeMap>1;

eyeImg = bwareaopen(eyeImg.*subFaceMask, nrEyePixels);

[sizeX, sizeY] = size(subImage);
mouthRadius = round(sizeX*sizeY*0.00006);
%subplot into 2 images


[c,r] = imfindcircles(eyeImg,[10,20]);
[row, ~] = size(c);

%check if 0.99 is a good threashold, if not
%find 4 eyes with a sliding threashold
if(row <2)
    for h = 99:-1:40
        eyeImg = dilatedEyeMap>(h/100);
        %remove everything below mouth
        eyeImg((mouthCenter(2)-20):end, : )=0;

        eyeImg = bwareaopen(eyeImg.*subFaceMask, nrEyePixels);
        [c,r] = imfindcircles(eyeImg,[10,20]);
        [row, ~] = size(c);
       
        if(row > 3 )
            break;
        else
        end
    end
end



%close all areas that are to small
eyeImg = bwareaopen(eyeImg.*subFaceMask, nrEyePixels);



%assign default values
xPos = 1:2;
yPos = 1:2;
x1 = 1;
y1 = 1;
x2 = 2;
y2 = 2;

%calculate a vector from mouth center to top of image
refmouthPoint = [1, mouthCenter(2)];
mouthRefVector = refmouthPoint-mouthCenter;

%assign and round centerpoints and distance vector
c = round(c);
boolFlag = 0;
d = 1:row;
d(:) = 1000000;

%check if all eyes are below mouth
%if so the code will use default values
for n = 1:row
    if (c(n,2) > mouthCenter(2))
        boolFlag = boolFlag+1;
    end
end


    
%if there are more than 2 eyes
if(row>2)

    %compare distance from eye2eye
    %and mergethem if to close
    for n = 1:row
        for j = 1:row
            if(n~=j)
                eye2eye=[c(n,1), c(n,2);
                        c(j,1), c(j,2)];
                distance = pdist(eye2eye,'minkowski');
                if(distance > (2*r))
                else
                    c(n,1) = round( (c(n,1)+c(j,1))/2);
                    c(n,2) = round( (c(n,2)+c(j,2))/2);
                    c(j,1) = sizeX;
                    c(j,2) = sizeY;
                end
            end
        end
    end

    eyesCenter=[mouthCenter(1) mouthCenter(2);
                1 1];

    %calculates the distance to that point
    for n = 1:row
        eyesCenter(2,1) = c(n,1);
        eyesCenter(2,2) = c(n,2);
        lengthToPoint = pdist(eyesCenter,'minkowski');

        if(lengthToPoint > mouthRadius )
           d(n) = lengthToPoint;
        else
           d(n) = 1000000;
        end

    end

    %check angle from a vector to seed away some points
    %uses closest points from mouth as eyes
    kol = 1;
    for n = 1:row

        l = find(d == min(d));
        x1 = c(l,1);
        y1 = c(l,2);
        possibleEyePoint = [x1,y1];
        d(d == min(d)) = 1000000;
        [ex, ye] = size(possibleEyePoint);

        %evil break of doom!
        if((ex*ye) > 3)
            break;
        end

        eyeVector = possibleEyePoint-mouthCenter;

        CosTheta = dot(eyeVector,mouthRefVector)/(norm(eyeVector)*norm(mouthRefVector));
        abs(CosTheta);

        if(abs(CosTheta) < 0.55 && abs(CosTheta) > 0.15)

            xPos(kol) = x1;
            yPos(kol) = y1;
            kol = kol+1;

        else


        end  

    end

%if there are only 2 eyes
elseif row == 2
    xPos(1) = c(1,1);
    yPos(1) = c(1,2);
    xPos(2) = c(2,1);
    yPos(2) = c(2,2);
%there are 1 or less eyes, TODO.
else

end



corrVal = 0;
figure;imshow(eyeImg)

eyeImg = zeros(size(eyeImg));
r = 18;

eyeImg(yPos(1),xPos(1)) = 1;
eyeImg(yPos(2),xPos(2)) = 1;
eyeImg = imdilate(eyeImg,strel('disk', r,0) );

eyeImg = eyeImg>0.1;

figure;imshow(eyeImg)
