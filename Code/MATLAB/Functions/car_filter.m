function data = car_filter(data)
% ================================== (2023-2024) ======================================
% ======================== Presented by: Reza Saadatyar ===============================
% ====================== E-mail: Reza.Saadatyar@outlook.com ===========================

% CAR_FILTER performs Common Average Referencing (CAR) filtering on EEG data.
% Inputs:
%   - data: EEG data in the form of a 3D matrix, where each row represents a channel,
%           each column represents a time point, and each slice represents a trial.
% Output:
%   - data: CAR-filtered EEG data.
%% ====================== Flowchart for the car_filter function =======================
% Start
% Input: EEG data (data)
% 1. Check the dimensions of the EEG data:
%    a. If it's a 3D matrix and has more rows than columns:
%       - Transpose the data using permute to make channels as slices
%    b. If it has more columns than rows:
%       - Transpose the data to make channels as rows
% 2. Calculate the average potential across all electrodes for each trial:
%    - Compute the mean along the second dimension, ignoring NaN values
% 3. Subtract the average potential from each electrode's potential:
%    - Perform element-wise subtraction of the average potential from the data
% Output: CAR-filtered EEG data (data)
% End
%% ====================================================================================
% Transpose data if it has more rows than columns
if ndims(data) > 2 && size(data, 1) < size(data, 3)
    data = permute(data, [3, 2, 1]);
elseif size(data, 1) < size(data, 2)
    data = data';
end

% Calculate the average potential across all electrodes for each trial
average_potential = mean(data, 2, 'omitnan'); % Vectorized Common Average Referencing

% Subtract the average potential from each electrode's potential
data = data - average_potential;
end