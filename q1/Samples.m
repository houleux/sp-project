y1 = audioread("bird1.wav");
y2 = audioread("bird2.wav");
y3 = audioread("bird3.wav");

fs = 1000; 
threshold = 0.2;

birdFiles = {y1, y2, y3};
birdNames = {"Bird1", "Bird2", "Bird3"};

for i = 1:3
    y = birdFiles{i};
    Y = abs(fft(y));
    Y = Y(1:floor(length(Y)/2)); 
    Y_normalized = Y / max(Y);  

    [peaks, ~] = findpeaks(Y_normalized, 'MinPeakHeight', threshold);
    numPeaksAboveThreshold = numel(peaks);

    fprintf('%s Peaks Above Threshold %.2f: %d\n', birdNames{i}, threshold, numPeaksAboveThreshold);
end
