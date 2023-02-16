% =========================== SSVEP (2023-2024) ============================
% ================== Presented by: Reza Saadatyar ==========================
% ================= E-mail: Reza.Saadatyar92@gmail.com =====================
clc;clear;close all;
%% --------------------------------- Step 1: Load Data -------------------------------
Data=load('Data.mat');             % (number samples, number channel, number trials)
Labels= [ones(1,size(Data.Data1,3)), 2*ones(1,size(Data.Data2,3)),3*ones(1,size(Data.Data3,3))];
DataTotal = cat(3,Data.Data1, Data.Data2, Data.Data3);
%% --------------------------------- Parameters --------------------------------------
fs= 256;                                            % Sampling frequency  
Duration_trial= 5;                                  % Length of trials 
Num_Channel= 1:3;                                   % Number of Channel
Num_Harmonic = 2;                                   % Number of harmonic for each frequency stimulation
F_stim= [13 21 17];                                 % Freqquencies stimuation
Num_samples_trial = fs*Duration_trial;              % Fs*time each trial
Time= linspace(0,Duration_trial,Num_samples_trial); % Time vector
M = 'M3';                                           % Type filter banks: M1, M2, M3
%% ------------------------------ Step 2: Filtering ----------------------------------
wn= [49.2 50.6]/(fs/2);
[b,a]= butter(3,wn,"stop");
%% ----------------------------- Step 3: FBCCA Method --------------------------------
% ---------------------------- Step 3.1: Reference signal ----------------------------
F_Ref = zeros(length(F_stim),1);
for k=1:length(F_stim)                        % First loop: frequencies stimulation
    Data_Ref = [];
    for j=1:Num_Harmonic                      % Second loop: creates a reference signal for each frequency stimulation
        Signal_Ref(:,1) = sin(2*pi*(j*F_stim(k))*Time);
        Signal_Ref(:,2) = cos(2*pi*(j*F_stim(k))*Time);
        Data_Ref = [Data_Ref Signal_Ref]; %#ok
    end
    eval(['Data_Ref' num2str(k) '=Data_Ref;'])
end
% ---------------------------- Step 3.2: Correlation Analysis ------------------------
Predict_Labels=zeros(1,size(DataTotal,3));

if strcmpi(M, 'M1')
    fbanks= [10:10:80;20:10:90];  
elseif strcmpi(M, 'M2')
    fbanks= [10 20 30 40 50 60 70 80;
             20 35 60 90 100 100 100 100]; 
else
    fbanks= [10:10:80;ones(1,8)*100]; 
end

K= (1: size(fbanks,2))';

Count= 0;
Landa1=[0.01 0.1 0 1 10];
Landa2=[0.01 0.1 0 1 10];
S = zeros(size(fbanks,2),length(F_stim));
Accuracy = zeros(1,length(Landa1)*length(Landa2));

for N1=1:length(Landa1)                              % FBCCA
   for N2=1:length(Landa2)
        Phi= (K).^-Landa1(N1) + Landa2(N2);
        Count= Count+1;

for i=1:size(DataTotal,3)                            % Read all Trials
    X_Filter= DataTotal(:,:,i);
    X_Filter= filtfilt(b,a,X_Filter);
    
    X_CAR=CAR_Filter(X_Filter);                      % CAR filter

    for n=1:size(fbanks,2)
        bands= fbanks(:,n);
        [b2,a2]= butter(3,(bands)/(fs/2), 'bandpass');
        SBn= filtfilt(b2,a2,X_CAR);
        for k=1:length(F_stim)                       % Second loop:Calculate CCA for frequencies stimulation
            [~,~,C]= canoncorr(SBn(:,Num_Channel),eval(['Data_Ref' num2str(k)]));
            S(n,k)=max(C);
        end
    end

    [~,Predict_Labels(i)]= max(sum(Phi.*(S.^2),1));


end
Accuracy(Count)=sum(Labels-Predict_Labels==0)/length(Predict_Labels)*100;
    end
end
plot(Accuracy,'-ob','linewidth',1)
ylabel('Accuracy');legend('FBCCA')