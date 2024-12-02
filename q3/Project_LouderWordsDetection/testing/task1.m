% Load the text and audio files
text_file = '6.txt';
audio_file = '6.wav';

fid = fopen(text_file, 'r');
text_data = textscan(fid, '%s %f %f %f', 'Delimiter', '\t', 'MultipleDelimsAsOne', true);
fclose(fid);

[audio, fs] = audioread(audio_file);

% Plot the audio signal
figure;
plot((0:length(audio)-1)/fs, audio);
title('Audio Signal');
xlabel('Time (s)');
ylabel('Amplitude');

% Threshold for loud words
threshold = 0.12;

% Initialize variables
loud_words = {};
loud_audio = [];
rms_energy_values = []; % Store RMS energy values for all words

% Process each word
for i = 1:length(text_data{1})
    word = text_data{1}{i};  
    start_time = text_data{2}(i);  
    end_time = text_data{3}(i);
    
    fprintf('Processing word %d: %s (Start: %.2f, End: %.2f)\n', i, word, start_time, end_time);
    
    % Get the corresponding segment of the audio
    start_sample = max(1, round(start_time * fs));
    end_sample = min(length(audio), round(end_time * fs));
    segment = audio(start_sample:end_sample);
    
    % Compute RMS energy of the segment
    rms_energy = sqrt(mean(segment .^ 2));
    rms_energy_values = [rms_energy_values; rms_energy]; % Store the RMS energy
    
    % Print word and its RMS energy
    fprintf('Word: %s, RMS Energy: %.4f\n', word, rms_energy);
    
    % Check if the word is loud
    if rms_energy > threshold
        loud_words{end + 1} = word; % Add word to loud words list
        loud_audio = [loud_audio; segment]; % Append loud audio segment
    end
end

% Save loud audio segments to a file
audiowrite('loud_words_task1.wav', loud_audio, fs);

% Display loud words
disp('Loud Words:');
disp(loud_words);

% Plot a histogram of RMS energy
figure;
bar(1:length(rms_energy_values), rms_energy_values, 'FaceColor', 'flat');
hold on;

% Highlight bars above the threshold
for i = 1:length(rms_energy_values)
    if rms_energy_values(i) > threshold
        bar(i, rms_energy_values(i), 'FaceColor', [1, 0, 0]); % Red for loud words
    else
        bar(i, rms_energy_values(i), 'FaceColor', [0, 0, 1]); % Blue for normal words
    end
end
yline(threshold, 'k--', 'Threshold', 'LineWidth', 1.5); % Add threshold line

% Label the histogram
xticks(1:length(text_data{1}));
xticklabels(text_data{1});
xtickangle(45);
xlabel('Words');
ylabel('RMS Energy');
title('Histogram of RMS Energy for Each Word');
legend({'Below Threshold', 'Above Threshold'}, 'Location', 'Best');

hold off;