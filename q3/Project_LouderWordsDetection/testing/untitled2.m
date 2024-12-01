% Load the audio file
audio_file = '3.wav'; % Replace with your WAV audio file
[audio, fs] = audioread(audio_file);

% Read the text file (to get the words)
text_file = '3.txt'; % Replace with your text file
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
silence_threshold = 0.041; % Adjust this based on your data
silence_frames = rms_energy < silence_threshold;

% Find boundaries of silent zones
silent_boundaries = find(diff([0; silence_frames; 0]) ~= 0); % Add padding for start/end
start_indices = silent_boundaries(1:2:end); % Start of silent regions
end_indices = silent_boundaries(2:2:end); % End of silent regions

% Map words based on silent zones
loud_words = {};
for i = 1:length(start_indices) - 1
    start_idx = end_indices(i); % End of current silent region
    end_idx = start_indices(i + 1); % Start of next silent region
    segment_rms = mean(rms_energy(start_idx:end_idx)); % Average RMS in this segment
    
    % Classify as loud if above a threshold
    if segment_rms > silence_threshold
        % Map segment to word
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
yline(silence_threshold, 'r--', 'Threshold', 'DisplayName', 'Silence Threshold');
for i = 1:length(start_indices)
    x = [start_indices(i) * frame_step / fs, end_indices(i) * frame_step / fs];
    y = [silence_threshold, silence_threshold];
    area(x, y, 'FaceColor', 'g', 'FaceAlpha', 0.2, 'EdgeColor', 'none', 'DisplayName', 'Silent Zone');
end
xlabel('Time (s)');
ylabel('RMS Energy');
title('RMS Energy with Silent and Loud Zones');
legend;
hold off;