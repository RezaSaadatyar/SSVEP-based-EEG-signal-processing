% =========================== SSVEP (2023-2024) ============================
% ================== Presented by: Reza Saadatyar ==========================
% ================= E-mail: Reza.Saadatyar92@gmail.com =====================
clc;            % Clear command window
clear;          % Clear workspace variables
close all;      % Close all figures
%% ------------------------------ Step 1: Load Data ------------------------------
addpath(genpath(cd)) % Add the current directory and its subfolders to the MATLAB search path
% Let the user select a mat file containing EEG data
filename = uigetfile({'*.mat','mat file';'*.*','All Files'},'File Selection','multiselect','off');
Data = load(filename); % Load the data from the selected mat file
X = Data.Data1(:,:,1); % Extract EEG data for the first trial; (number samples, number channel, number trials)
%% ------------------------------- Step 2: Plot Result ---------------------------
Fs = 256;       % Define sampling frequency
Time_trial = 5; % Define the duration of each trial in seconds
Duration_trial = Fs * Time_trial;  % Fs * time each trial
Time = linspace(0, 5, Duration_trial); % Define time vector
name_elec = {'Oz', 'O1', 'O2', 'POz', 'PO3', 'PO4', 'PO7', 'PO8'}; % Define electrode names
Numb_Channels = 8; % Number of EEG channels

for i = 1:Numb_Channels % Plot EEG data for each channel
    subplot(8,1,i) % Create subplots for each channel
    plot(Time, X(:,i), 'linewidth', 1) % Plot EEG data for the current channel
    ax = gca; % Get current axes handle
    ax.XAxis.Visible = 'off'; % Hide x-axis
    ax.YAxis.Visible = 'on'; % Show y-axis
    ylabel(name_elec(i), 'FontSize', 10, 'FontWeight', 'bold') % Set y-axis label
    ax.YTick = []; % Hide y-axis tick marks
    if i == 1 % Add title to the first subplot
        title('Freq stimulation=13Hz; Trial 1', 'FontSize', 10, 'FontWeight', 'bold');
    end
end