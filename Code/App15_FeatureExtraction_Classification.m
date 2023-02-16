% =========================== SSVEP (2023-2024) ============================
% ================== Presented by: Reza Saadatyar ==========================
% ================= E-mail: Reza.Saadatyar92@gmail.com =====================
clc;clear;close all;
%% --------------------------------- Step 1: Load Data -------------------------------
Data=load('Data.mat');             % (number samples, number channel, number trials)
Labels= [ones(1,size(Data.Data1,3)), 2*ones(1,size(Data.Data2,3)),3*ones(1,size(Data.Data3,3))]';
DataTotal = cat(3,Data.Data1, Data.Data2, Data.Data3);

%% --------------------------------- Parameters --------------------------------------
Fs= 256;                                            % Sampling frequency
Duration_trial= 5;                                  % Length of trials
Num_Channel= 1:8;                                   % Number of Channel
Num_Harmonic = 2;                                   % Number of harmonic for each frequency stimulation
F_stim= [13 21 17];                                 % Freqquencies stimuation
SB= [12 24 36 15 32 49 20 40 63;              
     15 28 42 19 33 53 23 44 65];
%% ------------------------------ Step 2: Filtering ----------------------------------
[b,a]= butter(3,[49.6 50.4]/(Fs/2),"stop");         % Notch filter: remove 50 Hz
[b1,a1]= butter(3,[11 70]/(Fs/2), 'bandpass');
%% ------------------------- Step 3: Feature Extraction (FFT) ------------------------
Features= zeros(size(DataTotal,3),size(SB,2)*length(Num_Channel));
for i=1:size(DataTotal,3)                           % Read all Trials
    X_Filter= DataTotal(:,:,i);
    X_Filter= filtfilt(b1,a1,X_Filter);

    X_CAR=CAR_Filter(X_Filter);                     % CAR filter

    X_fft= fft(X_CAR(:,Num_Channel));               % FFT
    X_PSD= abs(X_fft(1:floor(length(X_fft)/2)+1,:));

    F= linspace(0,Fs/2,floor(length(X_fft)/2)+1);

    for k=1:size(SB,2)                        % Feature extraction for each subband
        Ind= find((F>=SB(1,k)) & (F<=SB(2,k)));
        Features(i,length(find(Features(i,:)))+1:k*length(Num_Channel))= max(X_PSD(Ind,:));
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