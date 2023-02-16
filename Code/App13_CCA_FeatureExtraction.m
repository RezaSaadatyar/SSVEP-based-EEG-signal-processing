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
%% ------------------------------ Step 2: Filtering ----------------------------------
wn= [49.2 50.6]/(fs/2);
[b,a]= butter(3,wn,"stop");
[b1,a1]= butter(3,(min(F_stim)-1)/(fs/2), 'high');
%% ------------------------------ Step 3: CCA Method ---------------------------------
F_Ref = zeros(length(F_stim),1);
% ---------------------------- Step 3.1: Reference signal ----------------------------
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
Features=zeros(size(DataTotal,3),length(F_stim)*min(length(Num_Channel),2*Num_Harmonic));
S = zeros(1,length(F_stim));
for i=1:size(DataTotal,3)                            % Read all Trials
    X_Filter= DataTotal(:,:,i);
    X_Filter= filtfilt(b,a,X_Filter);
    X_Filter= filtfilt(b1,a1,X_Filter);

    X_CAR=CAR_Filter(X_Filter);                 % CAR filter

    for k=1:length(F_stim)                      % Second loop:Calculate CCA for frequencies stimulation
        [~,~,C]= canoncorr(X_CAR(:,Num_Channel),eval(['Data_Ref' num2str(k)]));
%         S(k)=max(C);
        Features(i,length(find(Features(i,:)))+1:length(find(Features(i,:)))+numel(C))= C; % Feature Extraction
    end
end
%% ------------------------------ Step 4: Feature Selection --------------------------
NumFeatures = 20;
Features=Feature_Selection(Features,Labels,NumFeatures);
%% ------------------------------ Step 5: Classification -----------------------------
K_Fold = 3;
NumNeigh_KNN = 3;
Kernel_SVM = 'linear';
Distr_Bayesian = 'normal';                               % 'normal','kernel'
DiscrimType_LDA = 'linear';                              % 'linear','quadratic','diaglinear','diagquadratic','pseudolinear','pseudoquadratic'
NumNeurons_ELM = 12;
Num_Neurons = 15;
NumCenter_RBF = 20;
Sigma_PNN = 0.1;
Type_PNN = 'Euclidean';                                  % 'Euclidean';'Correlation'
Classifiation(Features,Labels,K_Fold,NumNeigh_KNN,Kernel_SVM,Distr_Bayesian,DiscrimType_LDA,...
    NumNeurons_ELM,NumCenter_RBF,Sigma_PNN,Type_PNN)
%% ---------------------------------- Plot ----------------------------------
figure();
Class = unique(Labels);
for i = 1:numel(Class)
    if size(Features,1)==2
        plot(Features(Labels==Class(i),1),Features(Labels==Class(i),2),'o','LineWidth',1.5,'MarkerSize',4); hold on
        xlabel('Feature 1');ylabel('Feature 2');
    elseif size(Features,1)>2
        plot3(Features(Labels==Class(i),1),Features(Labels==Class(i),2),Features(Labels==Class(i),3),'o','LineWidth',1.5,'MarkerSize',4);hold on
        xlabel('Feature 1');ylabel('Feature 2');zlabel('Feature 3');
    end
end
grid on;til=legend(string(F_stim));title(til,'F-stim (Hz)')
