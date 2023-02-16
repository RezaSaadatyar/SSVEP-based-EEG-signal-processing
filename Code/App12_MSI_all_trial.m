% =========================== SSVEP (2023-2024) ============================
% ================== Presented by: Reza Saadatyar ==========================
% ================= E-mail: Reza.Saadatyar92@gmail.com =====================
clc;clear;close all;
%% --------------------------------- Step 1: Load Data -------------------------------
Data=load('Data.mat');             % (number samples, number channel, number trials)
label= [ones(1,size(Data.Data1,3)), 2*ones(1,size(Data.Data2,3)),3*ones(1,size(Data.Data3,3))];
data = cat(3,Data.Data1, Data.Data2, Data.Data3);
fs=256;
%% ------------------------------ Step 2: Filtering ----------------------------------
wn= [49.5 50.5]/(fs/2);
[b,a]= butter(4,wn,"stop");
%% ------------------------------ Step 3: MSI Method ---------------------------------
Duration_trial= 5;
Num_Channel= 1:3;
Num_Harmonic = 2;                             % Number of harmonic for each frequency stimulation
F_stim= [13 21 17];                           % Freqquencies stimuation
Num_samples_trial = fs*Duration_trial;        % Fs*time each trial
Time = linspace(0,Duration_trial,Num_samples_trial);
F_Ref = zeros(length(F_stim),1);
%% ---------------------------- Step 3.1: Reference signal ----------------------------
for k=1:length(F_stim)                        % First loop: frequencies stimulation
    Data_Ref = [];
    for j=1:Num_Harmonic                      % Second loop: creates a reference signal for each frequency stimulation
        Signal_Ref(:,1) = sin(2*pi*(j*F_stim(k))*Time);
        Signal_Ref(:,2) = cos(2*pi*(j*F_stim(k))*Time);
        Data_Ref = [Data_Ref Signal_Ref]; %#ok
    end
    eval(['Data_Ref' num2str(k) '=Data_Ref;'])
end
%% ---------------------------- Step 3.2: Correlation Analysis ------------------------
Label_predic=zeros(1,size(data,3));
S = zeros(1,length(F_stim));
for i=1:size(data,3)                            % First loop: Read all Trials
    X_Filter= data(:,:,i);
    X_Filter= filtfilt(b,a,X_Filter);

    X_CAR=CAR_Filter(X_Filter);                 % CAR filter

    for k=1:length(F_stim)                      % Second loop:Calculate MSI for frequencies stimulation 
        S(:,k)= MSI(X_CAR(:,Num_Channel),eval(['Data_Ref' num2str(k)]),Num_Harmonic);
    end

    [~,Label_predic(i)]= max(S);

end
Accuracy = sum(label-Label_predic==0)/length(Label_predic)*100




