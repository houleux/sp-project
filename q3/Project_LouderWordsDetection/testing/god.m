% Task-2 Audio Segmentation and Loud Word Detection with Histogram

[audioSignal, fs] = audioread('9.wav');

% Convert stereo to mono if needed
if size(audioSignal, 2) > 1
    audioSignal = mean(audioSignal, 2);  
end

% Load the words from the text file
fileID = fopen('9.txt', 'r');
data = textscan(fileID, '%s %f %f %d', 'Delimiter', ' \t', 'MultipleDelimsAsOne', true);
fclose(fileID);

words = data{1}; % List of words

% Parameters
window_duration = 0.025; % 25 ms window
window_samples = round(window_duration * fs);
hop_length = round(window_samples / 2); % 50% overlap

% Calculate energy for each window
energy = zeros(1, ceil(length(audioSignal) / hop_length));
for i = 1:length(energy)
    start_idx = 1 + (i-1) * hop_length;
    end_idx = min(start_idx + window_samples - 1, length(audioSignal));
    
    window = audioSignal(start_idx:end_idx);
    energy(i) = sum(window.^2);
end

% Normalize the energy
energy = energy / max(energy);
% energy = movmean(energy,10);

% Energy threshold to detect speech regions
energy_threshold = 0.01;  
speech_regions = energy > energy_threshold;

% Detect start and end of speech regions
speech_segments = find(diff([0, speech_regions, 0]) ~= 0);
speech_segments = reshape(speech_segments, 2, [])';
speech_segments = speech_segments * hop_length;

% Initialize RMS and loudness arrays
rms = zeros(1, size(speech_segments, 1));
loudness = zeros(1, size(speech_segments, 1));

% Match the number of segments to words if needed
if size(speech_segments, 1) > length(words)
    speech_segments = speech_segments(1:length(words), :);
elseif size(speech_segments, 1) < length(words)
    speech_segments = [speech_segments; zeros(length(words) - size(speech_segments, 1), 2)];
end

% RMS energy threshold for loudness detection
rms_threshold = 0.12;  

% Calculate RMS energy for each segment
for i = 1:size(speech_segments, 1)
    if speech_segments(i, 1) > 0 && speech_segments(i, 2) <= length(audioSignal)
        segment = audioSignal(speech_segments(i, 1):speech_segments(i, 2));
        
        rms_energy = sqrt(mean(segment.^2));
        rms(i) = rms_energy;
        
        if rms_energy > rms_threshold
            loudness(i) = 1; % Loud word
        else
            loudness(i) = 0; % Normal word
        end
    end
end

% Ensure RMS array length matches words for plotting
rms = rms(1:length(words));

% Print the results
fprintf("Word       | Energy (RMS)     | Loudness\n");
fprintf("--------------------------------------------\n");
for i = 1:length(words)
    fprintf("%-10s | %-16f | %d\n", words{i}, rms(i), loudness(i));
end
disp("--------------------------------------------")

% Plot histogram of RMS energy with word labels
figure;
bar(rms, 'FaceColor', 'blue'); % Normal words
hold on;
for i = 1:length(rms)
    if rms(i) > rms_threshold
        bar(i, rms(i), 'FaceColor', 'red'); % Loud words
    end
end
yline(rms_threshold, 'r--', 'LineWidth', 2, 'Label', 'Threshold');
title('RMS Energy of Words in 9.mp3');
xlabel('Words');
ylabel('RMS Energy');
xticks(1:length(words));
xticklabels(words);
xtickangle(45); % Rotate x-axis labels for readability
legend('Normal Words', 'Loud Words (> Threshold)', 'Threshold', 'Location', 'northwest');
hold off;

% Plot the energy envelope
figure;
plot(energy);
hold on;
yline(energy_threshold, 'r--', 'LineWidth', 2, 'Label', 'Energy Threshold');
title('Energy Envelope');
xlabel('Time Windows');
ylabel('Normalized Energy');
legend('Energy', 'Threshold');
hold off;