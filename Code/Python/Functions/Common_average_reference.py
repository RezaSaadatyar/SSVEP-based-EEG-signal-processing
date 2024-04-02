import numpy as np

# ================================================= CAR Filter =====================================================
def car(data):
    
    """
    Computes the common average reference (CAR) for EEG signals.
    Parameters:
    data (np.array): A numpy array where each row represents the potential between an electrode and the reference.
    Returns:
    np.array: The CAR for each electrode.
    ==================================== Flowchart for the car_filter function =====================================
    Start
    1. Convert data to a NumPy array if it's not already.
    2. Create a copy of the data array to store the Common Average Reference (CAR) values.
    3. Transpose the data if it has more than one dimension and has fewer rows than columns.
    4. Calculate the average potential across all electrodes for each trial.
    5. Subtract the average potential from each electrode's potential to compute the CAR.
    6. Return the data with the CAR applied.
    End
    ================================================================================================================
    """
    # ------------------------------ Convert data to ndarray if it's not already -----------------------------------
    data = np.array(data) if not isinstance(data, np.ndarray) else data
    
    data_car = data.copy()
    
    # Transpose the data if it has more than one dimension and has fewer rows than columns
    data_car = data_car.T if data_car.ndim > 1 and data_car.shape[0] < data_car.shape[-1] else data_car
    
    # Calculate the average potential across all electrodes for each trial
    average_potential = np.mean(data_car, axis=1, keepdims=True) # Vectorized Common Average Referencing (CAR)
    
    # Subtract the average potential from each electrode's potential
    data_car -= average_potential

    return data_car