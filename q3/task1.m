% Task 1: Loud Words with Start and End Times

% Load the audio and text data
[audio, fs] = audioread('speech_sample.wav');
text_data = readtable('word_info.txt', 'Delimiter', '\t', 'ReadVariableNames', true);

% Initialize results
loud_words = {};

for i = 1:height(text_data)
    % Extract start and end times (in seconds)
    start_time = text_data.start_time(i);
    end_time = text_data.end_time(i);
    is_loud = text_data.loudness_flag(i);
    
    % Convert to sample indices
    start_sample = floor(start_time * fs) + 1;
    end_sample = floor(end_time * fs);
    
    % Segment the audio
    segment = audio(start_sample:end_sample);
    
    % Calculate RMS energy
    rms_energy = sqrt(mean(segment.^2));
    
    % Store loud words
    if is_loud == 1
        loud_words{end+1} = text_data.word{i}; %#ok<AGROW>
    end
end

% Display results
disp('Loud Words:');
disp(loud_words);
