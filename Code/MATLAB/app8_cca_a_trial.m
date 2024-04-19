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
% Extract EEG data for the first trial (number samples, number channel, number trials)
x = data.data1;
%% ----------------------- Step 2: Filtering all trials -------------------------------
fs = 256;              % Sampling frequency
f_low = 0.05;
f_stim = [13 21 17];   % Frequencies stimulation
f_high = 100;
order = 4;  
notch_freq = 50;
notch_filter = 'on';
filter_active = 'off';
design_method = "IIR";      % IIR, FIR
type_filter = "bandpass";   % low, high, bandpass
filtered_data = filtering(x, f_low, f_high, order, fs, notch_freq, filter_active, ...
    notch_filter, type_filter, design_method);
x_car = car_filter(filtered_data); % CAR filter
%% ------------------------------- Step 3: CCA Method ---------------------------------
num_channel = 1:3;                  % Number of Channel
num_harmonic = 2;                   % Number of harmonic for each frequency stimulation
time = (0: size(x_car, 1) - 1) / fs;% Time vector
f_ref = zeros(length(f_stim), 1);

for i = 1:length(f_stim)             % First loop for frequencies stimulation
    data_ref = [];
    % Second loop creates a reference signal for each frequency stimulation
    for j = 1:num_harmonic            
        signal_ref(:, 1) = sin(2 * pi * (j * f_stim(i)) * time);
        signal_ref(:, 2) = cos(2 * pi * (j * f_stim(i)) * time);
        data_ref = [data_ref, signal_ref]; %#ok
    end
    [~, ~, a]=canoncorr(x_car(:, num_channel, 159), data_ref);
    f_ref(i) = max(a);
end
[~, Label_predic] = max(f_ref)
