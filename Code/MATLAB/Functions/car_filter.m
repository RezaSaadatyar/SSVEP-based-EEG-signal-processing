function data = car_filter(data)
% CAR_FILTER performs Common Average Referencing (CAR) filtering on EEG data.
%
% Inputs:
%   - data: EEG data in the form of a 3D matrix, where each row represents a channel,
%           each column represents a time point, and each slice represents a trial.
%
% Output:
%   - data: CAR-filtered EEG data.

% Transpose data if it has more rows than columns
if ndims(data) > 2 && size(data, 1) < size(data, 3)
    data = permute(data, [3, 2, 1]);
elseif size(data, 1) < size(data, 2)
    data = data';
end

% Calculate the average potential across all electrodes for each trial
average_potential = mean(data, 2, 'omitnan'); % Vectorized Common Average Referencing (CAR)

% Subtract the average potential from each electrode's potential
data = data - average_potential;
end