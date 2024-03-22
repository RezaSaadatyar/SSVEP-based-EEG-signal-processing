import numpy as np
from scipy import signal

# ================================================ Filtering =============================================================  
def filtering(data, f_low, f_high, order, fs, type_filter): # Function to apply digital filtering to data
    
    if type(data).__name__ != 'ndarray': # Convert data to ndarray if it's not already
        data = np.array(data)
    if data.ndim > 1 and data.shape[0] > data.shape[1]: # Transpose data if it has more columns than rows
        data = data.T
        
    f_low = f_low / (fs / 2) # Normalize frequency values
    f_high = f_high / (fs / 2)
    
    if type_filter == "low": # Design Butterworth filter based on the specified type
        b, a = signal.butter(order, f_low, btype='low')
    elif type_filter == "high":
        b, a = signal.butter(order, f_high, btype='high')
    elif type_filter == "bandpass":
        b, a = signal.butter(order, [f_low, f_high], btype='bandpass')
    elif type_filter == "bandstop":
        b, a = signal.butter(order, [f_low, f_high], btype='bandstop')
        
    data_filter = signal.filtfilt(b, a, data) # Apply the digital filter using filtfilt to avoid phase distortion
    
    return data_filter  