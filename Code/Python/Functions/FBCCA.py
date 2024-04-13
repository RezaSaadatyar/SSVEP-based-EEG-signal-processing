import numpy as np
from scipy import signal

# ============================ Filter bank canonical correlation analysis (FBCCA) ============================
def fbcca_analysis(data, labels, fs, f_stim, num_channel, num_harmonic, a, b, filter_banks, order, notch_freq, 
                   quality_factor, filter_active, notch_filter, type_filter):
    """
    =============================== Presented by: Reza Saadatyar (2023-2024) =================================
    ================================ E-mail: Reza.Saadatyar@outlook.com ======================================
    Parameters:
    - data: EEG data matrix with dimensions (number of samples, number of channels, number of trials).
    - labels: Labels corresponding to each trial.
    - fs: Sampling frequency of the EEG data.
    - f_stim: Array of frequencies for stimulation.
    - num_channel: Index of the channel to analyze.
    - num_harmonic: Number of harmonic frequencies for each stimulation frequency.
    - a: Parameter a for weighting filter banks.
    - b: Parameter b for weighting filter banks.
    - filter_banks: List of tuples specifying the passbands for each filter bank.
    =================================== Flowchart for the fbcca function =====================================
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
    7. Create an array k representing the filter bank indices.
    8. Initialize an array coeff to store correlation coefficients.
    9. Initialize an empty list accuracy to store accuracy values.
    10. Iterate over each value of a (val_a) in the parameter a:
        a. Iterate over each value of b (val_b) in the parameter b:
            i. Compute the weighting factor phi based on k, val_a, and val_b.
            ii. Iterate over each trial (i) in the EEG data:
                - Iterate over each filter bank specified in filter_banks:
                    * Apply filtering to the EEG data for the current filter bank.
                    * Iterate over each stimulation frequency and its index (ind_fstim):
                        - Perform canonical correlation analysis (CCA) between the filtered data and reference
                          signal.
                        - Find the maximum correlation coefficient and store it in coeff.
                iii. Predict the label for the current trial based on the maximum correlation coefficient.
            iii. Calculate the accuracy of the predictions and append it to the accuracy list.
    11. Return the list of accuracy values.
    End
    ==========================================================================================================
    """
    # -------------------------- Convert data to ndarray if it's not already ---------------------------------
    data = np.array(data) if not isinstance(data, np.ndarray) else data

    # Transpose the data if it has more than one dimension and has fewer rows than columns
    data = data.T if data.ndim > 1 and data.shape[0] < data.shape[-1] else data
    # --------------------------------------- Reference signal -----------------------------------------------
    data_ref = []
    time = np.linspace(0, data.shape[0] / fs, data.shape[0])  # Time vector
    
    for _, val in enumerate(f_stim): # First loop: frequencies stimulation

        signal_ref = []

        for j in range(1, num_harmonic + 1):  # Generate a reference signal for each frequency stimulation
            signal_ref.append(np.sin(2 * np.pi * j * val * time))
            signal_ref.append(np.cos(2 * np.pi * j * val * time))

        data_ref.append(np.stack(signal_ref, axis=1))  # Store data_ref in the data_ref_list
    # --------------------------------------- Correlation Analysis -------------------------------------------
    predict_label = np.zeros(data.shape[-1])  # Initialize label_predic array with zeros
    k = np.arange(1, np.array(filter_banks).shape[-1] + 1, dtype=float) # Create the array k
    coeff = np.zeros((len([*filter_banks][0]), len(f_stim)))
    accuracy = []
    
    for _, val_a in enumerate(a):
        for _, val_b in enumerate(b):
            phi =  np.power(k, -val_a) + val_b    # Compute phi
            
            for i in range(data.shape[-1]):       # Loop through all Trials
                for ind_sb, (val_sb1, val_sb2) in enumerate(zip(*filter_banks)):
                    data_sub_banks = filtering(data[:, :, i], val_sb1, val_sb2, order, fs, notch_freq, 
                                               quality_factor, filter_active, notch_filter, type_filter)
                    # Second loop: Calculate CCA for frequencies stimulation
                    for ind_fstim, _ in enumerate(f_stim):  
                        cano_corr = cca_analysis(data_sub_banks[:, num_channel], data_ref[ind_fstim])
                        
                        # Calculate the coefficient coeff(L)
                        coeff[ind_sb, ind_fstim] = np.max(cano_corr) 
                
                # Predict label for the current trial
                predict_label[i] = np.argmax(np.sum(phi * (coeff ** 2).T, axis=1)) 

            # Calculate accuracy and append it to the list accuracy
            print(f"{val_a}, {val_b} --> {np.sum(labels == predict_label) / len(predict_label) * 100:.2f}")
            accuracy.append("{:.2f}".format(np.sum(labels == predict_label) / len(predict_label) * 100))

    return accuracy

