import numpy as np
from scipy import signal

# ================================================ Filtering =============================================================  
# Function to apply digital filtering to data
def filtering(data, f_low, f_high, order, fs, f_notch, notch_filter="on", type_filter='bandpass'): 
    # ------------------------------------ Normalize frequency values ------------------------------------
    f_low = f_low / (fs / 2)     
    f_high = f_high / (fs / 2)
    # -------------------------- Convert data to ndarray if it's not already -----------------------------
    if type(data).__name__ != 'ndarray': 
        data = np.array(data)
    # ------------------------ Transpose data if it has more rows than columns ---------------------------
    if data.ndim == 2 and data.shape[0] > data.shape[1]: 
        data = data.T
    elif data.ndim == 3 and data.shape[0] > data.shape[2]:
        data = data.T
    # --------------------- Design Butterworth filter based on the specified type ------------------------
    if type_filter == "low":     
        b, a = signal.butter(order, f_low, btype='low')
    elif type_filter == "high":
        b, a = signal.butter(order, f_high, btype='high')
    elif type_filter == "bandpass":
        b, a = signal.butter(order, [f_low, f_high], btype='bandpass')
    elif type_filter == "bandstop":
        b, a = signal.butter(order, [f_low, f_high], btype='bandstop')
    # ------------------------------------------- Notch filter -------------------------------------------
    if data.ndim == 3:
        for i in range(data.shape[0]):
            if notch_filter == "on":     
                b1, a1 = signal.butter(order, [(f_notch - 0.7) / fs / 2, (f_notch + 0.7) / fs / 2], btype='bandstop')
                data[i, :, :] = signal.filtfilt(b1, a1, data[i, :, :])
            # ----------- Apply the digital filter using filtfilt to avoid phase distortion --------------
            # data[i, :, :] = signal.filtfilt(b, a, data[i, :, :])
    elif data.ndim < 3:
        # ----------------------------------------- Notch filter -----------------------------------------
        if notch_filter == "on":     
            b1, a1 = signal.butter(order, [(f_notch - 0.6) / fs / 2, (f_notch + 0.6) / fs / 2], btype='bandstop')
            data = signal.filtfilt(b1, a1, data)
        # ------------- Apply the digital filter using filtfilt to avoid phase distortion ----------------    
        # data = signal.filtfilt(b, a, data) 
    # ------------------------ Transpose data if it has more columns than rows ---------------------------
    if data.ndim == 2 and data.shape[0] < data.shape[1]: 
        data = data.T
    elif data.ndim == 3 and data.shape[0] < data.shape[2]:
        data = data.T
        
    return data