% =========================== SSVEP (2023-2024) ============================
% ================== Presented by: Reza Saadatyar ==========================
% ================= E-mail: Reza.Saadatyar92@gmail.com =====================
clc;clear;close all
%% ----------------------------- Step 1: Load Data -----------------------------
Data=load('Data.mat');

Fs=256;
Time = (0:size(Data.Data1,1)-1)*1/Fs;                                        % Time vector
%% -------------------------- Step 2: Filtering all trials ---------------------
wn= [49.2 50.6]/(Fs/2);
[b,a]= butter(4,wn,"stop");

X_CAR = zeros(size(Data.Data1,1),size(Data.Data1,2),size(Data.Data1,3));  % (number samples, number channel, number trials)
for i=1:size(Data.Data1,3)
    X_Filter= filtfilt(b,a,Data.Data1(:,:,i));
    X_CAR(:,:,i)= CAR_Filter(X_Filter);                                   % CAR filter
end
%% --------------------------- Step 3: Plot Results ----------------------------
figure()
subplot(2,1,1)
plot(Time,Data.Data1(:,1,1),'linewidth',0.5)
title('Freq stimulation=13Hz; OZ; Trial 1', FontSize=10,FontWeight='bold')
legend({'Raw signal'}, FontSize=8,FontWeight="bold")
subplot(2,1,2)
plot(Time,X_CAR(:,1,1),'linewidth',0.5)
legend({'Filter CAR'}, FontSize=8,FontWeight="bold")
xlabel('Time(sec)',FontSize=10,FontWeight="bold")

