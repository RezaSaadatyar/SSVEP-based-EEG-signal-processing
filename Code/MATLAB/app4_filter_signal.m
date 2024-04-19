% =============================== SSVEP (2023-2024) ===================================
% ========================= Presented by: Reza Saadatyar ==============================
% ======================== E-mail: Reza.Saadatyar@outlook.com =========================
clc;            % Clear command window
clear;          % Clear workspace variables
close all;      % Close all figures
%% -------------------------------- Step 1: Load Data ---------------------------------
% Add the current directory and its subfolders to the MATLAB search path
addpath(genpath(cd)) 
% Let the user select a mat file containing EEG data
[filename, path] = uigetfile({'*.mat', 'mat file'; '*.*', 'All Files'}, 'File Selection', ...
    'multiselect', 'off');
data = load([path filename]); % Load the data from the selected mat file
% Extract EEG data for the first trial (number samples, number channel, number trials)
x = data.data1;  
%% --------------------- Step 2: Filtering all trials ---------------------------------
fs = 256;
f_low = 0.05;
f_high = 100;
order = 4;  
notch_freq = 50;
notch_filter = 'on';
filter_active = 'off';
design_method = "IIR";      % IIR, FIR
type_filter = "bandpass";   % low, high, bandpass
filtered_data = filtering(x, f_low, f_high, order, fs, notch_freq, filter_active, ...
    notch_filter, type_filter, design_method);
trial = 1;
channel = 1;
%% --------------------- Step 3: Fourier transform for a channel ----------------------
% Perform Fourier transform on the first channel of the first trial
x_fft = fft(x(:, channel, trial));
% Calculate the one-sided power spectral density (PSD)
x_psd = abs(x_fft(1:floor(length(x_fft)/2))); 
% Perform Fourier transform on the filtered signal
fft_x_filter = fft(filtered_data(:, channel, trial)); 
fft_x_filter = abs(fft_x_filter(1:floor(length(x_fft)/2)));
f = linspace(0, fs/2, floor(length(x_fft)/2)); % Create a frequency axis
%% ------------------------------ Step 4: Plot Result ---------------------------------
figure(1)
subplot(2, 1, 1)   
plot(x(:, 1, 1),'linewidth', 0.5); hold on
plot(filtered_data(:, channel, trial), 'r', 'linewidth', 0.5)
xlim([0, length(filtered_data(:, channel, trial))])
title(['Freq stimulation=13Hz; Channel: ' num2str(channel) '; Trial: ' num2str(trial)], ...
    'FontSize', 10, 'FontWeight', 'bold')
legend({'Raw signal', 'Filtered Signal'}, 'FontSize', 8, 'FontWeight', 'bold')
subplot(2, 1, 2)
plot(f, x_psd, 'linewidth', 1); hold on
plot(f, fft_x_filter, 'LineWidth', 1); xlim([0, f(end)])
ylabel('PSD', 'FontSize', 10, 'FontWeight', 'bold')
xlabel('F(Hz)', 'FontSize', 10, 'FontWeight', 'bold')