# =============================================== CCA ========================================================
def cca_analysis(data, data_ref):
    """
    =============================== Presented by: Reza Saadatyar (2023-2024) =================================
    ================================ E-mail: Reza.Saadatyar@outlook.com ======================================
    Canonical Correlation Analysis (CCA)
    Parameters:
    - data: EEG data or one set of variables.
    - data_ref: Reference data or another set of variables.
    ==================================== Flowchart for the cca function ======================================
    Start
    1. Convert data and data_ref to NumPy arrays if they are not already.
    2. Transpose data and data_ref if they have more than one dimension and fewer rows than columns.
    3. Concatenate data and data_ref along the second axis if the number of features in data is less than or 
    equal 
    to the number of features in data_ref. Otherwise, concatenate data_ref and data.
    4. Calculate the covariance matrices:
    a. Extract covariance matrices for each set of variables from the combined covariance matrix.
    5. Solve the optimization problem using eigenvalue decomposition:
    a. Ensure numerical stability by adding a small epsilon value to the diagonal of covariance matrices.
    b. Compute the correlation coefficient matrix using the formula: inv(cy + eps * I) @ cyx @ inv(cx + eps * 
    I) @ cxy.
    6. Perform eigenvalue decomposition on the correlation coefficient matrix.
    7. Sort the eigenvalues in descending order.
    8. Set any small negative eigenvalues to a small positive value, assuming they are due to numerical error.
    9. Extract and return the sorted canonical correlation coefficients.
    End
    ==========================================================================================================
    """
    # ---------------------------- Convert data to ndarray if it's not already -------------------------------
    data = np.array(data) if not isinstance(data, np.ndarray) else data
    data_ref = np.array(data_ref) if not isinstance(data_ref, np.ndarray) else data_ref
    
    # Transpose the data if it has more than one dimension and has fewer rows than columns
    data, data_ref = [x.T if x.ndim > 1 and x.shape[0] < x.shape[-1] else x for x in [data, data_ref]]
   
    # Combine the data and reference data based on their dimensionality
    xy = np.concatenate((data, data_ref), axis=1) if data.shape[1] <= data_ref.shape[1] else np.concatenate\
        ((data_ref, data), axis=1)
    
    # Calculate covariance matrices
    covariance = np.cov(xy, rowvar=False)
    n = min(data.shape[1], data_ref.shape[1])
    cx = covariance[:n, :n]
    cy = covariance[n:, n:]
    cxy = covariance[:n, n:]
    cyx = covariance[n:, :n]
    
    # Solve the optimization problem using eigenvalue decomposition
    # Adding np.eye(*cy.shape) * eps ensures numerical stability
    eps = np.finfo(float).eps
    # corr_coef = np.linalg.inv(cy + np.eye(*cy.shape) * eps) @ cyx @ np.linalg.inv(cx + np.eye(*cx.shape) * 
    # eps) @ cxy
    
    corr_coef = np.linalg.inv(cy + eps * np.eye(cy.shape[0])) @ cyx @ np.linalg.inv(cx + eps * 
                                                                                    np.eye(cx.shape[0])) @ cxy

    # Eigenvalue decomposition and sorting
    eig_vals = np.linalg.eigvals(corr_coef)

    # Set any small negative eigenvalues to zero, assuming they are due to numerical error
    eig_vals[eig_vals < 0] = 0
    d_coeff = np.sort(np.real(eig_vals))[::-1]  # Only real parts, sorted in descending order
    d_coeff = np.sqrt(np.sort(np.real(eig_vals))[::-1])  # Only real parts, sorted in descending order
    
    return d_coeff[:n]  # Return the canonical correlations


