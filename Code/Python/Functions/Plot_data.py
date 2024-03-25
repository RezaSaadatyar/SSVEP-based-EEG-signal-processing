import numpy as np
import matplotlib.pyplot as plt

# ================================================= Plot data ============================================================
# Function to plot EEG data
def plot_data(data, fs=None, channels_name=None, first_point=0, last_point=100, val_ylim='', size_fig=(7,5), title='', display_figure="off"):

    if display_figure == "on":  # Check if the display_figure parameter is set to "on"
        
        if type(data).__name__ != 'ndarray': # Convert data to ndarray if it's not already
            data = np.array(data)
        if data.ndim > 1 and data.shape[0] < data.shape[1]: # Transpose data if it has more columns than rows
            data = data.T
            
        if channels_name is None: # If channel names are not provided, use numerical labels
            channels_name = np.arange(1, data.shape[1]+1)  
              
        data = data[first_point:last_point,:] # Extract the specified range of data
        std = np.sort(np.std(data, axis=0)) # Calculate the standard deviation of each channel
        if len(std) > 100:
            std = np.mean(std[1:len(std)-1])
        else:
            std = np.mean(std)
        
        _, axs = plt.subplots(nrows=1, sharey='row', figsize=size_fig)
        offset = np.arange(len(channels_name)*std*val_ylim, 0, -std*val_ylim)
      
        if fs is not None and np.array(fs) > 0: # Check if the sampling frequency is provided 
            time = (np.linspace(start=first_point/fs, stop=last_point/fs, num=len(data))).flatten()
            line = axs.plot(time, data + offset, linewidth=1)
            axs.set_xlabel('Time (sec)', fontsize=10)
        else:
            line = axs.plot(data + offset, linewidth=1)
            axs.set_xlabel('sample', fontsize=10)
        
        axs.set_title(f"Channels: {len(channels_name)}#; {title}", fontsize=10) # Set subplot properties
        axs.set_yticks(offset)
        axs.set_yticklabels(channels_name,  weight='bold')
        axs.tick_params(axis='x', labelsize=9)
        axs.tick_params(axis='y', labelsize=8)
        axs.set_ylabel('Channels', fontsize=10)
        axs.tick_params(axis='y', color='k', labelcolor='k')
        axs.grid(False)
        
        ytick_labels = plt.gca().get_yticklabels() # Color lines and labels
        for i, label in enumerate(ytick_labels):
            # line[i].set_color(line[i].get_color())
            label.set_color(line[i].get_color())
            
        axs.autoscale(enable=True, axis="x",tight=True)
        min_ = np.min(np.min(data + offset, axis=0))
        max_ = np.max(np.max(data + offset, axis=0))
        axs.set_ylim(min_ + min_*0.02, max_ + max_*0.01) 