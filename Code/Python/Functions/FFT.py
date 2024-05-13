import numpy as np
import matplotlib.pyplot as plt

# ================================================= fft ======================================================
def fft_analysis(data, filtered_data, fs, channel=0, trial=0, title='FFT Analysis', size_fig=[5, 3]):
    """
    =============================== Presented by: Reza Saadatyar (2023-2024) =================================
    ================================ E-mail: Reza.Saadatyar@outlook.com ======================================
    Perform FFT analysis on given data and its filtered counterpart.
    Parameters:
    - data: Numpy array containing the raw signal data.
    - filtered_data: Numpy array containing the filtered signal data.
    - fs: Sampling frequency.
    - channel: Channel number to analyze (default: 0).
    - trial: Trial number to analyze (default: 0).
    - title: Plot title (default: 'FFT Analysis').
    - size_fig: Figure size (default: [5, 3]).
    ================================ Flowchart for the fft_analysis function =================================
    Start
    1. Adjust trial and channel indices for Python's 0-indexing
    2. Convert data to ndarray if it's not already
    3. Ensure data is in the correct shape (Transpose if necessary)
    4. Extract the signal for the specified channel and trial from raw and filtered data
    5. Perform FFT on both raw and filtered signals
    6. Create frequency axis for FFT results
    7. Plot time-domain signals (raw and filtered) on the first subplot
    8. Plot frequency-domain FFT results (raw and filtered) on the second subplot
    9. Adjust subplot properties and labels
    End
    ==========================================================================================================
    """
    # Adjust for Python's 0-indexing
    trial, channel = max(0, trial - 1), max(0, channel - 1)
     # ----------------------------- Convert data to ndarray if it's not already -----------------------------
    data = np.array(data) if not isinstance(data, np.ndarray) else data
    filtered_data = np.array(filtered_data) if not isinstance(filtered_data, np.ndarray) else filtered_data
    # Ensure data is in correct shape
    data, filtered_data = [x.T if x.ndim > 1 and x.shape[0] < x.shape[-1] else x for x in [data, filtered_data]]
    
    # Extract signal
    signal, filtered_signal = extract_signal(data, filtered_data, channel, trial)
    
    # Perform FFT
    fft_results = perform_fft(signal, filtered_signal, fs)
    
    # Plotting
    plot_fft(*fft_results, fs, title, size_fig)

def extract_signal(data, filtered_data, channel, trial):
    if data.ndim == 3:
        return data[:, channel, trial], filtered_data[:, channel, trial]
    elif data.ndim == 2:
        return data[:, channel], filtered_data[:, channel]
    return data, filtered_data

def perform_fft(signal, filtered_signal, fs):
    x_fft = np.fft.rfft(signal)
    x_filter_fft = np.fft.rfft(filtered_signal)
    f = np.linspace(0, fs / 2, len(x_fft))
    return signal, filtered_signal, x_fft, x_filter_fft, f

def plot_fft(signal, filtered_signal, x_fft, x_filter_fft, f, fs, title, size_fig):
    time = np.linspace(0, len(signal) / fs, num=len(signal))
    
    _, axs = plt.subplots(nrows=2, sharex="row", figsize=size_fig)
    
    # Time-domain plots
    axs[0].plot(time, signal, label="Raw Signal")
    axs[0].plot(time, filtered_signal, label="Filtered Signal")
    axs[0].set_ylabel('Amplitude', fontsize=10)
    axs[0].set_title(title, fontsize=10)
    axs[0].autoscale(enable=True, axis="x", tight=True)  # Auto-scale x-axis and set y-axis limits
    axs[0].set_xlabel('Time(Sec)', labelpad=-0.1, fontsize=10)
    axs[0].legend(fontsize=9, ncol=2, handlelength=0, handletextpad=0.25, frameon=False, labelcolor='linecolor')
    
    # Frequency-domain plots
    axs[1].plot(f, np.abs(x_fft), label="Raw FFT")
    axs[1].plot(f, np.abs(x_filter_fft), label="Filtered FFT")
    axs[1].set_ylabel('Magnitude (PSD)', fontsize=10)
    axs[1].set_xlabel('Frequency (Hz)', fontsize=10)
    axs[1].set_xlabel('F(Hz)', labelpad=-0.1, fontsize=10)
    axs[1].autoscale(enable=True, axis="x", tight=True) 
    
#     axs[0].tick_params(axis='x', length=1, width=1, which='both', bottom=True, top=False, labelbottom=True, labeltop=False, pad=0)
#     axs[1].tick_params(axis='x', length=1, width=1, which='both', bottom=True, top=False, labelbottom=True, labeltop=False, pad=0)
#     axs[0].tick_params(axis='y', length=1, width=1, which='both', bottom=True, top=False, labelbottom=True, labeltop=False, pad=2)
#     axs[1].tick_params(axis='y', length=1, width=1, which='both', bottom=True, top=False, labelbottom=True, labeltop=False, pad=2)
    plt.tight_layout(pad=0, h_pad=0, w_pad=0)

