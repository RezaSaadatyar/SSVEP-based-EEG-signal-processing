import numpy as np
import matplotlib.pyplot as plt

# ================================================= Plot data ============================================================
# Function to plot EEG data
def plot_data(data, fs=None, channels_name=None, first_point=0, last_point=100, val_ylim='', size_fig=(7,5), title='', 
              display_figure="off"):
    """
    Parameters:
    - data: EEG data to be plotted.
    - fs: Sampling frequency of the EEG data.
    - channels_name: Names of the EEG channels.
    - first_point: Index of the first data point to plot.
    - last_point: Index of the last data point to plot.
    - val_ylim: Vertical scale factor.
    - size_fig: Size of the figure.
    - title: Title of the plot.
    - display_figure: Whether to display the figure.
    """

    if display_figure == "on":  # Check if the display_figure parameter is set to "on"
        
        if type(data).__name__ != 'ndarray': # Convert data to ndarray if it's not already
            data = np.array(data)
        
        # Transpose the data if it has more than one dimension and has fewer rows than columns
        data = data.T if data.ndim > 1 and data.shape[0] < data.shape[-1] else data
        
        # Use numerical labels if channel names are not provided
        channels_name = channels_name if channels_name is not None else np.arange(1, data.shape[1] + 1)

        if first_point > len(data) or last_point > len(data):
            print(f"Error, {first_point = } or {last_point = } > data size: {len(data)}")
            return
      
        data = data[first_point:last_point,:] # Extract the specified range of data
        std = np.sort(np.std(data, axis=0))   # Calculate the standard deviation of each channel
        
        # If the array is larger than 100 elements, exclude the first and last elements before taking the mean
        std = np.mean(std[1:-1] if len(std) > 100 else std)
        
        _, axs = plt.subplots(nrows=1, sharey='row', figsize=size_fig) # Create subplots for the figure
        offset = np.arange(len(channels_name)*std*val_ylim, 0, -std*val_ylim)

        if fs is not None and np.array(fs) > 0: # Check if the sampling frequency is provided 
            time = (np.linspace(start=first_point/fs, stop=last_point/fs, num=len(data))).flatten()
            line = axs.plot(time, data + offset, linewidth=1)
            axs.set_xlabel('Time (sec)', fontsize=10)
        else:
            line = axs.plot(data + offset, linewidth=1)
            axs.set_xlabel('sample', fontsize=10)
        
        axs.grid(False)
        axs.set_yticks(offset)
        axs.tick_params(axis='x', labelsize=9)
        axs.tick_params(axis='y', labelsize=8)
        axs.set_ylabel('Channels', fontsize=10)
        axs.set_yticklabels(channels_name,  weight='bold')
        axs.tick_params(axis='y', color='k', labelcolor='k')
        axs.set_title(f"Channels: {len(channels_name)}#; {title}", fontsize=10) # Set subplot properties
        
        ytick_labels = plt.gca().get_yticklabels() # Color lines and labels
        for i, label in enumerate(ytick_labels):
            # line[i].set_color(line[i].get_color())
            label.set_color(line[i].get_color())   # Set label color to match the line color
        
        # Auto-scale x-axis and set y-axis limits
        axs.autoscale(enable=True, axis="x",tight=True)
        min_ = np.min(np.min(data + offset, axis=0))
        max_ = np.max(np.max(data + offset, axis=0))
        axs.set_ylim(min_ + min_*0.02, max_ + max_*0.01)
        
             # if len(std) > 100:
        #     std = np.mean(std[1:len(std)-1])
        # else:
        #     std = np.mean(std)