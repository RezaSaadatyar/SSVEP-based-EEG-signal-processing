import numpy as np
from scipy import signal

# ================================================ Filtering =============================================================  
# Function to apply digital filtering to data
def filtering(data, f_low, f_high, order, fs, notch_freq, quality_factor, filter_active="on", notch_filter="on", 
              type_filter='bandpass'): 
    # ------------------------------------ Normalize frequency values ------------------------------------
    f_low = f_low / (fs / 2)     
    f_high = f_high / (fs / 2)
    # -------------------------- Convert data to ndarray if it's not already -----------------------------
    if type(data).__name__ != 'ndarray': 
        data = np.array(data)
    # ------------------------ Transpose data if it has more rows than columns ---------------------------
    data = data.T if data.ndim > 1 and data.shape[0] > data.shape[-1] else data
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
        if data.ndim == 3:
            for i in range(data.shape[0]):
                data[i, :, :] = signal.filtfilt(b_notch, a_notch, data[i, :, :])
        elif data.ndim < 3:
            data = signal.filtfilt(b_notch, a_notch, data)
     # -------------- Apply the digital filter using filtfilt to avoid phase distortion ------------------
    if filter_active == "on":
        if data.ndim == 3:
            for i in range(data.shape[0]):
                data[i, :, :] = signal.filtfilt(b, a, data[i, :, :])
        elif data.ndim < 3:
            data = signal.filtfilt(b, a, data)
    # ------------------------ Transpose data if it has more columns than rows ---------------------------
    data = data.T if data.ndim > 1 and data.shape[0] < data.shape[-1] else data

    return data