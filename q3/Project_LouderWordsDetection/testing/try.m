% Load the audio file
audio_file = '6.wav'; % Replace with your audio file
[audio, fs] = audioread(audio_file);

% Read the text file (to get the words)
text_file = '6.txt'; % Replace with your text file
fid = fopen(text_file, 'r');
text_data = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);
words = text_data{1}; % List of words in order

% Parameters
threshold = 0.1; % Set a suitable threshold (adjust based on your data)
frame_size = round(0.025 * fs); % Frame size of 25 ms
frame_step = round(0.010 * fs); % Frame step of 10 ms
time = (0:length(audio)-1) / fs; % Time vector for the signal

% Square the signal
squared_signal = audio.^2;

% Smooth the signal using Sinc interpolation
smoothing_window = 200; % Define window size for smoothing
sinc_filter = sinc(linspace(-4, 4, smoothing_window)); % Create a sinc filter
sinc_filter = sinc_filter / sum(sinc_filter); % Normalize the filter

% Apply smoothing to the squared signal
smoothed_signal = conv(squared_signal, sinc_filter, 'same');

% Filter the smoothed signal based on the threshold
loud_regions = smoothed_signal > threshold;

% Initialize time stamps array for loud segments
timestamps = [];

% Detect continuous loud regions
is_loud = false;
for i = 1:length(loud_regions)
    if loud_regions(i) && ~is_loud
        % Start of a loud region
        is_loud = true;
        start_time = time(i);
    elseif ~loud_regions(i) && is_loud
        % End of a loud region
        is_loud = false;
        end_time = time(i);
        timestamps = [timestamps; start_time, end_time]; % Add time stamps
    end
end

% Add any ongoing loud region at the end
if is_loud
    timestamps = [timestamps; start_time, time(end)];
end

% Print the time stamps for loud segments
disp('Time Stamps of Loud Segments:');
disp(timestamps);

% % Map the detected loud segments to words (approximation)
% num_words = length(words);
% word_duration = time(end) / num_words; % Approx. duration of each word
% detected_loud_words = {};

% for i = 1:size(timestamps, 1)
%     % Calculate approximate word indices
%     start_word_idx = max(1, ceil(timestamps(i, 1) / word_duration));
%     end_word_idx = min(num_words, ceil(timestamps(i, 2) / word_duration));
%     detected_loud_words = [detected_loud_words; words(start_word_idx:end_word_idx)];
% end

% % Display detected loud words
% disp('Detected Loud Words:');
% disp(unique(detected_loud_words));

% Plot the squared and smoothed signals along with the threshold
figure;
plot(time, squared_signal, 'b', 'DisplayName', 'Squared Signal');
hold on;
plot(time, smoothed_signal, 'g', 'DisplayName', 'Smoothed Signal');
yline(threshold, 'r--', 'Threshold', 'DisplayName', 'Threshold');
xlabel('Time (s)');
ylabel('Signal Amplitude');
title('Squared and Smoothed Signal with Threshold');
legend;
hold off;
