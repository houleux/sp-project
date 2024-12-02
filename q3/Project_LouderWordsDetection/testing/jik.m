% Read the audio signal
[audioSignal, fs] = audioread('8.wav');

% Convert stereo to mono if necessary
if size(audioSignal, 2) > 1
    audioSignal = mean(audioSignal, 2);  % Averaging channels for mono
end

% Read the word data from the text file
fileID = fopen('8.txt', 'r');
wordData = textscan(fileID, '%s %f %f %d', 'Delimiter', ' \t', 'MultipleDelimsAsOne', true);
fclose(fileID);

words = wordData{1};  % Extract the words

% Define parameters for windowing
windowDuration = 0.025;  % 25 ms window
windowSamples = round(windowDuration * fs);  % Window length in samples
hopLength = round(windowSamples / 2);  % 50% overlap for hop length

% Calculate the energy for each window
numWindows = ceil(length(audioSignal) / hopLength);
windowEnergy = zeros(1, numWindows);

for i = 1:numWindows
    startIdx = (i - 1) * hopLength + 1;
    endIdx = min(startIdx + windowSamples - 1, length(audioSignal));
    audioWindow = audioSignal(startIdx:endIdx);
    windowEnergy(i) = sum(audioWindow.^2);  % Sum of squares (energy)
end

% Normalize the energy values
windowEnergy = windowEnergy / max(windowEnergy);

% Energy threshold to detect speech regions
energyThreshold = 0.05;
speechRegionFlags = windowEnergy > energyThreshold;

% Detect start and end of speech segments
speechChanges = find(diff([0, speechRegionFlags, 0]) ~= 0);
speechSegments = reshape(speechChanges, 2, [])';  % Pair start and end indices
speechSegments = speechSegments * hopLength;  % Convert to sample indices

% Initialize arrays for RMS and loudness
numSpeechSegments = size(speechSegments, 1);
rmsValues = zeros(1, numSpeechSegments);
loudnessFlags = zeros(1, numSpeechSegments);

% Adjust the number of speech segments to match the number of words
numWords = length(words);
if numSpeechSegments > numWords
    speechSegments = speechSegments(1:numWords, :);
elseif numSpeechSegments < numWords
    speechSegments = [speechSegments; zeros(numWords - numSpeechSegments, 2)];
end

% RMS threshold to classify loud words
rmsThreshold = 0.12;

% Calculate RMS energy for each speech segment and classify loudness
for i = 1:numSpeechSegments
    startIdx = speechSegments(i, 1);
    endIdx = speechSegments(i, 2);
    
    % Ensure indices are within bounds of audioSignal
    if startIdx > 0 && endIdx <= length(audioSignal)
        segment = audioSignal(startIdx:endIdx);
        rmsEnergy = sqrt(mean(segment.^2));  % RMS energy for the segment
        rmsValues(i) = rmsEnergy;

        % Classify as loud or normal based on RMS threshold
        if rmsEnergy > rmsThreshold
            loudnessFlags(i) = 1;  % Loud word
        else
            loudnessFlags(i) = 0;  % Normal word
        end
    elseif startIdx > length(audioSignal)
        % If start index is out of bounds, skip this segment
        fprintf('Warning: Segment %d has a start index beyond the signal length.\n', i);
        continue;
    elseif endIdx > length(audioSignal)
        % If end index is out of bounds, clip it to the end of the signal
        segment = audioSignal(startIdx:end);  % From start to end of signal
        rmsEnergy = sqrt(mean(segment.^2));  % RMS energy for the segment
        rmsValues(i) = rmsEnergy;

        % Classify as loud or normal based on RMS threshold
        if rmsEnergy > rmsThreshold
            loudnessFlags(i) = 1;  % Loud word
        else
            loudnessFlags(i) = 0;  % Normal word
        end
    end
end

% Ensure the number of RMS values matches the number of words
rmsValues = rmsValues(1:numWords);

% Display the results in a table format
fprintf("Word       | RMS Energy        | Loudness\n");
fprintf("--------------------------------------------\n");
for i = 1:numWords
    fprintf("%-10s | %-16f | %d\n", words{i}, rmsValues(i), loudnessFlags(i));
end
disp("--------------------------------------------");

% Plot 1: Bar chart of RMS energy for each word
figure;
bar(rmsValues, 'FaceColor', 'blue');
hold on;

% Highlight loud words in red
for i = 1:numWords
    if rmsValues(i) > rmsThreshold
        bar(i, rmsValues(i), 'FaceColor', 'red');
    end
end

% Add a threshold line to the plot
yline(rmsThreshold, 'r--', 'LineWidth', 2, 'Label', 'Threshold');
title('RMS Energy of Words');
xlabel('Words');
ylabel('RMS Energy');
xticks(1:numWords);
xticklabels(words);
xtickangle(45);  % Rotate x-axis labels for readability
legend('Normal Words', 'Loud Words (> Threshold)', 'Threshold', 'Location', 'northwest');
hold off;

% Plot 2: Energy envelope of the entire audio signal
figure;
plot(windowEnergy, 'b');
hold on;
yline(energyThreshold, 'r--', 'LineWidth', 2, 'Label', 'Energy Threshold');
title('Energy Envelope');
xlabel('Time Windows');
ylabel('Normalized Energy');
legend('Energy', 'Threshold');
hold off;
