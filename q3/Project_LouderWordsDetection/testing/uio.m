% Load the audio file
audio_file = '7.wav'; % Replace with your WAV audio file
[audio, fs] = audioread(audio_file);

% Read the text file (to get the words)
text_file = '7.txt'; % Replace with your text file
fid = fopen(text_file, 'r');
text_data = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);
words = text_data{1}; % List of words in order

% Parameters
frame_size = round(0.025 * fs); % Frame size of 25 ms
frame_step = round(0.010 * fs); % Frame step of 10 ms
time = (0:length(audio)-1) / fs; % Time vector for the signal

% Ensure the audio signal is mono
if size(audio, 2) > 1
    audio = mean(audio, 2); % Convert stereo to mono
end

% Calculate RMS energy in frames
num_frames = floor((length(audio) - frame_size) / frame_step) + 1;
rms_energy = zeros(num_frames, 1);
for i = 1:num_frames
    start_idx = (i - 1) * frame_step + 1;
    end_idx = min(start_idx + frame_size - 1, length(audio));
    frame = audio(start_idx:end_idx);
    rms_energy(i) = sqrt(mean(frame.^2));
end

% Detect silent zones (RMS below a threshold)
silence_threshold = 0.01; % Adjust this based on your data
silence_frames = rms_energy < silence_threshold;

% Find boundaries of silent zones
silent_boundaries = find(diff([0; silence_frames; 0]) ~= 0); % Add padding for start/end
start_indices = silent_boundaries(1:2:end); % Start of silent regions
end_indices = silent_boundaries(2:2:end); % End of silent regions

% Initialize variables for loudness analysis
loudness_threshold = 0.12; % Adjust this based on your data
word_rms = zeros(length(words), 1); % RMS energy for each word
loud_word_flags = zeros(length(words), 1); % Flag for loud words

% Map words to time and compute their loudness
for i = 1:length(start_indices) - 1
    % Get the segment indices
    start_idx = end_indices(i) * frame_step;
    end_idx = start_indices(i + 1) * frame_step;
    segment = audio(start_idx:end_idx);

    % Compute RMS energy for the segment
    segment_rms = sqrt(mean(segment.^2));
    word_rms(i) = segment_rms;
    
    % Check if the word is loud
    if segment_rms > loudness_threshold
        loud_word_flags(i) = 1;
    end
end

% Prepare histogram data
word_labels = words(1:length(word_rms)); % Trim to match detected words
bar_colors = arrayfun(@(x) 'r', loud_word_flags, 'UniformOutput', false); % Red for loud words
bar_colors(~loud_word_flags) = {'b'}; % Blue for non-loud words

% Plot the histogram
figure;
bar(word_rms, 'FaceColor', 'flat');
for i = 1:length(word_rms)
    if loud_word_flags(i)
        bar_color = [1 0 0]; % Red for loud words
    else
        bar_color = [0 0 1]; % Blue for non-loud words
    end
    set(gca.Children, 'CData', bar_color, 'CDataMapping', 'scaled');
end
xticks(1:length(word_labels));
xticklabels(word_labels);
xtickangle(45);
xlabel('Words');
ylabel('RMS Energy');
title('Histogram of Words and Loud Words');
legend({'Loud Words (Red)', 'Normal Words (Blue)'});