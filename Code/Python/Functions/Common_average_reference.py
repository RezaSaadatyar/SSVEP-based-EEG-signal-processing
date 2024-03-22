import numpy as np

# ================================================ CAR Filter ============================================================ 
def car(data):
    
    """
    Computes the common average reference (CAR) for EEG signals.

    Parameters:
    data (np.array): A 2D numpy array where each row represents the potential between an electrode and the reference.

    Returns:
    np.array: The CAR for each electrode.
    """
    
    if type(data).__name__ != 'ndarray': # Convert data to ndarray if it's not already
        data = np.array(data)
    if data.ndim > 1 and data.shape[0] < data.shape[1]: # Transpose data if it has more columns than rows
        data = data.T

    average_potential = np.mean(data, axis=1) # Calculate the average potential across all electrodes                                             
 
    data_car = data - average_potential.reshape(-1, 1) # Subtract the average potential from each electrode's potential
    
    return data_car