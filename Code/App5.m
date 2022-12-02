clc;clear;close all
%%
Data=load('SSVEP.mat');
X= Data.data_L1_13Hz(:,:,87);   % (number samples, number channel, number trials)
fs=256;
%% Applying filtering to first trial
wn= [49.2 50.6]/(fs/2);
[b,a]= butter(4,wn,"stop");
X_Filter= filtfilt(b,a,X);
Mean= mean(X_Filter,2);    % CAR filter
for j=1:size(X_Filter,2)
    X_Filter(:,j)=X_Filter(:,j)-Mean;
end
%% PSDA
f_stim(1)= 13;
f_stim(2)= 21;
f_stim(3)= 17;
Xi= X_Filter(:,1);
m= size(Xi,1);
fx= fft(Xi,m);
fx= fx(1:floor(m/2)+1);
PSD= abs(fx).^2;
rf= linspace(0,fs/2,floor(m/2)+1);
figure
plot(rf(2:end), PSD(2:end),'linewidth',2)
%%
n=20;
[Max_Freq, Label]=PSDA_1(fs, PSD,n,f_stim,m);
legend({'','F:13','F:21','F:17'},FontSize=10,FontWeight="bold")
title('Freq stimulation:13Hz; Trial:87; PSDA method','FontSize',12,'FontWeight','bold')