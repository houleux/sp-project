audio_file = '3.wav';
[audio, fs] = audioread(audio_file);

% Read text file with word timestamps and loudness
text_file = '3.txt';
f = fopen(text_file, 'r');
data = textscan(f, '%s %f %f %d', 'Delimiter', '\t');
fclose(f);

% Extract words, start times, end times, and loudness flags
words = data{1};
start_times = data{2};
end_times = data{3};
loud_flags = data{4};

% Time and signal processing
time = (0:length(audio)-1) / fs;
squared_signal = audio.^2;

% Smoothing
smoothing_window = 200;
sinc_filter = sinc(linspace(-4, 4, smoothing_window));
sinc_filter = sinc_filter / sum(sinc_filter);
smoothed_signal = conv(squared_signal, sinc_filter, 'same');

% Threshold for loud regions
threshold = 0.12;
loud_regions = smoothed_signal > threshold;

% Find words with loudness flag 1
loud_words = {};
loud_word_limits = [];

disp('Original Word Boundaries from Text File:');
for i = 1:length(words)
    fprintf('%s: %.4f - %.4f (Loud Flag: %d)\n', words{i}, start_times(i), end_times(i), loud_flags(i));
end
disp(' ');

for i = 1:length(words)
    % Safely convert time to indices
    word_start_idx = max(1, min(round(start_times(i) * fs), length(loud_regions)));
    word_end_idx = max(1, min(round(end_times(i) * fs), length(loud_regions)));
    
    % If the loud flag is 1 or if there are loud samples in the word's time segment
    if loud_flags(i) == 1 || any(loud_regions(word_start_idx:word_end_idx))
        loud_words{end+1} = words{i};
        loud_word_limits = [loud_word_limits; start_times(i), end_times(i)];
    end
end

% Print loud words with their time limits
disp('Loud Words with Time Limits:');
for i = 1:length(loud_words)
    fprintf('%s: %.4f - %.4f\n', loud_words{i}, loud_word_limits(i,1), loud_word_limits(i,2));
end

% Visualization
figure('Position', [100, 100, 1200, 600]);

% Subplot for squared and smoothed signal

plot(time, squared_signal, 'b', 'DisplayName', 'Squared Signal');
hold on;
% plot(time, smoothed_signal, 'g', 'DisplayName', 'Smoothed Signal');
yline(threshold, 'r--', 'Threshold', 'DisplayName', 'Threshold');

% Mark word boundaries with vertical lines
for i = 1:length(start_times)
        % Blue for non-loud words
        line([start_times(i) start_times(i)], ylim, 'Color', 'b', 'LineStyle', '--', 'DisplayName', 'Word Start');
        line([end_times(i) end_times(i)], ylim, 'Color', 'b', 'LineStyle', '--', 'DisplayName', 'Word End');
  
end

xlabel('Time (s)');
ylabel('Signal Amplitude');
title('Squared and Smoothed Signal with Word Boundaries');
hold off;


% Annotate word boundaries
for i = 1:length(words)
    
        color = 'b';
    
    % Start of word
    line([start_times(i) start_times(i)], ylim, 'Color', color, 'LineStyle', '--');
    % End of word
    line([end_times(i) end_times(i)], ylim, 'Color', color, 'LineStyle', '--');
    
    % Add word labels
    text(start_times(i), max(smoothed_signal)/2, words{i}, 'Rotation', 90, 'Color', color, 'FontSize', 8);
end