# ============================================= Filtering ====================================================
# Function to apply digital filtering to data
def filtering(data, f_low, f_high, order, fs, notch_freq, quality_factor, filter_active="on", notch_filter="on",
              type_filter='bandpass'):
    """
    FILTERING applies digital filtering to data.
    Inputs:
    - data: Input data to be filtered.
    - f_low: Low cutoff frequency.
    - f_high: High cutoff frequency.
    - order: Filter order.
    - fs: Sampling frequency.
    - notch_freq: Frequency to be notched out.
    - filter_active: Activate filtering ('on' or 'off').
    - notch_filter: Activate notch filtering ('on' or 'off').
    - type_filter: Type of filter ('low', 'high', 'bandpass', 'stop').
    Output:
    - filtered_data: Filtered data.
    ================================= Flowchart for the filtering function ===================================
    Start
     1. Normalize frequency values (f_low, f_high)
     2. Check the dimensions of the input data:
        a. If it's a 3D matrix and has more rows than columns:
           - Transpose the data using permute to make channels as slices
        b. If it has more columns than rows:
           - Transpose the data to make channels as rows
     3. Design Butterworth filter based on the specified type:
        - Lowpass filter: Design Butterworth filter with 'low' option
        - Highpass filter: Design Butterworth filter with 'high' option
        - Bandpass filter: Design Butterworth filter with 'bandpass' option
        - Bandstop filter: Design Butterworth filter with 'bandstop' option
     4. Design a notch filter:
        - Use iirnotch to design a notch filter based on notch frequency and quality factor
     5. Notch filter:
        - Apply notch filtering if notch_filter is 'on'
     6. Apply the digital filter using filtfilt:
        - Apply filtering if filter_active is 'on'
     7. Output the filtered data (filtered_data)
     End
    ==========================================================================================================
    """
    # ---------------------------------------- Normalize frequency values ------------------------------------
    f_low = f_low / (fs / 2)
    f_high = f_high / (fs / 2)
    
    filtered_data = data.copy()           # Make a copy of the input data
    # ---------------------------- Convert data to ndarray if it's not already -------------------------------
    filtered_data = np.array(filtered_data) if not isinstance(filtered_data, np.ndarray) else filtered_data
    # ----------------------- Transpose data if it has more rows than columns --------------------------------
    filtered_data = filtered_data.T if filtered_data.ndim > 1 and filtered_data.shape[0] > filtered_data.shape[-1] \
    else filtered_data
    # ----------------------- Design Butterworth filter based on the specified type --------------------------
    if type_filter == "low":     
        b, a = signal.butter(order, f_low, btype='low')
    elif type_filter == "high":
        b, a = signal.butter(order, f_high, btype='high')
    elif type_filter == "bandpass":
        b, a = signal.butter(order, [f_low, f_high], btype='bandpass')
    elif type_filter == "bandstop":
        b, a = signal.butter(order, [f_low, f_high], btype='bandstop')
    
    # Design a notch filter using signal.iirnotch
    # b_notch, a_notch = signal.butter(3, np.array([notch_freq - 0.4, notch_freq + 0.4])/fs/2, btype='bandstop')
    b_notch, a_notch = signal.iirnotch(notch_freq, quality_factor, fs)
    # -------------------------------------------- Notch filter ----------------------------------------------
    if notch_filter == "on":
        if filtered_data.ndim == 3:
            for i in range(filtered_data.shape[0]):
                filtered_data[i, :, :] = signal.filtfilt(b_notch, a_notch, filtered_data[i, :, :])
        else:
            filtered_data = signal.filtfilt(b_notch, a_notch, filtered_data)
     # ---------------- Apply the digital filter using filtfilt to avoid phase distortion --------------------
    if filter_active == "on":
        if filtered_data.ndim == 3:
            for i in range(filtered_data.shape[0]):
                filtered_data[i, :, :] = signal.filtfilt(b, a, filtered_data[i, :, :])
        else:
            filtered_data = signal.filtfilt(b, a, filtered_data)
    # ----------------------------- Transpose data if it has more columns than rows --------------------------------
    filtered_data = filtered_data.T if filtered_data.ndim > 1 and filtered_data.shape[0] < filtered_data.shape[-1] \
    else filtered_data

    return filtered_data

#  if type(filtered_data).__name__ != 'ndarray': 
#         filtered_data = np.array(filtered_data)
