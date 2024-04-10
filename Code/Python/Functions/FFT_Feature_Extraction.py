import numpy as np
import matplotlib.pyplot as plt
from Functions import Plot_features
# ========================================== FFT_Feature_Extraction ==========================================
def fft_feature_extraction(data, labels, fs, num_channel, subbands, title="Feature Extraction using FFT",
                           location_legend=5, display_figuare="off"):
    """
    Parameters:
    - data: EEG data matrix with dimensions (number of samples, number of channels, number of trials).
    - labels: Array of labels corresponding to each trial.
    - fs: Sampling frequency.
    - num_channel: List or array of channel indices to consider for feature extraction.
    - subbands: List or array of tuples specifying the frequency subbands.
    - title: Title for the plot (default is "Feature Extraction using FFT").
    - display_figure: Specifies whether to display the feature plot ("on" or "off").
    ========================== Flowchart for the fft_feature_extraction function =============================
    Start
    1. Convert data to a numpy array if it's not already in that format.
    2. Transpose the data if necessary to ensure proper dimensions.
    3. Calculate the frequency vector f using the sampling frequency fs.
    4. Initialize an array `features` to store the extracted features, with dimensions (number of trials, 
    number of subbands * number of channels).
    5. Loop over each trial in the data:
        a. Compute the FFT (Fast Fourier Transform) of the EEG data for the selected channels.
        b. Compute the power spectral density (PSD) by taking the absolute value of the FFT and selecting 
        only the positive frequency components.
        c. Loop over each subband:
            i. Find the indices corresponding to the frequency subband.
            ii. Extract the maximum PSD within the subband for each channel and update the `features` array.
    6. If `display_figure` is set to "on":
        a. Plot the extracted features using the `plot_features` function.
    7. Return the `features` array.
    End
    ==========================================================================================================
    """
    # --------------------------- Convert data to ndarray if it's not already --------------------------------
    data = np.array(data) if not isinstance(data, np.ndarray) else data
    
    # Transpose the data if it has more than one dimension and has fewer rows than columns
    data = data.T if data.ndim > 1 and data.shape[0] < data.shape[-1] else data
    
    f = np.linspace(0, fs / 2, data.shape[0] // 2 + 1) # Calculate frequency vector
    features = np.zeros((data.shape[-1], np.array(subbands).shape[1] * len(num_channel)))

    for i in range(data.shape[-1]):
        data_fft = np.fft.fft(data[:, num_channel, i], axis=0) # Compute FFT
        data_psd = np.abs(data_fft[:len(data_fft) // 2, :])    # Compute power spectral density (PSD)
        
        for ind_sb, (val_sb1, val_sb2) in enumerate(zip(*subbands)): # Feature extraction for each subband
            # Find indices corresponding to the subband
            ind = np.where((f >= val_sb1) & (f <= val_sb2))[0]
            
            # Update features with maximum PSD within subband
            features[i, ind_sb * len(num_channel):(ind_sb + 1) * len(num_channel)] = np.max(data_psd[ind, :],
                                                                                        axis=0)
    if display_figuare == "on":
        Plot_features.plot_features(features, labels, title, location_legend, fig_size=(4, 3))
    
    return features

# # ============================================ Plot features =================================================
# def plot_features(data, labels, title=None, location_legend=5, fig_size=(4, 3)):
#     """
#     Parameters:
#     - data: Feature matrix with dimensions (number of samples, number of features).
#     - labels: Array of labels corresponding to each sample.
#     - title: Title for the plot.
#     - fig_size: Tuple specifying the size of the figure (default is (4, 3)).
#     ============================== Flowchart for the plot_features function ==================================
#     Start
#     1. Convert the input data to a numpy array if it's not already in that format.
#     2. Transpose the data if necessary to ensure proper dimensions.
#     3. Obtain the unique classes from the labels.
#     4. Define colors for each class using the seaborn color palette.
#     5. Normalize the data using Min-Max scaling.
#     6. Plot the data based on the number of features:
#         a. If there's only one feature:
#             i. Create a 4x4 grid for plotting.
#             ii. Plot the feature values against the sample indices for each class.
#             iii. Plot the Gaussian distribution of the feature values for each class.
#         b. If there are two features:
#             i. Create a 4x4 grid for plotting.
#             ii. Plot the feature values in a scatter plot for each class.
#             iii. Plot the Gaussian distribution of each feature for each class.
#         c. If there are more than two features:
#             i. Create a 3D plot for visualizing the features.
#             ii. Plot the feature values in a 3D scatter plot for each class.
#             iii. Plot the Gaussian distribution of each feature for each class.
#     7. Adjust the subplot layout and spacing.
#     8. Return the plot.
#     """
#     # --------------------------- Convert data to ndarray if it's not already --------------------------------
#     data = np.array(data) if not isinstance(data, np.ndarray) else data
    
#     # Transpose the data if it has more than one dimension and has fewer rows than columns
#     data = data.T if data.ndim > 1 and data.shape[0] < data.shape[-1] else data
    
#     # --------------------------------------------- Unique labels --------------------------------------------
#     classes = np.unique(labels)
#     colors = sns.color_palette("bright", len(classes)).as_hex() # Define colors
#     # ---------------------------------------- Data normalization --------------------------------------------
#     norm = preprocessing.MinMaxScaler()
#     data = norm.fit_transform(data)
#     # --------------------------------------------- Plot -----------------------------------------------------
#     if data.shape[-1] == 1:
#         fig = plt.figure(figsize=fig_size)
#         grid = plt.GridSpec(4, 4, hspace=0.06, wspace=0.06)
#         ax = fig.add_subplot(grid[1:, :3])
#         ax1 = fig.add_subplot(grid[0, :3], yticklabels=[], sharex=ax)
        
#         for i, val in enumerate(classes):
            
#             tim = np.linspace(np.min(data[labels==val, 0]), np.max(data[labels==val, 0]), num=len(data[labels
#                               ==val, 0]), retstep=True)
#             ax.plot(tim[0], data[labels==val, 0], '.', markersize=10, color=colors[i], label=val)
            
#             _, bins = np.histogram(data[labels==val, 0], density=True)
#             ax1.plot(bins, stats.norm.pdf(bins, np.mean(data[labels==val, 0]), np.std(data[labels==val, 0])),
#                      linewidth=1.5, color=colors[i])
#             ax1.fill_between(bins, y1=stats.norm.pdf(bins, np.mean(data[labels==val, 0]), np.std(data[labels==
#                              val, 0])), y2=0, alpha=0.4)
            
#         ax.set_xlabel('Feature 1', fontsize=10, va='center')
#         ax.tick_params(axis='x', length=1.5, width=1, which='both', bottom=True, top=False, labelbottom=True, 
#                        labeltop=False, pad=0)
#         ax.tick_params(axis='y', length=1.5, width=1, which="both", bottom=False, top=False, labelbottom=True,
#                        labeltop=True, pad=0)
        
#     elif data.shape[-1] < 3:
#         fig = plt.figure(figsize=fig_size)
#         grid = plt.GridSpec(4, 4, hspace=0.06, wspace=0.06)
#         ax = fig.add_subplot(grid[1:, :3])
#         ax1 = fig.add_subplot(grid[0, :3], yticklabels=[], sharex=ax)
#         ax2 = fig.add_subplot(grid[1:, 3], xticklabels=[], sharey=ax)
        
#         for i, val in enumerate(classes):
            
#             ax.plot(data[labels==val, 0], data[labels==val, 1], '.', markersize=10, color=colors[i], label=
#                     val)
            
#             _, bins = np.histogram(data[labels==val, 0], density=True)
#             ax1.plot(bins, stats.norm.pdf(bins, np.mean(data[labels==val, 0]), np.std(data[labels==val, 0])), 
#                      linewidth=1.5, color=colors[i])
#             ax1.fill_between(bins, y1=stats.norm.pdf(bins, np.mean(data[labels==val, 0]), np.std(data[labels==
#                              val, 0])), y2=0, alpha=0.4)

#             _, bins = np.histogram(data[labels==val, 1], density=True)
#             ax2.plot(stats.norm.pdf(bins, np.mean(data[labels==val, 1]), np.std(data[labels==val, 1])), bins,
#                      linewidth=2.5, color=colors[i])
#             ax2.fill_betweenx(bins, stats.norm.pdf(bins, np.mean(data[labels==val, 1]), np.std(data[labels==
#                               val, 1])), 0, alpha=0.4, color=colors[i])

#         ax2.spines[['top', 'right', 'bottom']].set_visible(False)
#         ax2.tick_params(bottom=False, top=False, labelbottom=False, right=False, left=False, labelleft=False)
#         ax.set_xlabel('Feature 1', fontsize=10)
#         ax.set_ylabel('Feature 2', fontsize=10)
#         ax.tick_params(axis='x', length=1.5, width=1, which='both', bottom=True, top=False, labelbottom=True,
#                        labeltop=False, pad=0)
#         ax.tick_params(axis='y', length=1.5, width=1, which="both", bottom=False, top=False, labelbottom=True,
#                        labeltop=True, pad=0)
            
#     elif data.shape[-1] > 2:
#         fig = plt.figure(figsize=[4, 3])
#         ax = fig.add_axes((0.02, -0.05, 0.9, 0.9), projection="3d")
#         ax1 = fig.add_axes((0.22, 0.67, 0.52, 0.16))
#         ax2 = fig.add_axes((0.8, 0.18, 0.13, 0.47))
#         ax3 = fig.add_axes((-0.05, 0.18, 0.13, 0.47))
        
#         for i, val in enumerate(classes):
            
#             ax.plot3D(data[labels==val, 0], data[labels==val, 1], data[labels==val, 2], '.', markersize=10, 
#                       color=colors[i], label=val)
            
#             _, bins = np.histogram(data[labels==val, 0], density=True)
#             ax1.plot(bins, stats.norm.pdf(bins, np.mean(data[labels==val, 0]), np.std(data[labels==val, 0])),
#                      linewidth=2.5, color=colors[i])
#             ax1.fill_between(bins, y1=stats.norm.pdf(bins, np.mean(data[labels==val, 0]), np.std(data[labels==
#                              val, 0])), y2=0, alpha=0.4, color=colors[i])
            
#             _, bins = np.histogram(data[labels==val, 1], density=True)
#             ax2.plot(stats.norm.pdf(bins, np.mean(data[labels==val, 1]), np.std(data[labels==val, 1])), bins,
#                      linewidth=2.5, color=colors[i])
#             ax2.fill_betweenx(bins, stats.norm.pdf(bins, np.mean(data[labels==val, 1]), np.std(data[labels==
#                               val, 1])), 0, alpha=0.4, color=colors[i])

#             _, bins = np.histogram(data[labels==val, 2], density=True)
#             ax3.plot(-stats.norm.pdf(bins, np.mean(data[labels==val, 2]), np.std(data[labels==val, 2])), bins,
#                      linewidth=2.5, color=colors[i])
#             ax3.fill_betweenx(bins, 0, -stats.norm.pdf(bins, np.mean(data[labels==val, 2]), np.std(data[labels
#                               ==val, 2])), alpha=0.4, color=colors[i])
        
#         ax.view_init(5, -120)
#         ax.set_xlabel('Feature 1', fontsize=10)
#         ax.set_ylabel('Feature 2', fontsize=10)
#         ax.set_zlabel('Feature 3', fontsize=10, labelpad=-5, va='center') # labelpad=1,
#         ax.tick_params(axis='x', length=1.5, width=1, which='both', bottom=True, top=False, labelbottom=True, 
#                        labeltop=False, pad=-6, rotation=-90)
#         ax.tick_params(axis='y', length=1.5, width=1, which="both", bottom=False, top=False, labelbottom=True, 
#                        labeltop=True, pad=-6, rotation=90)
#         ax.tick_params(axis='z', which='both', bottom=False, top=False, labelbottom=True, labeltop=False, 
#                        pad=-2)
        
#         ax2.spines[['top', 'right', 'bottom']].set_visible(False)
#         ax3.spines[['top', 'bottom', 'left']].set_visible(False)
#         ax2.tick_params(bottom=False, top=False, labelbottom=False, right=False, left=False, labelleft=False)
#         ax3.tick_params(bottom=False, top=False, labelbottom=False, right=False, left=False, labelleft=False)

#     ax.grid(True, linestyle='--', which='major', color='grey', alpha=0.3)
#     ax1.set_title(title, fontsize=10, pad=0, y=1)
#     ax1.spines[['top', 'left', 'right']].set_visible(False)
#     ax1.tick_params(bottom=False, top=False, labelbottom=False, right=False, left=False, labelleft=False)
#     ax.legend(title='Class', fontsize=9, loc=location_legend, ncol=3, handlelength=0, handletextpad=0.25, 
#               frameon=True, labelcolor='linecolor')

#     fig.subplots_adjust(wspace=0, hspace=0)
#     plt.autoscale(enable=True, axis="x",tight=True)
#     # ax.yaxis.set_ticks(np.linspace(ax.get_yticks()[1], ax.get_yticks()[-2], int(len(ax.get_yticks()) / 2), 
#     # dtype='int'))
#     # ax.tick_params(direction='in', colors='grey', grid_color='r', grid_alpha=0.5)
