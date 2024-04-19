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
% Extract EEG data for all stimulation frequencies 
data_total = cat(3, data.data1, data.data2, data.data3);
labels = [ones(1, size(data.data1, 3)), 2 * ones(1, size(data.data2, 3)), 3 * ones(1,...
    size(data.data3, 3))];
%% ----------------------- Step 2: Filtering all trials -------------------------------
fs = 256;                  % Sampling frequency
f_low = 0.05;
f_high = 100;
order = 3;  
notch_freq = 50;
notch_filter = 'on';
filter_active = 'off';
design_method = "IIR";      % IIR, FIR
type_filter = "bandpass";   % low, high, bandpass
filtered_data = filtering(data_total, f_low, f_high, order, fs, notch_freq, filter_active, ...
    notch_filter, type_filter, design_method);
data_car = car_filter(filtered_data); % CAR filter
%% ------------------------------- Step 3: MSI Method ---------------------------------
num_channel = 1:2;                  % Number of Channel
num_harmonic = 2;                   % Number of harmonic for each frequency stimulation
f_stim = [13, 21, 17];              % Frequencies stimulation
time = linspace(0, size(data_total, 1) / fs, size(data_total, 1));% Time vector
% ----------------------------- Step 3.1: Reference signal ----------------------------
for k = 1:length(f_stim)            % First loop: frequencies stimulation
    data_ref = [];
    % Second loop: creates a reference signal for each frequency stimulation
    for j = 1:num_harmonic       
        signal_ref(:, 1) = sin(2 * pi * (j * f_stim(k)) * time);
        signal_ref(:, 2) = cos(2 * pi * (j * f_stim(k)) * time);
        data_ref = [data_ref signal_ref]; %#ok
    end
    eval(['data_ref' num2str(k) '=data_ref;'])
end
% ----------------------------- Step 3.2: Correlation Analysis ------------------------
predict_labels = zeros(1, size(data_total, 3));
s_estimator = zeros(1, length(f_stim));

for i = 1:size(data_car, 3)       % First loop: Read all Trials

    for k = 1:length(f_stim)    % Second loop:Calculate MSI for frequencies stimulation
        s_estimator(:, k) = msi(data_car(:, num_channel, i), eval(['data_ref' num2str(k)]) ...
            , num_harmonic);
    end

  [~, predict_labels(i)] = max(s_estimator);

end

accuracy = sum(labels - predict_labels==0) / length(predict_labels) * 100




