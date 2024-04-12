% =============================== SSVEP (2023-2024) ===================================
% ====================== Presented by: Reza Saadatyar =================================
% ===================== E-mail: Reza.Saadatyar@outlook.com ============================
clc;            % Clear command window
clear;          % Clear workspace variables
close all;      % Close all figures
%% -------------- Step 1: Convert gdf data to mat using biosig4octmat -----------------
% biosig4octmat ---> biosig ---> run the install code
addpath(genpath(cd)) % Add the current directory and its subfolders to the path
% Let the user select gdf file(s)
[filename, path] = uigetfile({'*.gdf', 'gdf file'; '*.*', 'All Files'}, 'File Selection', ...
    'multiselect', 'off');
% Load gdf data into Signal and Inform variables
[signal, inform] = sload([path filename]); 
%% --------- Step 2: Define stimulation labels and extract trial information ----------
% Inform.EVENT.TYP:
% 33024 ---> rest
% Label_01 ---> 13Hz stimulation (33025)
% Label_02 ---> 21Hz stimulation (33026)
% Label_03 ---> 17Hz stimulation (33027).
labels = inform.EVENT.TYP; % Define labels for each stimulation frequency
time_start_trial = inform.EVENT.POS; % Get the start time of each trial
fs = 256; % Define sampling frequency
time_trial = 5; % Define the duration of each trial in seconds
duration_trial = fs * time_trial;  % Fs * time each trial
numb_Channels = 8; % Number of EEG channels

for i = 1:3 % Loop through each stimulation label
    lab = [33025, 33026, 33027];  % Define the labels for the current iteration
    numb_trials = find(labels == lab(i)); % Find indices of trials with the current label
    
    % Initialize an array to store trial data for the current label
    data = zeros(duration_trial, numb_Channels, length(numb_trials));
    
    % Iterate over each trial index and extract the corresponding data
    for j = 1:length(numb_trials) 
        data(:, :, j) = signal(time_start_trial(numb_trials(j)):time_start_trial(numb_trials(j)) ...
            + duration_trial - 1, :);
    end
    
    % Use eval to dynamically create variable names for each trial's data array
    eval(['data_' num2str(i) ' = data;']) 
end