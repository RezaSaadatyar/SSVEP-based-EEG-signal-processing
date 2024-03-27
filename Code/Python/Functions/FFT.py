import numpy as np
import matplotlib.pyplot as plt

# ==================================================== fft ===============================================================
def fft(data, data_filtered, fs, channel, trial, title, size_fig=[5, 3]):
    # ------------------------ Transpose data if it has more rows than columns ---------------------------
    data = data.T if data.ndim > 1 and data.shape[0] < data.shape[-1] else data
    data_filtered = data_filtered.T if data_filtered.ndim > 1 and data_filtered.shape[0] < data_filtered.shape[-1] else data_filtered
    
    trial = max(0, trial - 1)
    channel= max(0, channel - 1)

    _, axs = plt.subplots(nrows=2, sharey="row", figsize=size_fig) # Create subplots for the figure
    time = (np.linspace(start=0, stop=len(data)/fs, num=len(data))).flatten()
# ------------------- Perform Fourier transform on the ith trial's single channel --------------------
    if data.ndim == 3:
        x_fft = np.fft.fft(data[:, channel, trial])
        x_filter_fft = np.fft.fft(data_filtered[:, channel, trial]) # Perform Fourier transform on the filtered signal
        axs[0].plot(time, data[:, channel, trial], linewidth=0.7, label="Raw signal")
        axs[0].plot(time, data_filtered[:, channel, trial], linewidth=0.7, label="Filtered Signal")
    elif data.ndim ==2:
        x_fft = np.fft.fft(data[:, channel])
        x_filter_fft = np.fft.fft(data_filtered[:, channel])        # Perform Fourier transform on the filtered signal
        axs[0].plot(time, data[:, channel], linewidth=0.7, label="Raw signal")
        axs[0].plot(time, data_filtered[:, channel], linewidth=0.7, label="Filtered Signal")
    else:
        x_fft = np.fft.fft(data)
        x_filter_fft = np.fft.fft(data_filtered)                    # Perform Fourier transform on the filtered signal
        axs[0].plot(time, data, linewidth=0.7, label="Raw signal")
        axs[0].plot(time, data_filtered, linewidth=0.7, label="Filtered Signal")

    x_psd = np.abs(x_fft[:len(x_fft)//2])                           # Calculate the one-sided power spectral density (PSD)
    x_filter_psd = np.abs(x_filter_fft[:len(x_filter_fft)//2])
    f = np.linspace(0, fs/2, len(x_fft)//2)                         # Create a frequency axis
    # ------------------------------------------ Plot Result  --------------------------------------------
    axs[1].plot(f, x_psd)
    axs[1].plot(f, x_filter_psd)
    axs[0].set_ylabel('Amp', fontsize=10)
    axs[1].set_ylabel('PSD', fontsize=10)
    axs[0].set_title(title, fontsize=10)
    axs[1].set_xlabel('F(Hz)', labelpad=-0.1, fontsize=10)
    axs[0].set_xlabel('Time(Sec)', labelpad=-0.1, fontsize=10)
    axs[0].autoscale(enable=True, axis="x",tight=True) # Auto-scale x-axis and set y-axis limits
    axs[1].autoscale(enable=True, axis="x",tight=True) 
    axs[0].legend(fontsize=9, ncol=2, handlelength=0, handletextpad=0.25, frameon=False, labelcolor='linecolor')
    axs[0].tick_params(axis='x', length=1, width=1, which='both', bottom=True, top=False, labelbottom=True, labeltop=False, pad=0)
    axs[1].tick_params(axis='x', length=1, width=1, which='both', bottom=True, top=False, labelbottom=True, labeltop=False, pad=0)
    axs[0].tick_params(axis='y', length=1, width=1, which='both', bottom=True, top=False, labelbottom=True, labeltop=False, pad=2)
    axs[1].tick_params(axis='y', length=1, width=1, which='both', bottom=True, top=False, labelbottom=True, labeltop=False, pad=2)
    plt.tight_layout(pad=0, h_pad=0, w_pad=0); # fig.subplots_adjust(wspace=0, hspace=0), 