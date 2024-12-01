f1 = audioread("F1.wav");
f2 = audioread("F2.wav");
f3 = audioread("F3.wav");
f4 = audioread("F4.wav");
f5 = audioread("F5.wav");
f6 = audioread("F6.wav");
f7 = audioread("F7.wav");
f8 = audioread("F8.wav");

fs = 1000; 
files = {f1, f2, f3, f4, f5, f6, f7, f8};
threshold = 0.2;

for i = 1:8
    y = files{i};
    Y = abs(fft(y));
    Y = Y(1:floor(length(Y)/2)); 
    Y = Y / max(Y);
    f = (0:length(Y)-1) * fs / (2*length(Y));
    [peaks, ~] = findpeaks(Y, 'MinPeakHeight', threshold);
    numPeaks = numel(peaks);

    if numPeaks >= 0 && numPeaks <= 130
        birdType = "Bird3";
    elseif numPeaks > 130 && numPeaks <= 400
        birdType = "Bird1";
    else
        birdType = "Bird2";
    end

    fprintf('F%d Peaks Above Threshold %.2f: %d Predicted Bird: %s\n', i, threshold, numPeaks, birdType);
end
