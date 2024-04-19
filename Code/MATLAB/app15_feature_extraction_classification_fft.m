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
order = 3;  
notch_freq = 50;
notch_filter = 'on';
filter_active = 'on';
design_method = "IIR";      % IIR, FIR
type_filter = "bandpass";   % low, high, bandpass
subbands = [12 16 20;
       14 18 22];
% [12 25 38 16 33 50 20 41 62; % Sub_band        
%            14 27 40 18 35 52 22 43 64];
f_low = min(subbands(:)) - 1;
f_high = max(subbands(:)) + 1;
filtered_data = filtering(data_total, f_low, f_high, order, fs, notch_freq, filter_active, ...
    notch_filter, type_filter, design_method);
data_car = car_filter(filtered_data); % CAR filter
%% ------------------------ Step 3: Feature Extraction using FFT ----------------------
num_channel = 1:4;                  % Number of Channel
f_stim = [13, 21, 17];              % Frequencies stimulation
f = linspace(0, fs/2, floor(length(data_car) / 2) + 1);
features = zeros(size(subbands, 2) * length(num_channel), size(data_total, 3));

for i = 1:size(data_total, 3)                      % Read all Trials
    data_fft = fft(data_car(:, num_channel, i));   % FFT
    data_psd = abs(data_fft(1:floor(length(data_fft) / 2) + 1, :));
    
    for k = 1:size(subbands, 2)           % Feature extraction for each subband
        ind = find((f >= subbands(1, k)) & (f <= subbands(2, k)));
        features(length(find(features(:, i))) + 1:k * length(num_channel), i) = max(...
            data_psd(ind, :));
    end 
end
%% ------------------------------- Step 4: Feature Selection --------------------------
num_features = 4;
features = anova_feature_selection(features, labels, num_features);
%% ------------------------------- Step 5: Classification -----------------------------
k_fold = 5;
num_neigh_knn = 3;
kernel_svm = 'linear';
distr_bayesian = 'normal';  % 'normal','kernel'
% 'linear','quadratic','diaglinear','diagquadratic','pseudolinear','pseudoquadratic'
discrimtype_lda = 'linear'; 
num_neurons_elm = 12;
Num_Neurons = 15;
num_center_rbf = 20;
sigma_pnn = 0.1;
type_pnn = 'Euclidean';      % 'Euclidean';'Correlation'
classifiation(features, labels, k_fold, num_neigh_knn, kernel_svm, distr_bayesian, ...
              discrimtype_lda, num_neurons_elm, num_center_rbf, sigma_pnn, type_pnn)
%% -------------------------------------- Plot ----------------------------------------
figure();
classes = unique(labels);
if size(features, 1) < size(features, 2); features = features'; end

for i = 1:numel(classes)
    if size(features, 1) == 2
        plot(features(labels == classes(i), 1), features(labels==classes(i), 2), 'o', ...
            'LineWidth', 1.5, 'MarkerSize', 4); hold on
        xlabel('Feature 1'); ylabel('Feature 2');
    elseif size(features, 1) > 2
        plot3(features(labels == classes(i), 1), features(labels == classes(i), 2), ...
            features(labels == classes(i), 3), 'o', 'LineWidth', 1.5, 'MarkerSize', 4);
        hold on
        xlabel('Feature 1'); ylabel('Feature 2'); zlabel('Feature 3');
    end
end
grid on; til=legend(string(f_stim)); title(til, 'F-stim (Hz)')