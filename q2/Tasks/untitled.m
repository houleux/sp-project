load("E2.mat");
load("E1.mat");

ts = 1/128;
f_s = 128;

N1 = length(E1);
N2 = length(E2);

f1 = (-N1/2:N1/2-1)*(f_s/N1);
f2 = (-N2/2:N2/2-1)*(f_s/N2);

fe1 = fftshift(abs(fft(E1)));
fe2 = fftshift(abs(fft(E2)));

subplot(2,1,1);
plot(f1,fe1);
subplot(2,1,2);
plot(f2,fe2);

Hd = lp;

filtered_E2 = filter(Hd, E2);

ffe2 = fftshift(abs(fft(filtered_E2)));

figure;
subplot(2,1,1);
plot(f1,fe1);
subplot(2,1,2);
plot(f2,ffe2);

%%

HR1 = ECG_HRconverter(filtered_E2, ts);

figure;
time_minutes = 1:length(HR1);
plot(time_minutes, HR1);
sgtitle('heart rate for E2');



