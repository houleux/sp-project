load("E2.mat");
load("E1.mat");
load("E3.mat");

ts = 1/128;
f_s = 128;

N1 = length(E1);
N2 = length(E2);
N3 = length(E3);

f1 = (-N1/2:N1/2-1)*(f_s/N1);
f2 = (-N2/2:N2/2-1)*(f_s/N2);
f3 = (-N3/2:N3/2-1)*(f_s/N3);


fe1 = fftshift(abs(fft(E1)));
fe2 = fftshift(abs(fft(E2)));
fe3 = fftshift(abs(fft(E3)));

figure;
sgtitle('Fourier transforms of unfiltered ECG(s)');
subplot(3,1,1);
plot(f1,fe1);
title('E1');
xlabel('frequency (Hz)');
ylabel('abs(E_1(w))');

subplot(3,1,2);
plot(f2,fe2);
title('E2');
xlabel('frequency (Hz)');
ylabel('abs(E_2(w))');

subplot(3,1,3);
plot(f3,fe3);
title('E3');
xlabel('frequency (Hz)');
ylabel('abs(E_3(w))');

%% Applying lowpass filter

Hd = lp;

filtered_E2 = filter(Hd, E2);
filtered_E3 = filter(Hd, E3);

ffe2 = fftshift(abs(fft(filtered_E2)));
fffe3 = fftshift(abs(fft(filtered_E3)));

figure;
sgtitle('After using lowpass filter');
subplot(3,1,1);
plot(f1,fe1);
title('E1');
xlabel('frequency (Hz)');
ylabel('abs(E_1(w))');

subplot(3,1,2);
plot(f2,ffe2);
title('E2');
xlabel('frequency (Hz)');
ylabel('abs(E_2(w))');

subplot(3,1,3);
plot(f3,fffe3);
title('E3');
xlabel('frequency (Hz)');
ylabel('abs(E_3(w))');

%% Applying Notch filter

hd2 = notc;

Sfiltered_E3 = filter(hd2,filtered_E3);

fffe3 = fftshift(abs(fft(Sfiltered_E3)));
 

figure;
sgtitle('After using notch filter');
subplot(3,1,1)
plot(f1,fe1);
title('E1');
xlabel('frequency (Hz)');
ylabel('abs(E_1(w))');

subplot(3,1,2)
plot(f2,ffe2);
title('E2');
xlabel('frequency (Hz)');
ylabel('abs(E_2(w))');

subplot(3,1,3);
plot(f3,fffe3);
title('E3');
xlabel('frequency (Hz)');
ylabel('abs(E_3(w))');

%% Calculating HR

HR2 = ECG_HRconverter(filtered_E2, ts);
HR3 = ECG_HRconverter(Sfiltered_E3, ts);

time_minutes2 = 1:length(HR2);
time_minutes3 = 1:length(HR3);
 
figure;
sgtitle('HeatRates of E2 and E3');

subplot(2,1,1);
stem(time_minutes2,HR2);
xlabel('time (mins)');
ylabel('heart rate (bpm)');
title('E2');

subplot(2,1,2);
stem(time_minutes3,HR3);
xlabel('time (mins)');
ylabel('heart rate (bpm)');
title('E3');


