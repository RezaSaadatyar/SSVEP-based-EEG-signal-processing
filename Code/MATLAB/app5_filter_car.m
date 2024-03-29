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
data = load(filename); % Load the data from the selected mat file
% Extract EEG data for the first trial (number samples, number channel, number trials)
x = data.data1;  
%% ------------------ Step 2: Filtering all trials --------------------------------
fs = 256;           % Define sampling frequency
f_low = 0.05;
f_high = 100;
order = 4;  
notch_freq = 50;
quality_factor = 20;
filter_active = 'on';
notch_filter = 'on';
type_filter = "bandpass";   % low, high, bandpass
filtered_data = filtering(x, f_low, f_high, order, fs, notch_freq, ...
     filter_active, notch_filter, quality_factor, type_filter);
x_car = car_filter(filtered_data);  % CAR filter
%% --------------------------- Step 3: Plot Results ----------------------------
time = (0: size(x, 1)-1)*1/fs;   % Time vector
figure()
subplot(2, 1, 1)
plot(time, x(:, 1, 1),'linewidth', 0.5)
title('Freq stimulation=13Hz; OZ; Trial 1', FontSize=10, FontWeight='bold')
legend({'Raw signal'}, FontSize=8, FontWeight="bold")
subplot(2, 1, 2)
plot(time, x_car(:, 1, 1), 'linewidth', 0.5)
legend({'Filter CAR'}, FontSize=8, FontWeight="bold")
xlabel('Time(sec)', FontSize=10, FontWeight="bold")

