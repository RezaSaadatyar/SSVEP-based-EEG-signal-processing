function data = car_filter(data)

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
