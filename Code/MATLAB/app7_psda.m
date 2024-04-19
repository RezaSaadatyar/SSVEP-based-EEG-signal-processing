% =============================== SSVEP (2023-2024) ===================================
% ======================== Presented by: Reza Saadatyar ===============================
% ====================== E-mail: Reza.Saadatyar@outlook.com ===========================
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
% Extract EEG data (number samples, number channel, number trials)
data_total = cat(3, data.data1, data.data2, data.data3);
labels = [ones(1, size(data.data1, 3)), 2*ones(1, size(data.data2, 3)), 3*ones(1, ...
    size(data.data3, 3))];
%% ----------------------- Step 2: Filtering all trials -------------------------------
fs = 256;              % Sampling frequency
f_low = 0.05;
f_stim = [13 21 17];    % Frequencies stimulation
f_high = min(f_stim)-1;
order = 4;  
notch_freq = 50;
notch_filter = 'on';
filter_active = 'on';
design_method = "IIR";      % IIR, FIR
type_filter = "high";       % low, high, bandpass
filtered_data = filtering(data_total, f_low, f_high, order, fs, notch_freq, filter_active, ...
    notch_filter, type_filter, design_method);
x_car = car_filter(filtered_data); % CAR filter
%% -------------------------------- Step 3: PSDA Method -------------------------------
num_harmonic = 2;     % Number of harmonic for each frequency stimulation
% Number of samples neighborhood for each frequency stimulation
num_sample_neigh = 30;
num_channel = 1:2;    % Number of Channel

label_predic=zeros(1, size(data_total, 3));
for i = 1:size(data_total, 3)
    x = x_car(:, :, i);
    ps = psda(x(:, num_channel), f_stim, num_sample_neigh, fs, num_harmonic);
    [~, label_predic(i)] = max(ps);
end
Accuracy = sum(labels - label_predic == 0) / length(label_predic) * 100
