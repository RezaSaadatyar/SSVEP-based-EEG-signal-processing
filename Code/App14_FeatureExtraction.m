% =========================== SSVEP (2023-2024) ============================
% ================== Presented by: Reza Saadatyar ==========================
% ================= E-mail: Reza.Saadatyar92@gmail.com =====================
clc;clear;close all;
%% --------------------------------- Step 1: Load Data -------------------------------
Data=load('Data.mat');             % (number samples, number channel, number trials)
Labels= [ones(1,size(Data.Data1,3)), 2*ones(1,size(Data.Data2,3)),3*ones(1,size(Data.Data3,3))];
DataTotal = cat(3,Data.Data1, Data.Data2, Data.Data3);
%% --------------------------------- Parameters --------------------------------------
Fs= 256;                                            % Sampling frequency  
Duration_trial= 5;                                  % Length of trials 
Num_Channel= 1:8;                                   % Number of Channel
Num_Harmonic = 2;                                   % Number of harmonic for each frequency stimulation
F_stim= [13 21 17];                                 % Freqquencies stimuation
Subbands= [12 25 38 16 33 50 20 41 62;              % Sub_band        
           14 27 40 18 35 52 22 43 64];
% Subbands=[10:10:80;20:10:90]; 
%% ------------------------------ Step 2: Filtering ----------------------------------
[b,a]= butter(3,[49.2 50.6]/(Fs/2),"stop");         % Notch filter: remove 50 Hz
[b1,a1]= butter(3,[min(Subbands(:))-1 max(Subbands(:))+1]/(Fs/2), 'bandpass');
%% ------------------------- Step 3: Feature Extraction (FFT) ------------------------
Features= zeros(size(Subbands,2)*length(Num_Channel),size(DataTotal,3));
for i=1:size(DataTotal,3)                           % Read all Trials
    X_Filter= DataTotal(:,:,i);
    X_Filter= filtfilt(b1,a1,X_Filter);
    
    X_CAR=CAR_Filter(X_Filter);                     % CAR filter

    X_fft= fft(X_CAR(:,Num_Channel));               % FFT
    X_PSD= abs(X_fft(1:floor(length(X_fft)/2)+1,:));
    F= linspace(0,Fs/2,floor(length(X_fft)/2)+1);

    for k=1:size(Subbands,2)                        % Feature extraction for each subband
        Ind= find((F>=Subbands(1,k)) & (F<=Subbands(2,k)));
        Features(length(find(Features(:,i)))+1:k*length(Num_Channel),i)= max(X_PSD(Ind,:));
    end 
end
%% -------------------------------------- Plot -------------------------------------
if size(Features,1)<size(Features,2);Features=Features';end

figure()
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

