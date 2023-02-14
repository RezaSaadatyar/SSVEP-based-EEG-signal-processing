% =========================== SSVEP (2023-2024) ============================
% ================== Presented by: Reza Saadatyar ==========================
% ================= E-mail: Reza.Saadatyar92@gmail.com =====================
clc;clear;close all
%% --------------------------------- Step 1: Load Data -------------------------------
Data=load('Data.mat'); 
X= Data.Data1(:,:,87);            % (number samples, number channel, number trials)
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
X_Filter= filtfilt(b,a,X);
X_Filter= filtfilt(b,a,X_Filter);
X_CAR= CAR_Filter(X_Filter);% CAR filter
%% ----------------------------- Step 3: PSDA Method --------------------------------
[Max_Freq, Label_predic]=PSDA_a_trial(fs, X_CAR(:,1),Num_Sample_Neigh,F_stim, Num_Harmonic);
