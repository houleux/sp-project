 % Specify the file and audio signal
text_file = '6.txt';
audio_file = '6.wav';

% Read the data from the text file
fid = fopen(text_file, 'r');
text_data = textscan(fid, '%s %f %f %f', 'Delimiter', '\t', 'MultipleDelimsAsOne', true);
fclose(fid);
 
% Load the audio data
[audio, fs] = audioread(audio_file);

% Parameters for RMS calculation
frame_size = round(0.025 * fs); % 25 ms frame
frame_step = round(0.010 * fs); % 10 ms step
num_frames = floor((length(audio) - frame_size) / frame_step) + 1;

% Threshold for loudness (this value can be adjusted based on your data)
threshold = 0.20;

% Initialize results
loud_words = {};
loud_audio = [];
word_index = 1;

% Compute RMS energy for each frame
for i = 1:num_frames
    start_idx = (i - 1) * frame_step + 1;
    end_idx = min(start_idx + frame_size - 1, length(audio));
    frame = audio(start_idx:end_idx);
    
    % Calculate RMS energy
    rms_energy = sqrt(mean(frame.^2));
    % Find the corresponding word
    while word_index <= length(text_data{1}) && text_data{3}(word_index) < (start_idx - 1) / fs
        word_index = word_index + 1;
    end
   %% print the word and its RMS energy
    % fprintf('Word: %s, RMS Energy: %.4f\n', text_data{1}{word_index}, rms_energy);
    % If the RMS energy exceeds the threshold, classify as loud
    if rms_energy > threshold
        % Concatenate loud audio segments
        loud_audio = [loud_audio; frame];
        % Add the loud word to the list
        loud_words{end + 1} = text_data{1}{word_index};

    end
end
 
% print a single loud word one time only delete its copies
loud_words = unique(loud_words);
disp('Loud Words:');
disp(loud_words);

% Play the loud audio
sound(loud_audio, fs);
 