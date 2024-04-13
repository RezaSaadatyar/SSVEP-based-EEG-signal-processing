import numpy as np

# ============================================== CAR Filter ==================================================
def car(data, reference_channel=None):
    """
    =============================== Presented by: Reza Saadatyar (2023-2024) =================================
    ================================ E-mail: Reza.Saadatyar@outlook.com ======================================
    Computes the common average reference (CAR) for EEG signals.
    Parameters:
    - data: EEG data matrix with dimensions (number of samples, number of channels, number of trials).
    - reference_channel: Index of the reference channel for CAR. If None, the average potential across all 
    electrodes is used.
    ================================== Flowchart for the car_filter function =================================
    Start
    1. Convert data to a NumPy array if it's not already.
    2. Transpose the data if it has more than one dimension and fewer rows than columns.
    3. Create a copy of the data and assign it to data_car.
    4. Transpose data_car if it has more than one dimension and fewer rows than columns.
    5. If reference_channel is not None:
        a. Create an array of channel indices excluding the reference channel.
        b. If data_car has more than two dimensions (trials included):
            i. Subtract the reference signal from each electrode's potential for each trial.
        c. If data_car has two dimensions:
            i. Subtract the reference signal from each electrode's potential.
    6. If reference_channel is None:
        a. Calculate the average potential across all electrodes for each trial.
        b. Subtract the average potential from each electrode's potential for each trial.
    End
    ==========================================================================================================
    """
    # ---------------------------- Convert data to ndarray if it's not already -------------------------------
    data = np.array(data) if not isinstance(data, np.ndarray) else data
    
    data_car = data.copy()
    
    # Transpose the data if it has more than one dimension and has fewer rows than columns
    data_car = data_car.T if data_car.ndim > 1 and data_car.shape[0] < data_car.shape[-1] else data_car
    
    if reference_channel is not None:
        # Subtract the reference signal from each electrode's potential
        channels = np.delete(np.arange(data_car.shape[1]), reference_channel)
        
        if data_car.ndim > 2:
            data_car[:, channels, :] -= np.reshape(data_car[:, reference_channel, :], (data_car.shape[0], 1, 
                                                                                       data_car.shape[-1]))
        else:
            data_car[:, channels] -= data_car[:, reference_channel].reshape(-1, 1)
    else:
        # Calculate the average potential across all electrodes for each trial
        average_potential = np.mean(data_car, axis=1, keepdims=True) 

        # Subtract the average potential from each electrode's potential
        data_car -= average_potential

    return data_car