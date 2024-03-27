import numpy as np
from scipy import signal
import pandas as pd 
# ================================================ Filtering =============================================================  
# Function to apply digital filtering to data
def filtering(data, f_low, f_high, order, fs, notch_freq, quality_factor, filter_active="on", notch_filter="on", 
              type_filter='bandpass'): 
    # ------------------------------------ Normalize frequency values ------------------------------------
    f_low = f_low / (fs / 2)     
    f_high = f_high / (fs / 2)
    
    filtered_data = data.copy()           # Make a copy of the input data
    # -------------------------- Convert data to ndarray if it's not already -----------------------------
    filtered_data = np.array(filtered_data) if not isinstance(filtered_data, np.ndarray) else filtered_data
    # ------------------------ Transpose data if it has more rows than columns ---------------------------
    filtered_data = filtered_data.T if filtered_data.ndim > 1 and filtered_data.shape[0] > filtered_data.shape[-1] else filtered_data
    # --------------------- Design Butterworth filter based on the specified type ------------------------
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
    # ------------------------------------------- Notch filter -------------------------------------------
    if notch_filter == "on":
        if filtered_data.ndim == 3:
            for i in range(filtered_data.shape[0]):
                filtered_data[i, :, :] = signal.filtfilt(b_notch, a_notch, filtered_data[i, :, :])
        elif filtered_data.ndim < 3:
            filtered_data = signal.filtfilt(b_notch, a_notch, filtered_data)
     # -------------- Apply the digital filter using filtfilt to avoid phase distortion ------------------
    if filter_active == "on":
        if filtered_data.ndim == 3:
            for i in range(filtered_data.shape[0]):
                filtered_data[i, :, :] = signal.filtfilt(b, a, filtered_data[i, :, :])
        elif filtered_data.ndim < 3:
            filtered_data = signal.filtfilt(b, a, filtered_data)
    # ------------------------ Transpose data if it has more columns than rows ---------------------------
    filtered_data = filtered_data.T if filtered_data.ndim > 1 and filtered_data.shape[0] < filtered_data.shape[-1] else filtered_data

    return filtered_data

#  if type(filtered_data).__name__ != 'ndarray': 
#         filtered_data = np.array(filtered_data)