% Task 2: Loud Words without Start and End Times

% Load the audio data
[audio, fs] = audioread('speech_sample.wav');

% Define parameters for short-time analysis
frame_length = 0.025; % 25 ms
frame_shift = 0.010; % 10 ms
frame_size = round(frame_length * fs);
frame_step = round(frame_shift * fs);

% Compute short-time energy
num_frames = floor((length(audio) - frame_size) / frame_step) + 1;
energy = zeros(1, num_frames);

for i = 1:num_frames
    start_idx = (i - 1) * frame_step + 1;
    end_idx = start_idx + frame_size - 1;
    if end_idx > length(audio)
        break;
    end
    frame = audio(start_idx:end_idx);
    energy(i) = sqrt(mean(frame.^2));
end

% Thresholding: Adaptive threshold based on mean energy
threshold = mean(energy) + std(energy);

% Identify loud frames
loud_frames = energy > threshold;

% Display loud segments (indices)
disp('Loud Frames Detected:');
disp(find(loud_frames));
