% Load the audio file
audio_file = '1.wav'; % Replace with your audio file
[audio, fs] = audioread(audio_file);

% Read the text file (to get the words)
text_file = '1.txt'; % Replace with your text file
fid = fopen(text_file, 'r');
text_data = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);
words = text_data{1}; % List of words in order

% Parameters
threshold = 0.12; % Set a suitable threshold (adjust based on your data)
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