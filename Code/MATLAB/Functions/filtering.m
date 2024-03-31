function filtered_data = filtering(data, f_low, f_high, order, fs, notch_freq, ...
    filter_active, notch_filter, quality_factor, type_filter) 
% FILTERING applies digital filtering to data.
% Inputs:
%   - data: Input data to be filtered.
%   - f_low: Low cutoff frequency.
%   - f_high: High cutoff frequency.
%   - order: Filter order.
%   - fs: Sampling frequency.
%   - notch_freq: Frequency to be notched out.
%   - quality_factor: Quality factor for the notch filter.
%   - filter_active: Activate filtering ('on' or 'off').
%   - notch_filter: Activate notch filtering ('on' or 'off').
%   - type_filter: Type of filter ('low', 'high', 'bandpass', 'stop').
% Output:
%   - filtered_data: Filtered data.
%% ==================== Flowchart for the filtering function =====================
% Start
% Inputs: Input data (data), low cutoff frequency (f_low), high cutoff frequency (f_high), filter order (order),
%         sampling frequency (fs), notch frequency (notch_freq), quality factor (quality_factor),
%         filter_active (filtering activation), notch_filter (notch filtering activation), type_filter (type of filter)
% 1. Normalize frequency values (f_low, f_high)
% 2. Check the dimensions of the input data:
%    a. If it's a 3D matrix and has more rows than columns:
%       - Transpose the data using permute to make channels as slices
%    b. If it has more columns than rows:
%       - Transpose the data to make channels as rows
% 3. Design Butterworth filter based on the specified type:
%    - Lowpass filter: Design Butterworth filter with 'low' option
%    - Highpass filter: Design Butterworth filter with 'high' option
%    - Bandpass filter: Design Butterworth filter with 'bandpass' option
%    - Bandstop filter: Design Butterworth filter with 'stop' option
% 4. Design a notch filter:
%    - Use iirnotch to design a notch filter based on notch frequency and quality factor
% 5. Notch filter:
%    - Apply notch filtering if notch_filter is 'on'
% 6. Apply the digital filter using filtfilt:
%    - Apply filtering if filter_active is 'on'
% 7. Output the filtered data (filtered_data)
% End
%% ===============================================================================
% Normalize frequency values
f_low = f_low / (fs / 2);
f_high = f_high / (fs / 2);

% Transpose data if it has more rows than columns
if ndims(data) > 2 && size(data, 1) < size(data, 3)
    data = permute(data, [3, 2, 1]);
elseif size(data, 1) < size(data, 2)
    data = data';
end

% Design Butterworth filter based on the specified type
if strcmp(type_filter, 'low')
    [b, a] = butter(order, f_low, 'low');
elseif strcmp(type_filter, 'high')
    [b, a] = butter(order, f_high, 'high');
elseif strcmp(type_filter, 'bandpass')
    [b, a] = butter(order, [f_low, f_high], 'bandpass');
elseif strcmp(type_filter, 'bandstop')
    [b, a] = butter(order, [f_low, f_high], 'stop');
end

% Design a notch filter
[b_notch, a_notch] = iirnotch(notch_freq / (fs/2), notch_freq / (fs/2) / quality_factor);

% Notch filter
if strcmp(notch_filter, 'on')
    if ndims(data) == 3
        for i = 1:size(data, 3)
            data(:, :, i) = filtfilt(b_notch, a_notch, data(:, :, i));
        end
    else
        data = filtfilt(b_notch, a_notch, data);
    end
end

% Apply the digital filter using filtfilt
if strcmp(filter_active, 'on')
    if ndims(data) == 3
        for i = 1:size(data, 3)
            data(:, :, i) = filtfilt(b, a, data(:, :, i));
        end
    else
        data = filtfilt(b, a, data);
    end
end

filtered_data = data;
end
