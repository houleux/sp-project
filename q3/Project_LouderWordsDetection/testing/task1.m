 
text_file = '2.txt';
audio_file = '2.wav';
 
fid = fopen(text_file, 'r');
text_data = textscan(fid, '%s %f %f %f', 'Delimiter', '\t', 'MultipleDelimsAsOne', true);
fclose(fid);
 
 
[audio, fs] = audioread(audio_file);
 %plot audio signal
figure;
plot(audio);
title('Audio Signal');
xlabel('Sample');
ylabel('Amplitude'); 

threshold = 0.12;
 
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
    
     
    fprintf('Word: %s, RMS Energy: %.4f\n', word, rms_energy);
    
    
    if rms_energy > threshold
       
        loud_words{end + 1} = word;
        
        loud_audio = [loud_audio; segment];
    end
end
 
audiowrite('loud_words_task1.wav', loud_audio, fs);
 
disp('Loud Words:');
disp(loud_words);

 
% sound(loud_audio, fs);
