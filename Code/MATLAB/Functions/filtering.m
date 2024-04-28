function filtered_data = filtering(data, f_low, f_high, order, fs, notch_freq, ...
                                   filter_active, notch_filter, type_filter, design_method) 
% ================================== (2023-2024) ======================================
% ======================== Presented by: Reza Saadatyar ===============================
% ====================== E-mail: Reza.Saadatyar@outlook.com ===========================
% Example:
% fs = 256;                  % Sampling frequency
% order = 3; 
% f_low = 0.5;
% f_high = 100;
% notch_freq = 50;
% notch_filter = 'on';
% filter_active = 'on';
% design_method = "IIR";      % IIR, FIR
% type_filter = "bandpass";   % low, high, bandpass
% filtered_data = filtering(data_total, f_low, f_high, order, fs, notch_freq, filter_active, ...
%     notch_filter, type_filter, design_method);

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
%% ======================== Flowchart for the filtering function ======================
% Start
% 1. Normalize the frequency values by dividing them by half the sampling frequency 
% (Nyquist frequency).
% 2. Transpose the data if it has more rows than columns or if specified by the user.
% 3. Design the filter based on the specified parameters and filter type:
%    a. If the design method is IIR:
%       - Design Butterworth filter using the 'butter' function.
%    b. If the design method is FIR:
%       - Design FIR filter using the 'fir1' function. 
% 4. Design a notch filter if specified by the user using the 'butter' function.
% 5. Apply the notch filter to the data if specified by the user using 'filtfilt'.
% 6. Apply the designed filter to the data if active using 'filtfilt'.
% 7. Return the filtered data.
% End
%% ====================================================================================
% Normalize frequency values
f_low = f_low / (fs / 2);
f_high = f_high / (fs / 2);

% Transpose data if it has more rows than columns
if ndims(data) > 2 && size(data, 1) < size(data, 3)
    data = permute(data, [3, 2, 1]);
elseif size(data, 1) < size(data, 2)
    data = data';
end
if strcmp(design_method, 'IIR')
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
else
    a = 1;
    if strcmp(type_filter, 'low')
        b = fir1(order, f_low, 'low');
    elseif strcmp(type_filter, 'high')
        b = fir1(order, f_high, 'high');
    elseif strcmp(type_filter, 'bandpass')
        b = fir1(order, [f_low, f_high], 'bandpass');
    elseif strcmp(type_filter, 'bandstop')
        b = fir1(order, [f_low, f_high], 'stop');
    end
end
% Design a notch filter
[b_notch, a_notch] = butter(3, [notch_freq - 0.5, notch_freq + 0.5]/(fs/2), 'stop');

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
