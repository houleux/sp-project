load("E1.mat");

ts = 1/128;

HR = ECG_HRconverter(E1, ts);

time_minutes = 1:length(HR);

stem(time_minutes,HR);
sgtitle('HR for E1');
xlabel('time in minutes');
ylabel('heart rate in bpm');