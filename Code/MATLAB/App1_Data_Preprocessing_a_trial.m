% =========================== SSVEP (2023-2024) ============================
% ================== Presented by: Reza Saadatyar ==========================
% ================= E-mail: Reza.Saadatyar92@gmail.com =====================
clc;            % Clear command window
clear;          % Clear workspace variables
close all;      % Close all figures
%% ------------ Step 1: Convert gdf data to mat using biosig4octmat -------------
% biosig4octmat ---> biosig ---> run the install code
addpath(genpath(cd)) % Add the current directory and its subfolders to the path
% Let the user select gdf file(s)
filename = uigetfile({'*.gdf','gdf file';'*.*','All Files'},'File Selection','multiselect','off');
[Signal, Inform] = sload(filename); % Load gdf data into Signal and Inform variables
%% ------- Step 2: Define stimulation labels and extract trial information ------
% Inform.EVENT.TYP:
% 33024 ---> rest
% Label_01 ---> 13Hz stimulation (33025)
% Label_02 ---> 21Hz stimulation (33026)
% Label_03 ---> 17Hz stimulation (33027).
Labels = Inform.EVENT.TYP; % Define labels for each stimulation frequency
Time_start_trial = Inform.EVENT.POS; % Get the start time of each trial
Fs = 256; % Define sampling frequency
Time_trial = 5; % Define the duration of each trial in seconds
Duration_trial = Fs * Time_trial;  % Fs * time each trial
Numb_Channels = 8; % Number of EEG channels

for i = 1:3 % Loop through each stimulation label
    Lab = [33025, 33026, 33027];  % Define the labels for the current iteration
    Numb_Trials = find(Labels == Lab(i)); % Find indices of trials with the current label
    
    % Initialize an array to store trial data for the current label
    Data = zeros(Duration_trial, Numb_Channels, length(Numb_Trials));

    for j = 1:length(Numb_Trials) % Iterate over each trial index and extract the corresponding data
        Data(:, :, j) = Signal(Time_start_trial(Numb_Trials(j)):Time_start_trial(Numb_Trials(j)) + Duration_trial - 1, :);
    end
    
    eval(['Data_' num2str(i) ' = Data;']) % Use eval to dynamically create variable names for each trial's data array
end