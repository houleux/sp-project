% Specify the file and audio signal
text_file = '7.txt';
audio_file = '7.mp3';
wav_file = '7.wav';

% Convert MP3 to WAV
[audio, fs] = audioread(audio_file);
audiowrite(wav_file, audio, fs);

 
fid = fopen(text_file, 'r');
text_data = textscan(fid, '%s %f %f %f', 'Delimiter', '\t', 'MultipleDelimsAsOne', true);
fclose(fid);
 
[audio, fs] = audioread(wav_file);

 
threshold = 0.11;
 
loud_words = {};
loud_audio = [];

 
for i = 1:length(text_data{1})
    word = text_data{1}{i};  
    start_time = text_data{2}(i); 
    end_time = text_data{3}(i); 
     
    fprintf('Processing word %d: %s (Start: %.2f, End: %.2f)\n', i, word, start_time, end_time);
    
   
    start_sample = max(1, round(start_time * fs));
    end_sample = min(length(audio), round(end_time * fs));
    
    
    segment = audio(start_sample:end_sample);
    
    rms_energy = sqrt(mean(segment .^ 2));
    
    % Debugging: Display RMS energy for the current word
    fprintf('Word: %s, RMS Energy: %.4f\n', word, rms_energy);
    
    % Check if the word is loud based on RMS threshold
    if rms_energy > threshold
       
        loud_words{end + 1} = word;
        
        sound(segment, fs);
    end
end

% % Save the loud words audio to a new .wav file
% audiowrite('loud_words_task1.wav', loud_audio, fs);

% Display results
disp('Loud Words:');
disp(loud_words);

% % Play the loud audio (optional for debugging)
% sound(loud_audio, fs);