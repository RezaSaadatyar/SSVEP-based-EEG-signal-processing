clc;clear;close all
%% 
Data=load('SSVEP.mat');
X= Data.data_L1_13Hz(:,1,1);   % (number samples, number channel, number trials)
fs=256;
%% filtering
order=4;
wn= [49.2 50.6]/(fs/2);
[b,a]= butter(order,wn,"stop");
X_Filter= filtfilt(b,a,X);
%% fourier transform
fft_X= fft(X);
m= numel(fft_X);
fft_X= abs(fft_X(1:floor(m/2)));

fft_X_Filter= fft(X_Filter);
fft_X_Filter= abs(fft_X_Filter(1:floor(m/2)));
f= linspace(0,fs/2,floor(m/2));

subplot(2,1,1)
plot(X,'linewidth',0.5); hold on
plot(X_Filter,'r','linewidth',0.5)
title('Freq stimulation=13Hz; OZ; Trial 1', FontSize=12,FontWeight='bold')
legend({'Raw signal','Filtered Signal'}, FontSize=10,FontWeight="bold")
subplot(2,1,2)
plot(f,fft_X,'linewidth',1); hold on
plot(f, fft_X_Filter,'LineWidth',1)
ylabel('PSD',FontSize=12,FontWeight='bold')
xlabel('F(Hz)',FontSize=12,FontWeight='bold')
