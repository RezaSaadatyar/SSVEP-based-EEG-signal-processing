function filtered_data = filtering(data, f_low, f_high, order, fs, notch_freq, ...
    filter_active, notch_filter, quality_factor, type_filter) 

    % Filtering Applies digital filtering to data
    %   data: Input data to be filtered
    %   f_low: Low cutoff frequency
    %   f_high: High cutoff frequency
    %   order: Filter order
    %   fs: Sampling frequency
    %   notch_freq: Frequency to be notched out
    %   quality_factor: Quality factor for the notch filter
    %   filter_active: Activate filtering ('on' or 'off')
    %   notch_filter: Activate notch filtering ('on' or 'off')
    %   type_filter: Type of filter ('low', 'high', 'bandpass', 'stop')

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