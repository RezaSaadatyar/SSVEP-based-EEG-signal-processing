import numpy as np
import matplotlib.pyplot as plt

# ==================================================== fft ===============================================================
def fft_analysis(data, data_filtered, fs, channel=0, trial=0, title='FFT Analysis', size_fig=[5, 3]):
    
    """
    Perform FFT analysis on given data and its filtered counterpart.
    
    Parameters:
    - data: Numpy array containing the raw signal data.
    - data_filtered: Numpy array containing the filtered signal data.
    - fs: Sampling frequency.
    - channel: Channel number to analyze (default: 0).
    - trial: Trial number to analyze (default: 0).
    - title: Plot title (default: 'FFT Analysis').
    - size_fig: Figure size (default: [5, 3]).
    """
    
    # Adjust for Python's 0-indexing
    trial, channel = max(0, trial - 1), max(0, channel - 1)
    
    # Ensure data is in correct shape
    data, data_filtered = [x.T if x.ndim > 1 and x.shape[0] < x.shape[-1] else x for x in [data, data_filtered]]
    
    # Extract signal
    signal, signal_filtered = extract_signal(data, data_filtered, channel, trial)
    
    # Perform FFT
    fft_results = perform_fft(signal, signal_filtered, fs)
    
    # Plotting
    plot_fft(*fft_results, fs, title, size_fig)

def extract_signal(data, data_filtered, channel, trial):
    if data.ndim == 3:
        return data[:, channel, trial], data_filtered[:, channel, trial]
    elif data.ndim == 2:
        return data[:, channel], data_filtered[:, channel]
    return data, data_filtered

def perform_fft(signal, signal_filtered, fs):
    x_fft = np.fft.rfft(signal)
    x_filter_fft = np.fft.rfft(signal_filtered)
    f = np.linspace(0, fs / 2, len(x_fft))
    return signal, signal_filtered, x_fft, x_filter_fft, f

def plot_fft(signal, signal_filtered, x_fft, x_filter_fft, f, fs, title, size_fig):
    time = np.linspace(0, len(signal) / fs, num=len(signal))
    
    _, axs = plt.subplots(nrows=2, sharex="row", figsize=size_fig)
    
    # Time-domain plots
    axs[0].plot(time, signal, label="Raw Signal")
    axs[0].plot(time, signal_filtered, label="Filtered Signal")
    axs[0].set_ylabel('Amplitude', fontsize=10)
    axs[0].set_title(title, fontsize=10)
    axs[0].autoscale(enable=True, axis="x",tight=True)  # Auto-scale x-axis and set y-axis limits
    axs[0].set_xlabel('Time(Sec)', labelpad=-0.1, fontsize=10)
    axs[0].legend(fontsize=9, ncol=2, handlelength=0, handletextpad=0.25, frameon=False, labelcolor='linecolor')
    
    # Frequency-domain plots
    axs[1].plot(f, np.abs(x_fft), label="Raw FFT")
    axs[1].plot(f, np.abs(x_filter_fft), label="Filtered FFT")
    axs[1].set_ylabel('Magnitude (PSD)', fontsize=10)
    axs[1].set_xlabel('Frequency (Hz)', fontsize=10)
    axs[1].set_xlabel('F(Hz)', labelpad=-0.1, fontsize=10)
    axs[1].autoscale(enable=True, axis="x",tight=True) 
    
#     axs[0].tick_params(axis='x', length=1, width=1, which='both', bottom=True, top=False, labelbottom=True, labeltop=False, pad=0)
#     axs[1].tick_params(axis='x', length=1, width=1, which='both', bottom=True, top=False, labelbottom=True, labeltop=False, pad=0)
#     axs[0].tick_params(axis='y', length=1, width=1, which='both', bottom=True, top=False, labelbottom=True, labeltop=False, pad=2)
#     axs[1].tick_params(axis='y', length=1, width=1, which='both', bottom=True, top=False, labelbottom=True, labeltop=False, pad=2)
    plt.tight_layout(pad=0, h_pad=0, w_pad=0)

