% =========================== SSVEP (2023-2024) ============================
% ================== Presented by: Reza Saadatyar ==========================
% ================= E-mail: Reza.Saadatyar92@gmail.com =====================
clc;            % Clear command window
clear;          % Clear workspace variables
close all;      % Close all figures
%% ------------------------------ Step 1: Load Data ------------------------------
addpath(genpath(cd)) % Add the current directory and its subfolders to the MATLAB search path
% Let the user select a mat file containing EEG data
filename = uigetfile({'*.mat','mat file';'*.*','All Files'},'File Selection','multiselect','off');
Data = load(filename); % Load the data from the selected mat file

X = Data.Data1;  % Extract EEG data for the first trial (number samples, number channel, number trials)
fs = 256;
%% ------------------ Step 2: Filtering all trials --------------------------------
wn = [49.2 50.6]/(fs/2); % Define the stopband frequencies for the notch filter
[b, a] = butter(4, wn, "stop"); % Design a 4th order Butterworth notch filter
for i = 1:size(X,3) % Apply the notch filter to each trial
    X(:,:,i) = filtfilt(b, a, X(:,:,i));
end
%% ------------------- Step 3: Fourier transform for a channel --------------------
% Perform Fourier transform on the first channel of the first trial
X_fft = fft(Data.Data1(:,1,1));
X_PSD = abs(X_fft(1:floor(length(X_fft)/2))); % Calculate the one-sided power spectral density (PSD)
fft_X_Filter = fft(X(:,1,1)); % Perform Fourier transform on the filtered signal
fft_X_Filter = abs(fft_X_Filter(1:floor(length(X_fft)/2)));
f = linspace(0, fs/2, floor(length(X_fft)/2)); % Create a frequency axis
%% ---------------------------- Step 4: Plot Result --------------------------------
figure(1)
subplot(2,1,1)
plot(Data.Data1(:,1,1),'linewidth',0.5); hold on
plot(X(:,1,1),'r','linewidth',0.5); xlim([0, length(X(:,1,1))])
title('Freq stimulation=13Hz; OZ; Trial 1', 'FontSize',10, 'FontWeight','bold')
legend({'Raw signal','Filtered Signal'}, 'FontSize',8, 'FontWeight','bold')
subplot(2,1,2)
plot(f, X_PSD,'linewidth',1); hold on
plot(f, fft_X_Filter,'LineWidth',1); xlim([0, f(end)])
ylabel('PSD', 'FontSize',10, 'FontWeight','bold')
xlabel('F(Hz)', 'FontSize',10, 'FontWeight','bold')
