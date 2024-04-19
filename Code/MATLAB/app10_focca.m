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
labels = [ones(1, size(data.data1, 3)), 2*ones(1, size(data.data2, 3)), 3*ones(1, ...
    size(data.data3, 3))];
%% ----------------------- Step 2: Filtering all trials -------------------------------
fs = 256;                  % Sampling frequency
f_low = 0.05;
f_high = 100;
order = 4;  
notch_freq = 50;
notch_filter = 'on';
filter_active = 'off';
design_method = "IIR";      % IIR, FIR
type_filter = "bandpass";   % low, high, bandpass
filtered_data = filtering(data_total, f_low, f_high, order, fs, notch_freq, filter_active, ...
    notch_filter, type_filter, design_method);
data_car = car_filter(filtered_data); % CAR filter
%% ------------------------------ Step 3: FoCCA Method --------------------------------
num_channel = [1, 2, 3];            % Number of Channel
num_harmonic = 2;                   % Number of harmonic for each frequency stimulation
f_stim = [13, 21, 17];              % Frequencies stimulation
time = (0: size(data_car, 1) - 1) / fs;% Time vector
% ----------------------------- Step 3.1: Reference signal ----------------------------
for k = 1:length(f_stim)    % First loop: frequencies stimulation
    data_ref = [];
    % Second loop: creates the harmonic signal for each frequency stimulation
    for j = 1:num_harmonic                      
        signal_ref(:, 1) = sin(2 * pi * (j * f_stim(k)) * time);
        signal_ref(:, 2) = cos(2 * pi * (j * f_stim(k)) * time);
        data_ref = [data_ref signal_ref]; %#ok
    end
    eval(['data_ref' num2str(k) '=data_ref;'])
end
% ----------------------------- Step 3.2: Correlation Analysis ------------------------
predict_label = zeros(1, size(data_total, 3));
coeff = zeros(1, length(f_stim));
k = (1: min([numel(num_channel), num_harmonic * 2]))';
count = 0;
a = [0.001 0.01 0.1 0 1 10];
b = [0.001 0.01 0.1 0 1 10];
accuracy = zeros(1, length(a) * length(b));
for n1 = 1:length(a)                  
   for n2 = 1:length(b)
        phi = (k).^-a(n1) + b(n2);
        count = count + 1;

        for i = 1:size(data_total,3)     % Read all Trials

            for L = 1:length(f_stim)     % Calculate FOCCA for frequencies stimulation
                [~, ~, cano_corr]= canoncorr(data_car(:, num_channel, i), eval(['data_ref' ...
                    num2str(L)]));
                coeff(L) = sum(phi.* (cano_corr'.^2));
            end

            [~, predict_label(i)] = max(coeff);

        end

        accuracy(count) = sum(labels - predict_label == 0) / length(predict_label) * 100;

    end
end

plot(accuracy, '-ob', 'linewidth', 1)
ylabel('Accuracy')
legend('FOCCA')
        
