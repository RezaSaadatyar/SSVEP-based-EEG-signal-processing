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
order = 3;  
notch_freq = 50;
notch_filter = 'on';
filter_active = 'off';
design_method = "IIR";      % IIR, FIR
type_filter = "bandpass";   % low, high, bandpass
filtered_data = filtering(data_total, f_low, f_high, order, fs, notch_freq, filter_active, ...
    notch_filter, type_filter, design_method);
data_car = car_filter(filtered_data); % CAR filter
%% ------------------------------ Step 3: FBCCA Method --------------------------------
notch_filter = 'off';
filter_active = 'on';
type_filter = "bandpass";           % low, high, bandpass
num_channel = [1, 2];               % Number of Channel
num_harmonic = 2;                   % Number of harmonic for each frequency stimulation
f_stim = [13, 21, 17];              % Frequencies stimulation
time = linspace(0, size(data_total, 1) / fs, size(data_total, 1));% Time vector
m = 'm3';                           % Type filter banks: M1, M2, M3
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
count = 0;

if strcmpi(m, 'm1')
    filter_banks = [10:10:80; 20:10:90];  
elseif strcmpi(m, 'm2')
    filter_banks = [10, 20, 30, 40, 50, 60, 70, 80; 
              20, 35, 60, 90, 100, 100, 100, 100]; 
else
    filter_banks = [10:10:90; ones(1, 9)*100]; 
end

k = (1: size(filter_banks, 2))';
a = [0.01 0];
b = [0.001 0];
accuracy = zeros(1, length(a) * length(b));
predict_labels = zeros(1, size(data_total, 3));
coeff = zeros(size(filter_banks, 2), length(f_stim));

for ind_a = 1:numel(a)
    for ind_b = 1:numel(b)
        phi= (k).^-a(ind_a) + b(ind_b);
        count = count + 1;
     
        for i = 1:size(data_car, 3)
            for ind_sub = 1:size(filter_banks, 2)
                f_low = filter_banks(1, ind_sub);
                f_high = filter_banks(2, ind_sub);
                data_sub_banks = filtering(data_car(:, :, i), f_low, f_high, order, fs, ...
                                 notch_freq, filter_active, notch_filter, type_filter);

                % Second loop:Calculate CCA for frequencies stimulation
                for L = 1:length(f_stim) 
                    [~, ~, cano_corr] = canoncorr(data_sub_banks(:, num_channel), ...
                        eval(['data_ref' num2str(L)]));
                    coeff(ind_sub, L) = max(cano_corr);
                end

            end
            [~, predict_labels(i)] = max(sum(phi.*(coeff.^2), 1));

        end
        accuracy(count) = sum(labels - predict_labels==0) / length(predict_labels) * 100; 
    end
end

plot(accuracy, '-ob', 'linewidth', 1)
ylabel('Accuracy'); 
legend('FBCCA')
