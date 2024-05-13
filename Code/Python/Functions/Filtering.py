import numpy as np
from scipy import signal

# =============================================== Filtering ==================================================
# Function to apply digital filtering to data
def filtering(data, f_low, f_high, order, fs, notch_freq, quality_factor, filter_active="on", notch_filter="on",
              type_filter='bandpass', design_method="IRR"):
    """
    =============================== Presented by: Reza Saadatyar (2023-2024) =================================
    ================================ E-mail: Reza.Saadatyar@outlook.com ======================================
    Example:
    fs = 256;                  % Sampling frequency
    order = 3; 
    f_low = 0.5;
    f_high = 100;
    notch_freq = 50;
    notch_filter = 'on';
    filter_active = 'on';
    design_method = "IIR";      % IIR, FIR
    type_filter = "bandpass";   % low, high, bandpass
    filtered_data = filtering(data_total, f_low, f_high, order, fs, notch_freq, filter_active,  notch_filter, 
                              type_filter, design_method)
                              
    FILTERING applies digital filtering to data.
    Inputs:
    - data: Input data to be filtered.
    - f_low: Low cutoff frequency.
    - f_high: High cutoff frequency.
    - order: Filter order.
    - fs: Sampling frequency.
    - notch_freq: Frequency to be notched out.
    - quality_factor: Quality factor for the notch filter.
    - filter_active: Activate filtering ('on' or 'off').
    - notch_filter: Activate notch filtering ('on' or 'off').
    - type_filter: Type of filter ('low', 'high', 'bandpass', 'stop').
    Output:
    - filtered_data: Filtered data.
    ================================== Flowchart for the filtering function ==================================
    Start
    1. Normalize the frequency values by dividing them by half the sampling frequency 
    (Nyquist frequency).
    2. Transpose the data if it has more rows than columns or if specified by the user.
    3. Design the filter based on the specified parameters and filter type:
        a. If the design method is IIR:
        - Design Butterworth filter using the 'butter' function.
        b. If the design method is FIR:
        - Design FIR filter using the 'fir1' function. 
    4. Design a notch filter if specified by the user using the 'butter' function.
    5. Apply the notch filter to the data if specified by the user using 'filtfilt'.
    6. Apply the designed filter to the data if active using 'filtfilt'.
    7. Return the filtered data.
    End
    ==========================================================================================================
    """
    # ---------------------------------------- Normalize frequency values ------------------------------------
    f_low = f_low / (fs / 2)
    f_high = f_high / (fs / 2)
    
    filtered_data = data.copy()           # Make a copy of the input data
    # ----------------------------- Convert data to ndarray if it's not already ------------------------------
    filtered_data = np.array(filtered_data) if not isinstance(filtered_data, np.ndarray) else filtered_data
    # ------------------------- Transpose data if it has more rows than columns ------------------------------
    filtered_data = filtered_data.T if filtered_data.ndim > 1 and filtered_data.shape[0] > filtered_data.shape[-1]\
    else filtered_data
    # ------------------------- Design Butterworth filter based on the specified type ------------------------
    if design_method == "IIR":
        if type_filter == "low":     
            b, a = signal.butter(order, f_low, btype='low')
        elif type_filter == "high":
            b, a = signal.butter(order, f_high, btype='high')
        elif type_filter == "bandpass":
            b, a = signal.butter(order, [f_low, f_high], btype='bandpass')
        elif type_filter == "bandstop":
            b, a = signal.butter(order, [f_low, f_high], btype='bandstop')
    else:
        a = 1
        if type_filter == "low":     
            b = signal.firwin(order, f_low, pass_zero='lowpass')
        elif type_filter == "high":
            b = signal.firwin(order, f_high, pass_zero='highpass')
        elif type_filter == "bandpass":
            b = signal.firwin(order, [f_low, f_high], pass_zero='bandpass')
        elif type_filter == "bandstop":
            b = signal.firwin(order, [f_low, f_high], pass_zero='bandstop')
    
    # Design a notch filter using signal.iirnotch
    b_notch, a_notch = signal.iirnotch(notch_freq, quality_factor, fs)
    # ------------------------------------------ Notch filter ------------------------------------------------
    if notch_filter == "on":
        if filtered_data.ndim == 3:
            for i in range(filtered_data.shape[0]):
                filtered_data[i, :, :] = signal.filtfilt(b_notch, a_notch, filtered_data[i, :, :])
        else:
            filtered_data = signal.filtfilt(b_notch, a_notch, filtered_data)
     # ------------------ Apply the digital filter using filtfilt to avoid phase distortion ------------------
    if filter_active == "on":
        if filtered_data.ndim == 3:
            for i in range(filtered_data.shape[0]):
                filtered_data[i, :, :] = signal.filtfilt(b, a, filtered_data[i, :, :])
        else:
            filtered_data = signal.filtfilt(b, a, filtered_data)
    # --------------------------- Transpose data if it has more columns than rows ----------------------------
    filtered_data = filtered_data.T if filtered_data.ndim > 1 and filtered_data.shape[0] < filtered_data.shape[-1]\
    else filtered_data

    return filtered_data

#  if type(filtered_data).__name__ != 'ndarray': 
#         filtered_data = np.array(filtered_data)