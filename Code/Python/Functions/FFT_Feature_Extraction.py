import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
from sklearn import preprocessing

def fft_feature_extraction(data, fs, num_channel, subbands, labels=None, display_figuare="off"):
    
    f = np.linspace(0, fs / 2, data.shape[0] // 2 + 1) # Calculate frequency vector
    features = np.zeros((data.shape[-1], np.array(subbands).shape[1] * len(num_channel)))

    for i in range(data.shape[-1]):
        data_fft = np.fft.fft(data[:, num_channel, i], axis=0) # Compute FFT
        data_psd = np.abs(data_fft[:len(data_fft) // 2, :])         # Compute power spectral density (PSD)
        
        for ind_sb, (val_sb1, val_sb2) in enumerate(zip(*subbands)): # Feature extraction for each subband
            # Find indices corresponding to the subband
            ind = np.where((f >= val_sb1) & (f <= val_sb2))[0]
            
            # Update features with maximum PSD within subband
            features[i, ind_sb * len(num_channel):(ind_sb + 1) * len(num_channel)] = np.max(data_psd[ind, :], 
                                                                                        axis=0)
    if display_figuare == "on":
        fig = plt.figure()   # Plot features
        norm = preprocessing.MinMaxScaler()
        features = norm.fit_transform(features)
        classes = np.unique(labels)   # Get unique classes
        colors = sns.color_palette("bright", len(classes)).as_hex() # Define colors
        
        if features.shape[1] >= 3:
            ax = fig.add_subplot(111, projection='3d')
            ax.set_xlabel('Feature 1', fontsize=10, loc="center", labelpad=0)
            ax.set_ylabel('Feature 2', fontsize=10, loc="center", labelpad=1)
            ax.set_zlabel('Feature 3', fontsize=10, va="center", labelpad=0)
            plt.tick_params(axis='x', length=1.5, width=1, which='both', bottom=True, top=False, labelbottom=
                            True, labeltop=False, pad=-3)
            plt.tick_params(axis='y', length=1.5, width=1, which="both", bottom=False, top=False, labelbottom=
                            True, labeltop=True, pad=-5, rotation=50)
            plt.tick_params(axis='z', length=1.5, width=1, which="both", bottom=False, top=False, labelbottom=
                            True, labeltop=True, pad=0)
            ax.view_init(5, -110)
        
        for i, cls in enumerate(classes):
            if features.shape[1] < 3:
                plt.plot(features[labels == cls, 0], features[labels == cls, 1], "o", label=cls, color=colors[i], 
                        linewidth=2, markersize=3)
                plt.xlabel('Feature 1', fontsize=10, loc="center", labelpad=0)
                plt.ylabel('Feature 2', loc="center", labelpad=0)
            else:
                ax.plot3D(features[labels == cls, 0], features[labels == cls, 1], features[labels == cls, 2],
                          "o", color=colors[i], label=cls, linewidth=2, markersize=3)
        
        plt.autoscale(enable=True, axis="x", tight=True)
        plt.legend(title='Class', loc=5, fontsize=9, ncol=1, handlelength=0, handletextpad=0.25, frameon=False, 
            labelcolor='linecolor') # Set legend
    
    return features
