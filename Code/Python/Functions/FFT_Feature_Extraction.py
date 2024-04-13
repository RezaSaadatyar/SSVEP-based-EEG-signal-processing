import numpy as np

# ========================================== FFT_Feature_Extraction ==========================================
def fft_feature_extraction(data, fs, num_channel, subbands):
    """
    =============================== Presented by: Reza Saadatyar (2023-2024) =================================
    ================================ E-mail: Reza.Saadatyar@outlook.com ======================================
    Parameters:
    - data: EEG data matrix with dimensions (number of samples, number of channels, number of trials).
    - fs: Sampling frequency.
    - num_channel: List or array of channel indices to consider for feature extraction.
    - subbands: List or array of tuples specifying the frequency subbands.
    ========================== Flowchart for the fft_feature_extraction function =============================
    Start
    1. Convert data to a numpy array if it's not already in that format.
    2. Transpose the data if necessary to ensure proper dimensions.
    3. Calculate the frequency vector f using the sampling frequency fs.
    4. Initialize an array `features` to store the extracted features, with dimensions (number of trials, 
    number of subbands * number of channels).
    5. Loop over each trial in the data:
        a. Compute the FFT (Fast Fourier Transform) of the EEG data for the selected channels.
        b. Compute the power spectral density (PSD) by taking the absolute value of the FFT and selecting 
        only the positive frequency components.
        c. Loop over each subband:
            i. Find the indices corresponding to the frequency subband.
            ii. Extract the maximum PSD within the subband for each channel and update the `features` array.
    6. Return the `features` array.
    End
    ==========================================================================================================
    """
    # --------------------------- Convert data to ndarray if it's not already --------------------------------
    data = np.array(data) if not isinstance(data, np.ndarray) else data
    
    # Transpose the data if it has more than one dimension and has fewer rows than columns
    data = data.T if data.ndim > 1 and data.shape[0] < data.shape[-1] else data
    
    f = np.linspace(0, fs / 2, data.shape[0] // 2 + 1) # Calculate frequency vector
    features = np.zeros((data.shape[-1], np.array(subbands).shape[1] * len(num_channel)))

    for i in range(data.shape[-1]):
        data_fft = np.fft.fft(data[:, num_channel, i], axis=0) # Compute FFT
        data_psd = np.abs(data_fft[:len(data_fft) // 2, :])    # Compute power spectral density (PSD)
        
        for ind_sb, (val_sb1, val_sb2) in enumerate(zip(*subbands)): # Feature extraction for each subband
            # Find indices corresponding to the subband
            ind = np.where((f >= val_sb1) & (f <= val_sb2))[0]
            
            # Update features with maximum PSD within subband
            features[i, ind_sb * len(num_channel):(ind_sb + 1) * len(num_channel)] = np.max(data_psd[ind, :],
                                                                                        axis=0)

    return features