import numpy as np
import matplotlib.pyplot as plt

# ============================================ PSDA a trial ==================================================
def psda_a_trial(data, fs, num_sample_neigh, f_stim, num_harmonic, title, fig_size=[4, 3]):
    """
    =============================== Presented by: Reza Saadatyar (2023-2024) =================================
    ================================ E-mail: Reza.Saadatyar@outlook.com ======================================
    PSDA_A_TRIAL calculates the Power Spectral Density Amplitude (PSDA) for a single trial.
    Inputs:
      - fs: Sampling frequency of the signal.
      - data: EEG signal data for a single trial.
      - num_sample_neigh: Number of samples in the neighborhood of each frequency stimulation.
      - f_stim: Array of frequencies for stimulation.
      - num_harmonic: Number of harmonic frequencies for each stimulation frequency.
    Outputs:
      - max_freq: Maximum frequency found using PSDA.
      - label: Index of the stimulation frequency with maximum PSDA.
    ================================ Flowchart for the psda a trial function =================================
    Start
    1. Convert data to ndarray if it's not already.
    2. Transpose the data if it has more than one dimension and has fewer rows than columns.
    3. Generate the frequency axis up to the Nyquist frequency.
    4. Calculate the frequency step size for each neighborhood.
    5. Initialize an array to store PSDA values for each stimulation frequency and harmonic.
    6. Compute FFT of the data along the specified axis.
    7. Take the one-sided spectrum of the FFT result.
    8. Compute the power spectral density (PSD) of the FFT result.
    9. Create a new figure with the specified size.
    10. Plot the PSD against frequency, excluding the DC component.
    11. Loop over each stimulation frequency:
        a. Loop over each harmonic:
            i. Find indices around the stimulation frequency and its neighborhood.
            ii. Compute PSDA and plot PSD in the neighborhood.
    12. Find the maximum PSDA value and its corresponding label.
    13. Set plot title and axis labels.
    14. Auto-scale x-axis.
    15. Add legend to the plot.
    16. Return the maximum PSDA value and its corresponding label.
    End
    ==========================================================================================================
    """
    # ---------------------------- Convert data to ndarray if it's not already -------------------------------
    data = np.array(data) if not isinstance(data, np.ndarray) else data

    # Transpose the data if it has more than one dimension and has fewer rows than columns
    data = data.T if data.ndim > 1 and data.shape[0] < data.shape[-1] else data
    
    # Generate frequency axis up to Nyquist frequency
    f = np.linspace(0, fs/2, int(np.floor(data.shape[0]/2)) + 1) 
    step = fs * (num_sample_neigh/2) / data.shape[0] # Calculate the frequency step size for each neighborhood
    # Initialize array to store PSDA values for each stimulation frequency and harmonic
    psda = np.zeros((len(f_stim), num_harmonic)) 

    x_fft = np.fft.fft(data, axis=0) # Compute FFT of the data along the specified axis
    x_fft = x_fft[:int(np.floor(data.shape[0]/2)) + 1] # Take one-sided spectrum
    psd = np.abs(x_fft)**2 # Compute power spectral density
    
    plt.figure(figsize=fig_size) # Create a new figure with the specified size
    plt.plot(f[1:], psd[1:], linewidth=1.5) # Plot PSD against frequency, excluding DC component

    for i, val in enumerate(f_stim): # Loop over each stimulation frequency
        for h in range(1, num_harmonic + 1): # Loop over each harmonic
            # Find indices around the stimulation frequency and its neighborhood
            ind_fk = np.where((f >= h * val - 0.2) & (f <= h * val + 0.2))[0]
            ind_h = np.where((f >= h * val - step) & (f <= h * val + step))[0]
            
            # Compute PSDA and plot PSD in the neighborhood
            psda[i, h-1] = 10 * np.log10((num_sample_neigh * max(psd[ind_fk])) / (np.sum(psd[ind_h]) - 
                                                                                  max(psd[ind_fk])))
            plt.plot(f[ind_h], psd[ind_h], linewidth=2.5, label=f"F_stim{i + 1}.H{h}:{val * h}")
            
    # Find the maximum PSDA value and its corresponding label
    max_freq = np.max(np.max(psda, axis=1))
    label = np.argmax(np.max(psda, axis=1)) + 1

    plt.title(title, fontsize=10) # Set plot title and axis labels
    plt.xlabel('F(Hz)', fontsize=10)
    plt.ylabel('PSD', fontsize=10)
    plt.autoscale(enable=True, axis="x", tight=True)
    plt.legend(fontsize=9, ncol=2, handlelength=0, handletextpad=0.25, frameon=False, labelcolor='linecolor')

    return max_freq, label # Return the maximum PSDA value and its corresponding label