import numpy as np

# ============================================== psda_analysis ===============================================
def psda_analysis(data, f_stim, num_sample_neigh, fs, num_harmonic):
    """
    =============================== Presented by: Reza Saadatyar (2023-2024) =================================
    ================================ E-mail: Reza.Saadatyar@outlook.com ======================================
    Calculate the Power Spectral Density Amplitude (PSDA) for all trials.
    Inputs:
        - data: EEG data matrix with dimensions (number of samples, number of channels).
        - f_stim: Array of frequencies of stimulation.
        - num_sample_neigh: Number of samples in the frequency neighborhood for each stimulation frequency.
        - fs: Sampling frequency.
        - num_harmonic: Number of harmonics for each stimulation frequency.
    Output:
        - psda: Array containing the maximum PSDA values for each stimulation frequency.
    =============================== Flowchart for the psda_analysis function =================================
    Start
    1. Convert data to ndarray if it's not already
    2. Transpose the data if it has more columns than rows
    3. Calculate the step size for the frequency neighborhood (step)
    4. Create the frequency axis (f)
    5. Initialize an array to store PSDA values (psda)
    6. Loop over each stimulation frequency (f_stim):
    a. Initialize a matrix to store PSD values for each channel (ps)
    b. Loop over each channel in the EEG data:
        i. Perform Fourier transform on the channel's data
        ii. Compute power spectral density (psd)
        iii. Loop over each harmonic:
            - Find indices around stimulation frequency and frequency neighborhood
            - Compute PSDA and store in the ps matrix
    c. Store the maximum PSDA value for the current stimulation frequency in psda
    Output: psda (Array containing the maximum PSDA values for each stimulation frequency)
    End
    ==========================================================================================================
    """
    # ------------------------ Convert data to ndarray if it's not already -----------------------------------
    data = np.array(data) if not isinstance(data, np.ndarray) else data

    # Transpose the data if it has more than one dimension and has fewer rows than columns
    data = data.T if data.ndim > 1 and data.shape[0] < data.shape[-1] else data
    
    # Number of frequency neighborhood for each stimulation frequency
    step = fs * (num_sample_neigh / 2) / data.shape[0]
    f = np.linspace(0, fs / 2, int(data.shape[0] / 2) + 1)  # Frequency axis

    psda = np.zeros((len(f_stim), 1))  # Initialize array to store PSDA values
    
    predict_label = np.zeros(data.shape[-1])
    
    for ind in range(data.shape[-1]):
        x = data[:, :, ind]

        for i, val in enumerate(f_stim):  # Loop over each stimulation frequency
            
            # Initialize matrix to store PSD values for each channel
            ps = np.zeros((x.shape[1], num_harmonic))  
            
            for j in range(x.shape[1]):  # Loop over each channel
                x_fft = np.fft.fft(x[:, j], n=x[:, j].shape[0])  # Perform Fourier transform
                x_fft = x_fft[:int(x[:, j].shape[0] / 2) + 1]  # Take one-sided spectrum
                psd = np.abs(x_fft) ** 2  # Compute power spectral density

                for h in range(1, num_harmonic + 1): # Loop over each harmonic
                    # Find indices around stimulation frequency
                    ind_fk = np.where((f >= h * val - 0.2) & (f <= h * val + 0.2))[0]
                    # Find indices for frequency neighborhood
                    ind_h = np.where((f >= h * val - step) & (f <= h * val + step))[0]

                    # Compute PSDA and plot PSD in the neighborhood
                    ps[j, h-1] = 10 * np.log10((num_sample_neigh * max(psd[ind_fk])) / (np.sum(psd[ind_h]) -
                                                                                        max(psd[ind_fk])))
            # Store maximum PSDA value for the current stimulation frequency
            psda[i] = np.max(np.max(ps, axis=1)) 
            
        predict_label[ind] = np.argmax(psda)

    return predict_label
