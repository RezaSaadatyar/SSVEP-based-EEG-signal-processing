import numpy as np

# ================================= Fusing Canonical Coefficients (FoCCA) ====================================
def focca_analysis(data, labels, fs, f_stim, num_channel, num_harmonic, a, b):
    """
    =============================== Presented by: Reza Saadatyar (2023-2024) =================================
    ================================ E-mail: Reza.Saadatyar@outlook.com ======================================
    Parameters:
    - data: EEG data matrix with dimensions (number of samples, number of channels, number of trials).
    - labels: True labels corresponding to each trial.
    - fs: Sampling frequency of the EEG data.
    - f_stim: Array of frequencies for stimulation.
    - num_channel: Number of channels to consider for analysis.
    - num_harmonic: Number of harmonic frequencies for each stimulation frequency.
    - a: Array of parameter values for scaling the coefficients.
    - b: Array of parameter values for shifting the coefficients.
    ==================================== Flowchart for the focca function ====================================
    Start
    1. Convert data to a NumPy array if it's not already.
    2. Transpose the data if it has more than one dimension and fewer rows than columns.
    3. Initialize an empty list data_ref to store reference signals for each stimulation frequency.
    4. Create a time vector based on the sampling frequency and the length of the data.
    5. Loop over each stimulation frequency:
    a. Generate reference signals for each harmonic frequency and append them to the data_ref list.
    6. Initialize an array predict_label to store predicted labels for each trial.
    7. Create an array k containing values from 1 to the minimum of num_channel and num_harmonic * 2.
    8. Initialize an array coeff to store computed coefficients.
    9. Initialize an empty list accuracy to store the accuracy of predictions for different parameter 
    combinations.
    10. Loop over each pair of parameter values (val_a, val_b) in the arrays a and b:
        a. Loop over each trial in the data:
            i. Loop over each stimulation frequency:
                A. Calculate canonical correlation coefficients between the EEG data and reference signals.
                B. Compute the coefficient using the FOCCA formula.
            ii. Predict the label for the current trial based on the computed coefficients.
        b. Calculate the accuracy of predictions and append it to the accuracy list.
        c. Print the accuracy for the current parameter combination.
    11. Return the list of accuracies.
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
    predict_label = np.zeros(data.shape[-1])  # Initialize label_predic array with zeros
    k = np.arange(1, min(len(num_channel), num_harmonic * 2) + 1, dtype=float) # Create the array k
    coeff = np.zeros(len(f_stim))
    accuracy = []
    
    for _, val_a in enumerate(a):
        for _, val_b in enumerate(b):
            phi =  np.power(k, -val_a) + val_b    # Compute phi
            
            for i in range(data.shape[-1]):       # Loop through all Trials

                for ind, _ in enumerate(f_stim):  # Second loop: Calculate CCA for frequencies stimulation
                    cano_corr = cca_analysis(data[:, num_channel, i], data_ref[ind])
                    coeff[ind] = np.sum(phi * (cano_corr ** 2), axis=0) # Calculate the coefficient coeff(L)
                
                predict_label[i] = np.argmax(coeff) # Predict label for the current trial
            
            # Calculate accuracy and append it to the list accuracy
            print(f"{val_a}, {val_b} --> {np.sum(labels == predict_label) / len(predict_label) * 100:.2f}")
            accuracy.append("{:.2f}".format(np.sum(labels == predict_label) / len(predict_label) * 100))

    return accuracy

def cca_analysis(data, data_ref):
    """
    =============================== Presented by: Reza Saadatyar (2023-2024) =================================
    ================================ E-mail: Reza.Saadatyar@outlook.com ======================================
    Canonical Correlation Analysis (CCA)
    Parameters:
    - data: EEG data or one set of variables.
    - data_ref: Reference data or another set of variables.
    =================================== Flowchart for the cca function =======================================
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
    # ----------------------------- Convert data to ndarray if it's not already ------------------------------
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
    # corr_coef = np.linalg.inv(cy + np.eye(*cy.shape) * eps) @ cyx @ np.linalg.inv(cx + np.eye(*cx.shape) 
    # * eps) @ cxy
    
    corr_coef = np.linalg.inv(cy + eps * np.eye(cy.shape[0])) @ cyx @ np.linalg.inv(cx + eps * 
                                                                                    np.eye(cx.shape[0])) @ cxy

    # Eigenvalue decomposition and sorting
    eig_vals = np.linalg.eigvals(corr_coef)

    # Set any small negative eigenvalues to zero, assuming they are due to numerical error
    eig_vals[eig_vals < 0] = 0
    d_coeff = np.sort(np.real(eig_vals))[::-1]  # Only real parts, sorted in descending order
    d_coeff = np.sqrt(np.sort(np.real(eig_vals))[::-1])  # Only real parts, sorted in descending order
    
    return d_coeff[:n]  # Return the canonical correlations