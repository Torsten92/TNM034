function [ result ] = tnm034( im )

% result is in the range 0-1. Tröskla result and return 1 if low enough.
% 
% 

result = 1;
[skinCorr, mouthCorr, eyeCorr, triCorr, noseCorr] = faceDetect(image);

for i = 1:antalbiler
    [DBskinCorr, DBmouthCorr, DBeyeCorr, DBtriCorr, DBnoseCorr] = faceDetect(DBimage(i));
    temp = abs(DBskinCorr-skinCorr) + abs(DBmouthCorr-mouthCorr) + ...
        if temp < result
            result = temp;
        end
end

return result < 0.1;

end