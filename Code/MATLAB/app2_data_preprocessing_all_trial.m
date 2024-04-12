% =============================== SSVEP (2023-2024) ===================================
% ========================= Presented by: Reza Saadatyar ==============================
% ======================== E-mail: Reza.Saadatyar@outlook.com =========================
clc;            % Clear command window
clear;          % Clear workspace variables
close all;      % Close all figures
%% --------------- Step 1: Convert gdf data to mat using biosig4octmat ----------------
% Load gdf data into Signal and Inform variables using biosig4octmat
% Add the current directory and its subfolders to the MATLAB search path
addpath(genpath(cd)) 
% Let the user select gdf file(s)
[filename, path] = uigetfile({'*.gdf', 'gdf file'; '*.*', 'All Files'}, 'File Selection', ...
    'multiselect', 'on');
%% ------------------------- Step 2: Access data folders ------------------------------
fs = 256;       % Define sampling frequency
time_trial = 5; % Define the duration of each trial in seconds
% Calculate the duration of each trial in samples based on the sampling frequency
duration_trial = fs * time_trial;
numb_Channels = 8; % Number of EEG channels

% Loop through each selected filename, First loop ---> read all data
for i = 1:length(filename) 
     % Load gdf data into Signal and Inform variables
    [signal, inform] = sload(filename{i});
    %% -------------------------------- Step 3: Split trials --------------------------
    labels = inform.EVENT.TYP; % Define labels for each stimulation frequency
    time_start_trial = inform.EVENT.POS; % Get the start time of each trial
    
    for j = 1:3    % Loop through each label 
        lab = [33025, 33026, 33027];
        % Find indices of trials with the current label
        numb_trials = find(labels == lab(j)); 
        % Initialize an array to store trial data for the current label
        data = zeros(duration_trial, numb_Channels, length(numb_trials));
        % Loop through each trial index and extract the corresponding data
        for k = 1:length(numb_trials) % Sorting trials based on each label in the Signal
            % Append data to existing Data variables if they exist
            if exist('data1', 'var') && (i > 1) && (j == 1)
                data1(:, :, size(data1, 3) + 1) = signal(time_start_trial(numb_trials(k)) ...
                    :time_start_trial(numb_trials(k)) + ...
                    duration_trial - 1, :);
            elseif exist('data2', 'var') && (i > 1) && (j == 2)
                data2(:, :, size(data2, 3) + 1) = signal(time_start_trial(numb_trials(k)) ...
                    :time_start_trial(numb_trials(k)) + ...
                    duration_trial - 1, :);
            elseif exist('data3', 'var') && (i > 1) && (j == 3)
                data3(:, :, size(data3, 3) + 1) = signal(time_start_trial(numb_trials(k)) ...
                    :time_start_trial(numb_trials(k)) + ...
                    duration_trial - 1, :);
            else
                data(:, :, k) = signal(time_start_trial(numb_trials(k)):time_start_trial ...
                    (numb_trials(k)) + duration_trial - 1, :);
            end
        end
        % Create new Data variables if they don't exist
        if exist('data1', 'var') == 0 || exist('data2', 'var') == 0 || exist('data3', ...
                'var') == 0
            eval(['data' num2str(j)  ' = data;'])
        end
    end
end
%% Save the data
filename = fullfile(path, 'data.mat'); % Construct the full file path
% Save your variables to the specified location
save(filename, 'data1', 'data2', 'data3'); 
