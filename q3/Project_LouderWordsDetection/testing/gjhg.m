
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

% Map words based on silent zones
loud_words = {};
for i = 1:length(start_indices) - 1
    % Get the segment indices
    start_idx = end_indices(i) * frame_step;
    end_idx = start_indices(i + 1) * frame_step;
    segment = audio(start_idx:end_idx);

    % Compute RMS energy for the segment
    segment_rms = sqrt(mean(segment.^2));
    
    % Classify as loud if RMS exceeds the loudness threshold
    loudness_threshold = 0.12; % Adjust this based on your data
    if segment_rms > loudness_threshold
        % Map the segment to a word
        word_index = ceil(i / length(start_indices) * length(words));
        loud_words{end+1} = words{word_index};
    end
end

% Print the detected loud words
disp('Loud Words Detected:');
disp(unique(loud_words));

% Plot RMS energy with silent and loud zones
figure;
plot((1:num_frames) * frame_step / fs, rms_energy, 'b', 'DisplayName', 'RMS Energy');
hold on;
yline(silence_threshold, 'r--', 'Silence Threshold', 'DisplayName', 'Silence Threshold');
yline(loudness_threshold, 'g--', 'Loudness Threshold', 'DisplayName', 'Loudness Threshold');
xlabel('Time (s)');
ylabel('RMS Energy');
title('RMS Energy with Silent and Loud Zones');
legend;
hold off;