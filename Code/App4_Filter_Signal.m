% =========================== SSVEP (2023-2024) ============================
% ================== Presented by: Reza Saadatyar ==========================
% ================= E-mail: Reza.Saadatyar92@gmail.com =====================
clc;clear;close all
%% --------------------------- Step 1: Load Data ----------------------------------
Data=load('Data.mat');
X= Data.Data1;   % (number samples, number channel, number trials)
fs=256;
%% ------------------ Step 2: Filtering all trials --------------------------------
wn= [49.2 50.6]/(fs/2);
[b,a]= butter(4,wn,"stop");
for i=1:size(X,3)
    X(:,:,i)= filtfilt(b,a,X(:,:,i));
end
%% ------------------- Step 3: Fourier transform for a channel --------------------
X_fft= fft(Data.Data1(:,1,1));
X_PSD= abs(X_fft(1:floor(length(X_fft)/2)));

fft_X_Filter= fft(X(:,1,1));
fft_X_Filter= abs(fft_X_Filter(1:floor(length(X_fft)/2)));
f= linspace(0,fs/2,floor(length(X_fft)/2));
%% ---------------------------- Step 4: Plot Result --------------------------------
figure(1)
subplot(2,1,1)
plot(Data.Data1(:,1,1),'linewidth',0.5); hold on
plot(X(:,1,1),'r','linewidth',0.5);xlim([0, length(X(:,1,1))])
title('Freq stimulation=13Hz; OZ; Trial 1', FontSize=10,FontWeight='bold')
legend({'Raw signal','Filtered Signal'}, FontSize=8,FontWeight="bold")
subplot(2,1,2)
plot(f,X_PSD,'linewidth',1); hold on
plot(f, fft_X_Filter,'LineWidth',1);xlim([0, f(end)])
ylabel('PSD',FontSize=10,FontWeight='bold')
xlabel('F(Hz)',FontSize=10,FontWeight='bold')
