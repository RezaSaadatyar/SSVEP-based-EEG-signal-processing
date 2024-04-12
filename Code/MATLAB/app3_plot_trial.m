% =============================== SSVEP (2023-2024) ===================================
% ======================== Presented by: Reza Saadatyar ===============================
% ====================== E-mail: Reza.Saadatyar@outlook.com ===========================
clc;            % Clear command window
clear;          % Clear workspace variables
close all;      % Close all figures
%% ------------------------------- Step 1: Load Data ----------------------------------
% Add the current directory and its subfolders to the MATLAB search path
addpath(genpath(cd)) 
% Let the user select a mat file containing EEG data
[filename, path] = uigetfile({'*.mat', 'mat file'; '*.*', 'All Files'}, 'File Selection', ...
    'multiselect', 'off');
data = load([path filename]); % Load the data from the selected mat file
% Extract EEG data for the first trial; (number samples, number channel, number trials)
trial = 1;
x = data.data1(:, :, trial); 
%% -------------------------------- Step 2: Plot Result -------------------------------
fs = 256;       % Define sampling frequency
time_trial = 5; % Define the duration of each trial in seconds
duration_trial = fs * time_trial;  % Fs * time each trial
time = linspace(0, 5, duration_trial); % Define time vector

% Define electrode names
name_elec = {'Oz', 'O1', 'O2', 'POz', 'PO3', 'PO4', 'PO7', 'PO8'}; 
numb_Channels = 8; % Number of EEG channels

for i = 1:numb_Channels % Plot EEG data for each channel
    subplot(8, 1, i) % Create subplots for each channel
    plot(time, x(:, i), 'linewidth', 1) % Plot EEG data for the current channel
    ax = gca; % Get current axes handle
    ax.XAxis.Visible = 'off'; % Hide x-axis
    ax.YAxis.Visible = 'on'; % Show y-axis
    ylabel(name_elec(i), 'FontSize', 10, 'FontWeight', 'bold') % Set y-axis label
    ax.YTick = []; % Hide y-axis tick marks
    if i == 1 % Add title to the first subplot
        title(['Freq stimulation=13Hz; Trial:' num2str(trial)], 'FontSize', 10, ...
            'FontWeight', 'bold');
    end
end