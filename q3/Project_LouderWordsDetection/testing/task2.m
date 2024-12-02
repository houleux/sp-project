[audioSignal, fs] = audioread('9.wav');

if size(audioSignal, 2) > 1
    audioSignal = mean(audioSignal, 2);  
end

fileID = fopen('9.txt', 'r');
data = textscan(fileID, '%s %f %f %d', 'Delimiter', ' \t', 'MultipleDelimsAsOne', true);
fclose(fileID);

words = data{1}; 


window_duration = 0.025;
window_samples = round(window_duration * fs);
hop_length = round(window_samples / 2); 

energy = zeros(1, ceil(length(audioSignal) / hop_length));
for i = 1:length(energy)
    start_idx = 1 + (i-1) * hop_length;
    end_idx = min(start_idx + window_samples - 1, length(audioSignal));
    
    window = audioSignal(start_idx:end_idx);
    energy(i) = sum(window.^2);
end

energy = energy / max(energy); 
% energy = movmean(energy,10);

energy_threshold = 0.01;  
speech_regions = energy > energy_threshold;

speech_segments = find(diff([0, speech_regions, 0]) ~= 0);
speech_segments = reshape(speech_segments, 2, [])';
speech_segments = speech_segments * hop_length;

rms = zeros(1, size(speech_segments, 1));
loudness = zeros(1, size(speech_segments, 1));

if size(speech_segments, 1) > length(words)
    speech_segments = speech_segments(1:length(words), :);
elseif size(speech_segments, 1) < length(words)
    speech_segments = [speech_segments; zeros(length(words) - size(speech_segments, 1), 2)];
end

rms_threshold = 0.12;  

for i = 1:size(speech_segments, 1)
    if speech_segments(i, 1) > 0 && speech_segments(i, 2) <= length(audioSignal)
        segment = audioSignal(speech_segments(i, 1):speech_segments(i, 2));
        
        rms_energy = sqrt(mean(segment.^2));
        rms(i) = rms_energy;
        
        if rms_energy > rms_threshold
            loudness(i) = 1; % Loud word
        else
            loudness(i) = 0; % Normal word
        end
    end
end

rms = rms(1:length(words));

fprintf("Word       | Energy (RMS)     | Loudness\n");
fprintf("--------------------------------------------\n");
for i = 1:length(words)
    fprintf("%-10s | %-16f | %d\n", words{i}, rms(i), loudness(i));
end
disp("--------------------------------------------")

figure;
bar(rms, 'FaceColor', 'blue');
hold on;
for i = 1:length(rms)
    if rms(i) > rms_threshold
        bar(i, rms(i), 'FaceColor', 'red');
    end
end
yline(rms_threshold, 'r--', 'LineWidth', 2, 'Label', 'Threshold');
title('RMS Energy of Words in 9.mp3');
xlabel('Words');
ylabel('RMS Energy');
xticks(1:length(words));
xticklabels(words);
xtickangle(45); 
legend('Normal Words', 'Loud Words (> Threshold)', 'Threshold', 'Location', 'northwest');
hold off;

% Plot the energy envelope
figure;
plot(energy);
hold on;
yline(energy_threshold, 'r--', 'LineWidth', 2, 'Label', 'Energy Threshold');
title('Energy Envelope');
xlabel('Time Windows');
ylabel('Normalized Energy');
legend('Energy', 'Threshold');
hold off;