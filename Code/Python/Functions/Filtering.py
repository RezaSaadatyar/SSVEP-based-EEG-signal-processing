import numpy as np
from scipy import signal

# =============================================== Filtering ==================================================
# Function to apply digital filtering to data
def filtering(data, f_low, f_high, order, fs, notch_freq, quality_factor, filter_active="on", notch_filter="on",
              type_filter='bandpass'):
    """
    =============================== Presented by: Reza Saadatyar (2023-2024) =================================
    ================================ E-mail: Reza.Saadatyar@outlook.com ======================================
    FILTERING applies digital filtering to data.
    Inputs:
    - data: Input data to be filtered.
    - f_low: Low cutoff frequency.
    - f_high: High cutoff frequency.
    - order: Filter order.
    - fs: Sampling frequency.
    - notch_freq: Frequency to be notched out.
    - filter_active: Activate filtering ('on' or 'off').
    - notch_filter: Activate notch filtering ('on' or 'off').
    - type_filter: Type of filter ('low', 'high', 'bandpass', 'stop').
    Output:
    - filtered_data: Filtered data.
    ================================== Flowchart for the filtering function ==================================
    Start
     1. Normalize frequency values (f_low, f_high)
     2. Check the dimensions of the input data:
        a. If it's a 3D matrix and has more rows than columns:
           - Transpose the data using permute to make channels as slices
        b. If it has more columns than rows:
           - Transpose the data to make channels as rows
     3. Design Butterworth filter based on the specified type:
        - Lowpass filter: Design Butterworth filter with 'low' option
        - Highpass filter: Design Butterworth filter with 'high' option
        - Bandpass filter: Design Butterworth filter with 'bandpass' option
        - Bandstop filter: Design Butterworth filter with 'bandstop' option
     4. Design a notch filter:
        - Use iirnotch to design a notch filter based on notch frequency and quality factor
     5. Notch filter:
        - Apply notch filtering if notch_filter is 'on'
     6. Apply the digital filter using filtfilt:
        - Apply filtering if filter_active is 'on'
     7. Output the filtered data (filtered_data)
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
    if type_filter == "low":     
        b, a = signal.butter(order, f_low, btype='low')
    elif type_filter == "high":
        b, a = signal.butter(order, f_high, btype='high')
    elif type_filter == "bandpass":
        b, a = signal.butter(order, [f_low, f_high], btype='bandpass')
    elif type_filter == "bandstop":
        b, a = signal.butter(order, [f_low, f_high], btype='bandstop')
    
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