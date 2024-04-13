import numpy as np

# ===================== Feature extraction using Canonical Correlation Analysis (CCA) ========================
def cca_feature_extraction(data, fs, f_stim, num_channel, num_harmonic):
    """
    =============================== Presented by: Reza Saadatyar (2023-2024) =================================
    ================================ E-mail: Reza.Saadatyar@outlook.com ======================================
    Parameters:
    - data: EEG data matrix with dimensions (number of samples, number of channels, number of trials).
    - fs: Sampling frequency of the EEG data.
    - f_stim: Array of frequencies for stimulation.
    - num_channel: Number of the channel to analyze.
    - num_harmonic: Number of harmonic frequencies for each stimulation frequency.
    ========================== Flowchart for the cca_feature_extraction function =============================
    Start
    1. Convert the input data to a NumPy ndarray if it's not already.
    2. Transpose the data if it has more columns than rows.
    3. Define the reference signals based on the stimulation frequencies:
        - Create an empty list for reference signals.
        - Generate reference signals for each frequency stimulation.
        - Stack the sine and cosine components of each harmonic together.
        - Store the reference signals in the `data_ref` list.
    4. Perform correlation analysis between the input data and reference signals:
        - Initialize an empty list for storing correlation coefficients.
        - Loop through all trials in the input data.
            - For each trial, calculate the correlation coefficient using Canonical Correlation Analysis (CCA).
            - Append the correlation coefficients to the `coeff` list.
        - Stack the correlation coeffi
    End
    ==========================================================================================================
    """
    # -------------------------- Convert data to ndarray if it's not already ---------------------------------
    data = np.array(data) if not isinstance(data, np.ndarray) else data

    # Transpose the data if it has more than one dimension and has fewer rows than columns
    data = data.T if data.ndim > 1 and data.shape[0] < data.shape[-1] else data
    # ---------------------------------------- Reference signal ----------------------------------------------
    data_ref = []
    time = np.arange(0, data.shape[0]) / fs  # Time vector

    for _, val in enumerate(f_stim): # First loop: frequencies stimulation

        signal_ref = []

        for j in range(1, num_harmonic + 1):  # Generate a reference signal for each frequency stimulation
            signal_ref.append(np.sin(2 * np.pi * j * val * time))
            signal_ref.append(np.cos(2 * np.pi * j * val * time))

        data_ref.append(np.stack(signal_ref, axis=1))  # Store data_ref in the data_ref_list
    # --------------------------------------- Correlation Analysis -------------------------------------------
    features = []
    for i in range(data.shape[-1]): # Loop through all Trials
        
        coeff = []

        for k in range(len(f_stim)):  # Second loop: Calculate CCA for frequencies stimulation
            coeff.append(cca_analysis(data[:, num_channel, i], data_ref[k]))
            
        features.append(np.hstack(coeff))
    
    features = np.stack(features)
    
    return features


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
    corr_coef = np.linalg.inv(cy + np.eye(*cy.shape) * eps) @ cyx @ np.linalg.inv(cx + np.eye(*cx.shape) * 
                                                                                  eps) @ cxy
    
    # Eigenvalue decomposition and sorting
    eig_vals = np.linalg.eigvals(corr_coef)
    
    # Set any small negative eigenvalues to zero, assuming they are due to numerical error
    eig_vals[eig_vals < 0] = 0.0000000000000000000001
    d_coeff = np.sort(np.real(eig_vals))[::-1]  # Only real parts, sorted in descending order
    # d_coeff = np.sqrt(np.sort(np.real(eig_vals))[::-1])  # Only real parts, sorted in descending order
    
    return d_coeff[:n]  # Return the canonical correlations