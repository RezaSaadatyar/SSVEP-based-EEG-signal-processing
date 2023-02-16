% =========================== SSVEP (2023-2024) ============================
% ================== Presented by: Reza Saadatyar ==========================
% ================= E-mail: Reza.Saadatyar92@gmail.com =====================
clc;clear;close all;
%% --------------------------------- Step 1: Load Data -------------------------------
Data=load('Data.mat');             % (number samples, number channel, number trials)
label= [ones(1,size(Data.Data1,3)), 2*ones(1,size(Data.Data2,3)),3*ones(1,size(Data.Data3,3))];
DataTotal = cat(3,Data.Data1, Data.Data2, Data.Data3);
%% --------------------------------- Parameters --------------------------------------
fs= 256;                        % Sampling frequency  
Duration_trial= 5;              % Length of trials 
Num_Channel= 1:3;               % Number of Channel
Num_Harmonic = 2;               % Number of harmonic for each frequency stimulation
F_stim= [13 21 17];             % Freqquencies stimuation
Num_Sample_Neigh=20;            % Number of samples neighborhood for each frequency stimulation
%% ------------------------------ Step 2: Filtering ----------------------------------
wn= [49.2 50.6]/(fs/2);
[b,a]= butter(4,wn,"stop");
[b1,a1]= butter(3,(min(F_stim)-1)/(fs/2), 'high');
%% ----------------------------- Step 3: PSDA Method ---------------------------------
Label_predic=zeros(1,size(DataTotal,3));
for i=1:size(DataTotal,3)
    X= DataTotal(:,:,i);
    X_Filter= filtfilt(b,a,X);
    X_Filter= filtfilt(b1,a1,X_Filter);
    X_CAR= CAR_Filter(X_Filter); % CAR filter
    PSDA=PSDA_all_trial(X_CAR(:,Num_Channel),F_stim,Num_Sample_Neigh,fs,Num_Harmonic);
    [~,Label_predic(i)]= max(PSDA);
end
Accuracy = sum(label-Label_predic==0)/length(Label_predic)*100


