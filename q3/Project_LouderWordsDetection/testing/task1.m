 
text_file = '6.txt';
audio_file = '6.wav';

fid = fopen(text_file, 'r');
text_data = textscan(fid, '%s %f %f %f', 'Delimiter', '\t', 'MultipleDelimsAsOne', true);
fclose(fid);

[audio, fs] = audioread(audio_file);
 
figure;
plot((0:length(audio)-1)/fs, audio);
title('Audio Signal');
xlabel('Time (s)');
ylabel('Amplitude');
 
threshold = 0.12;
 
loud_words = {};
loud_audio = [];
rms_energy_values = [];  
 
for i = 1:length(text_data{1})
    word = text_data{1}{i};  
    start_time = text_data{2}(i);  
    end_time = text_data{3}(i);
    
    fprintf('Processing word %d: %s (Start: %.2f, End: %.2f)\n', i, word, start_time, end_time);
    
    start_sample = max(1, round(start_time * fs));
    end_sample = min(length(audio), round(end_time * fs));
    segment = audio(start_sample:end_sample);
 
    rms_energy = sqrt(mean(segment .^ 2));
    rms_energy_values = [rms_energy_values; rms_energy];  
    
    fprintf('Word: %s, RMS Energy: %.4f\n', word, rms_energy);
    
    if rms_energy > threshold
        loud_words{end + 1} = word; 
        loud_audio = [loud_audio; segment];  
    end
end
 
audiowrite('loud_words_task1.wav', loud_audio, fs);
 
disp('Loud Words:');
disp(loud_words);
 
figure;
bar(1:length(rms_energy_values), rms_energy_values, 'FaceColor', 'flat');
hold on;
 
for i = 1:length(rms_energy_values)
    if rms_energy_values(i) > threshold
        bar(i, rms_energy_values(i), 'FaceColor', [1, 0, 0]); 
    else
        bar(i, rms_energy_values(i), 'FaceColor', [0, 0, 1]);  
    end
end
yline(threshold, 'k--', 'Threshold', 'LineWidth', 1.5);  
 
xticks(1:length(text_data{1}));
xticklabels(text_data{1});
xtickangle(45);
xlabel('Words');
ylabel('RMS Energy');
title('Histogram of RMS Energy for Each Word');
legend({'Below Threshold', 'Above Threshold'}, 'Location', 'Best');

hold off;