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
f_low =  13 - 1;
f_high = 100;
order = 3;  
notch_freq = 50;
notch_filter = 'on';
filter_active = 'on';
design_method = "IIR";      % IIR, FIR
type_filter = "bandpass";   % low, high, bandpass
filtered_data = filtering(data_total, f_low, f_high, order, fs, notch_freq, filter_active, ...
    notch_filter, type_filter, design_method);
data_car = car_filter(filtered_data); % CAR filter
%% ------------------------------- Step 3: CCA Method ---------------------------------
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
features = zeros(size(data_total, 3), length(f_stim) * min(length(num_channel), 2 * ...
    num_harmonic));

for i = 1:size(data_total, 3) % Read all Trials
 
    for k = 1:length(f_stim)      % Second loop:Calculate CCA for frequencies stimulation
        [~, ~, coeff] = canoncorr(data_car(:, num_channel, i), eval(['data_ref' num2str(k)]));

        features(i, length(find(features(i, :))) + 1:length(find(features(i, :))) + ...
            numel(coeff)) =  coeff; % Feature Extraction
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
%% ---------------------------------------- Plot --------------------------------------
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
