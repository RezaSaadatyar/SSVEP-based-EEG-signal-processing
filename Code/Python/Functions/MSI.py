import numpy as np

# ================================ Multivariate synchronization index (MSI) ==================================
def msi(data, fs, f_stim, num_channel, num_harmonic):
    """
    Parameters:
    - data: EEG data matrix with dimensions (number of samples, number of channels, number of trials).
    - fs: Sampling frequency of the EEG data.
    - f_stim: Array of frequencies for stimulation.
    - num_channel: Index of the channel to analyze.
    - num_harmonic: Number of harmonic frequencies for each stimulation frequency.
     ===================================== Flowchart for the msi function ====================================
    Start
    1. Convert data to a numpy array if it's not already in that format.
    2. Transpose the data if necessary to ensure proper dimensions.
    3. Initialize an empty list data_ref to store reference signals.
    4. Generate a time vector based on the sampling frequency.
    5. Iterate over each stimulation frequency (val) in f_stim:
        a. Initialize an empty list signal_ref to store reference signals for the current stimulation frequency.
        b. Generate sine and cosine signals for each harmonic frequency and append them to signal_ref.
        c. Stack the sine and cosine signals along the second axis to form the reference signal.
        d. Append the reference signal to data_ref.
    6. Initialize an array predict_label to store predicted labels for each trial.
    7. Iterate over each trial (i) in the EEG data:
        a. Initialize an array coeff to store correlation coefficients.
        b. Iterate over each stimulation frequency (k) and its index:
            i. Perform MSI analysis between the data for the current trial and the reference signal.
            ii. Store the MSI coefficient in the coeff array.
        c. Predict the label for the current trial based on the maximum MSI coefficient.
    8. Return the array of predicted labels.
    End
    ==========================================================================================================
    """
    # --------------------------- Convert data to ndarray if it's not already --------------------------------
    data = np.array(data) if not isinstance(data, np.ndarray) else data

    # Transpose the data if it has more than one dimension and has fewer rows than columns
    data = data.T if data.ndim > 1 and data.shape[0] < data.shape[-1] else data
    # ---------------------------------------- Reference signal ----------------------------------------------
    data_ref = []
    time = np.linspace(0, data.shape[0] / fs, data.shape[0])  # Time vector
    
    for _, val in enumerate(f_stim): # First loop: frequencies stimulation

        signal_ref = []

        for j in range(1, num_harmonic + 1):  # Generate a reference signal for each frequency stimulation
            signal_ref.append(np.sin(2 * np.pi * j * val * time))
            signal_ref.append(np.cos(2 * np.pi * j * val * time))

        data_ref.append(np.stack(signal_ref, axis=1))  # Store data_ref in the data_ref_list
    # --------------------------------------- Correlation Analysis -------------------------------------------
    predict_label = np.zeros(data.shape[-1])  # Initialize predict_label array with zeros
    
    for i in range(data.shape[-1]): # Loop through all Trials
        
        coeff = np.zeros(len(f_stim))

        for k in range(len(f_stim)):  # Second loop: Calculate MSI for frequencies stimulation
            coeff[k] = msi_analysis(data[:, num_channel, i], data_ref[k]) 
        
        predict_label[i] = np.argmax(coeff) # Predict label for the current trial
  
    return predict_label


# =============================================== MSI ========================================================
# Perform msi analysis for multiple channels
def msi_analysis(data, data_ref):
    """
    =============================== Presented by: Reza Saadatyar (2023-2024) =================================
    ================================ E-mail: Reza.Saadatyar@outlook.com ======================================
    Parameters:
    - data: EEG data matrix with dimensions (number of samples, number of channels).
    - data_ref: Reference signal matrix with dimensions (number of samples, number of channels).
    ==================================== Flowchart for the msi function ======================================
    Start
    1. Convert data and data_ref to numpy arrays if they are not already in that format.
    2. Transpose the data if necessary to ensure proper dimensions.
    3. Calculate the number of channels in the data.
    4. Compute the covariance matrix c of the concatenated data and reference signal.
    5. Split the covariance matrix into submatrices:
        a. c1: Covariance matrix of the EEG data.
        b. c2: Covariance matrix of the reference signal.
        c. c12: Cross-covariance matrix between EEG data and reference signal.
        d. c21: Transpose of c12.
    6. Set negative values in c1 and c2 to zero to ensure positive semi-definiteness.
    7. Compute the transformed correlation matrices:
        a. r1: Identity matrix corresponding to the EEG data.
        b. r2: Identity matrix corresponding to the reference signal.
        c. r12: Transformed correlation matrix between EEG data and reference signal.
        d. r21: Transformed correlation matrix between the reference signal and EEG data.
        e. r: Stack r1, r12, r21, and r2 to form the complete transformed correlation matrix.
    8. Compute the eigenvalues of the transformed correlation matrix.
    9. Set any negative eigenvalues to a small positive value (eps).
    10. Normalize the eigenvalues by dividing each by the sum of all eigenvalues.
    11. Calculate the synchronization index (s) between the EEG data and the reference signal using the 
    normalized eigenvalues.
    12. Return the synchronization index (s).
    End
    ==========================================================================================================
    """
    data = np.array(data) if not isinstance(data, np.ndarray) else data
    data_ref = np.array(data_ref) if not isinstance(data_ref, np.ndarray) else data_ref

    # Transpose the data if it has more than one dimension and has fewer rows than columns
    data, data_ref = [x.T if x.ndim > 1 and x.shape[0] < x.shape[-1] else x for x in [data, data_ref]]
    # --------------------------------- Calculate covariance matrices ----------------------------------------
    num_channel = data.shape[1]
    c = np.cov(np.hstack((data, data_ref)), rowvar=False)
    c1 = c[:num_channel, :num_channel]
    c2 = c[num_channel:, num_channel:]
    c12 = c[:num_channel, num_channel:]
    c21 = c[num_channel:, :num_channel]
    c1[c1 < 0], c2[c2 < 0] = 0, 0
    # --------------------------------- Transformed correlation matrix ---------------------------------------
    eps = np.finfo(float).eps
    r1 = np.eye(num_channel)
    r2 = np.eye(2 * int(data_ref.shape[1] / 2))
    r12 = np.real(np.linalg.inv(np.sqrt(c1) + eps * np.eye(c1.shape[0])) @ c12 @ np.linalg.inv(np.sqrt(c2) + 
                  eps * np.eye(c2.shape[0])))
    r21 = np.real(np.linalg.inv(np.sqrt(c2) + eps * np.eye(c2.shape[0])) @ c21 @ np.linalg.inv(np.sqrt(c1) + 
                  eps * np.eye(c1.shape[0])))
    r = np.vstack((np.hstack((r1, r12)), np.hstack((r21, r2))))
    # ------------------------------------- Eigenvalues of matrix --------------------------------------------
    eig_vals, _ = np.linalg.eig(r)    # Landa
    eig_vals[eig_vals < 0] = eps
    eig_vals = np.real(eig_vals)
    # landa = np.diag(landa)
    eig_vals /= np.sum(eig_vals)     # Normalize eigenvalues

    # --------------------------- Synchronization index between two signals ----------------------------------
    s = 1 + (np.sum(eig_vals * np.log(eig_vals)) / np.log(num_channel + 2 * int(data_ref.shape[1] / 2)))
    
    return s

