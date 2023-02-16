% =========================== SSVEP (2023-2024) ============================
% ================== Presented by: Reza Saadatyar ==========================
% ================= E-mail: Reza.Saadatyar92@gmail.com =====================
clc;clear;close all;
%% --------------------------------- Step 1: Load Data -------------------------------
Data=load('Data.mat');             
X_Filter=Data.Data1(:,:,1);                         % (number samples, number channel, number trials)
%% --------------------------------- Parameters --------------------------------------
fs= 256;                                            % Sampling frequency  
Duration_trial= 5;                                  % Length of trials 
Num_Channel= 1:3;                                   % Number of Channel
Num_Harmonic = 2;                                   % Number of harmonic for each frequency stimulation
F_stim= [13 21 17];                                 % Freqquencies stimuation
Num_samples_trial = fs*Duration_trial;              % Fs*time each trial
Time= linspace(0,Duration_trial,Num_samples_trial); % Time vector
%% ------------------------------ Step 2: Filtering ----------------------------------
wn= [49.2 50.6]/(fs/2);
[b,a]= butter(3,wn,"stop");
[b1,a1]= butter(3,(min(F_stim)-1)/(fs/2), 'high');
X_Filter= filtfilt(b,a,X_Filter);
X_Filter= filtfilt(b1,a1,X_Filter);
X_CAR=CAR_Filter(X_Filter);                   % CAR filter 
%% ------------------------------ Step 3: CCA Method ---------------------------------
F_Ref = zeros(length(F_stim),1);

for i=1:length(F_stim)                        % First loop for frequencies stimulation
    Data_Ref = [];
    for j=1:Num_Harmonic                      % Second loop creates a reference signal for each frequency stimulation
        Signal_Ref(:,1) = sin(2*pi*(j*F_stim(i))*Time);
        Signal_Ref(:,2) = cos(2*pi*(j*F_stim(i))*Time);
        Data_Ref = [Data_Ref, Signal_Ref]; %#ok
    end
    [~,~,a]=canoncorr(X_CAR(:,Num_Channel),Data_Ref);
    F_Ref(i) = max(a);
end
[~,Label_predic]= max(F_Ref);




