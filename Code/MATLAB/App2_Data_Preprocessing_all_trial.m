% =========================== SSVEP (2023-2024) ============================
% ================== Presented by: Reza Saadatyar ==========================
% ================= E-mail: Reza.Saadatyar92@gmail.com =====================
clc;            % Clear command window
clear;          % Clear workspace variables
close all;      % Close all figures
%% ------------ Step 1: Convert gdf data to mat using biosig4octmat -------------
% Load gdf data into Signal and Inform variables using biosig4octmat
addpath(genpath(cd)) % Add the current directory and its subfolders to the MATLAB search path
% Let the user select gdf file(s)
[filename, path] = uigetfile({'*.gdf','gdf file';'*.*','All Files'},'File Selection','multiselect','on');
%% --------------------- Step 2: Access data folders-----------------------------
Fs = 256;       % Define sampling frequency
Time_trial = 5; % Define the duration of each trial in seconds
% Calculate the duration of each trial in samples based on the sampling frequency
Duration_trial = Fs * Time_trial;
Numb_Channels = 8; % Number of EEG channels
for i = 1:length(filename) % Loop through each selected filename, First loop ---> read all data
    [Signal, Inform] = sload(filename{i}); % Load gdf data into Signal and Inform variables
    %% -------------------------------- Step 3: Split trials -----------------------
    Labels = Inform.EVENT.TYP; % Define labels for each stimulation frequency
    Time_start_trial = Inform.EVENT.POS; % Get the start time of each trial
    
    for j = 1:3    % Loop through each label 
        Lab = [33025, 33026, 33027];
        Numb_Trials = find(Labels == Lab(j)); % Find indices of trials with the current label
        % Initialize an array to store trial data for the current label
        Data = zeros(Duration_trial, Numb_Channels, length(Numb_Trials));
        % Loop through each trial index and extract the corresponding data
        for k = 1:length(Numb_Trials) % Third loop ---> Sorting trials based on each label in the Signal
            % Append data to existing Data variables if they exist
            if exist('Data1', 'var') && (i > 1) && (j == 1)
                Data1(:, :, size(Data1, 3) + 1) = Signal(Time_start_trial(Numb_Trials(k)):Time_start_trial(Numb_Trials(k)) + Duration_trial - 1,:);
            elseif exist('Data2','var') && (i > 1) && (j == 2)
                Data2(:, :, size(Data2, 3) + 1) = Signal(Time_start_trial(Numb_Trials(k)):Time_start_trial(Numb_Trials(k)) + Duration_trial - 1,:);
            elseif exist('Data3','var') && (i > 1) && (j == 3)
                Data3(:, :, size(Data3, 3) + 1) = Signal(Time_start_trial(Numb_Trials(k)):Time_start_trial(Numb_Trials(k)) + Duration_trial - 1,:);
            else
                Data(:, :, k) = Signal(Time_start_trial(Numb_Trials(k)):Time_start_trial(Numb_Trials(k)) + Duration_trial - 1,:);
            end
        end
        % Create new Data variables if they don't exist
        if exist('Data1','var') == 0 || exist('Data2','var') == 0 || exist('Data3','var') == 0
            eval(['Data' num2str(j)  ' = Data;'])
        end
    end
end
%% Save the data
filename = fullfile(path, 'data.mat'); % Construct the full file path
save(filename, 'Data1', 'Data2', 'Data3'); % Save your variables to the specified location