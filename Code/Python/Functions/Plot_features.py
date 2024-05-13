import numpy as np
import seaborn as sns
from scipy import stats
import matplotlib.pyplot as plt
from sklearn import preprocessing

# ============================================ Plot features =================================================
def plot_features(data, labels, title=None, location_legend=5, fig_size=(4, 3)):
    """
    =============================== Presented by: Reza Saadatyar (2023-2024) =================================
    ================================ E-mail: Reza.Saadatyar@outlook.com ======================================
    Parameters:
    - data: Feature matrix with dimensions (number of samples, number of features).
    - labels: Array of labels corresponding to each sample.
    - title: Title for the plot.
    - fig_size: Tuple specifying the size of the figure (default is (4, 3)).
    ============================== Flowchart for the plot_features function ==================================
    Start
    1. Convert the input data to a numpy array if it's not already in that format.
    2. Transpose the data if necessary to ensure proper dimensions.
    3. Obtain the unique classes from the labels.
    4. Define colors for each class using the seaborn color palette.
    5. Normalize the data using Min-Max scaling.
    6. Plot the data based on the number of features:
        a. If there's only one feature:
            i. Create a 4x4 grid for plotting.
            ii. Plot the feature values against the sample indices for each class.
            iii. Plot the Gaussian distribution of the feature values for each class.
        b. If there are two features:
            i. Create a 4x4 grid for plotting.
            ii. Plot the feature values in a scatter plot for each class.
            iii. Plot the Gaussian distribution of each feature for each class.
        c. If there are more than two features:
            i. Create a 3D plot for visualizing the features.
            ii. Plot the feature values in a 3D scatter plot for each class.
            iii. Plot the Gaussian distribution of each feature for each class.
    7. Adjust the subplot layout and spacing.
    8. Return the plot.
    """
    # --------------------------- Convert data to ndarray if it's not already --------------------------------
    data = np.array(data) if not isinstance(data, np.ndarray) else data
    
    # Transpose the data if it has more than one dimension and has fewer rows than columns
    data = data.T if data.ndim > 1 and data.shape[0] < data.shape[-1] else data
    
    # --------------------------------------------- Unique labels --------------------------------------------
    classes = np.unique(labels)
    colors = sns.color_palette("bright", len(classes)).as_hex() # Define colors
    # ---------------------------------------- Data normalization --------------------------------------------
    norm = preprocessing.MinMaxScaler()
    data = norm.fit_transform(data)
    # --------------------------------------------- Plot -----------------------------------------------------
    if data.shape[-1] == 1:
        fig = plt.figure(figsize=fig_size)
        grid = plt.GridSpec(4, 4, hspace=0.06, wspace=0.06)
        ax = fig.add_subplot(grid[1:, :3])
        ax1 = fig.add_subplot(grid[0, :3], yticklabels=[], sharex=ax)
        
        for i, val in enumerate(classes):
            
            tim = np.linspace(np.min(data[labels==val, 0]), np.max(data[labels==val, 0]), num=len(data[labels
                              ==val, 0]), retstep=True)
            ax.plot(tim[0], data[labels==val, 0], '.', markersize=10, color=colors[i], label=val)
            
            _, bins = np.histogram(data[labels==val, 0], density=True)
            ax1.plot(bins, stats.norm.pdf(bins, np.mean(data[labels==val, 0]), np.std(data[labels==val, 0])),
                     linewidth=1.5, color=colors[i])
            ax1.fill_between(bins, y1=stats.norm.pdf(bins, np.mean(data[labels==val, 0]), np.std(data[labels==
                             val, 0])), y2=0, alpha=0.4)
            
        ax.set_xlabel('Feature 1', fontsize=10, va='center')
        ax.tick_params(axis='x', length=1.5, width=1, which='both', bottom=True, top=False, labelbottom=True, 
                       labeltop=False, pad=0)
        ax.tick_params(axis='y', length=1.5, width=1, which="both", bottom=False, top=False, labelbottom=True,
                       labeltop=True, pad=0)
        
    elif data.shape[-1] < 3:
        fig = plt.figure(figsize=fig_size)
        grid = plt.GridSpec(4, 4, hspace=0.06, wspace=0.06)
        ax = fig.add_subplot(grid[1:, :3])
        ax1 = fig.add_subplot(grid[0, :3], yticklabels=[], sharex=ax)
        ax2 = fig.add_subplot(grid[1:, 3], xticklabels=[], sharey=ax)
        
        for i, val in enumerate(classes):
            
            ax.plot(data[labels==val, 0], data[labels==val, 1], '.', markersize=10, color=colors[i], label=
                    val)
            
            _, bins = np.histogram(data[labels==val, 0], density=True)
            ax1.plot(bins, stats.norm.pdf(bins, np.mean(data[labels==val, 0]), np.std(data[labels==val, 0])), 
                     linewidth=1.5, color=colors[i])
            ax1.fill_between(bins, y1=stats.norm.pdf(bins, np.mean(data[labels==val, 0]), np.std(data[labels==
                             val, 0])), y2=0, alpha=0.4)

            _, bins = np.histogram(data[labels==val, 1], density=True)
            ax2.plot(stats.norm.pdf(bins, np.mean(data[labels==val, 1]), np.std(data[labels==val, 1])), bins,
                     linewidth=2.5, color=colors[i])
            ax2.fill_betweenx(bins, stats.norm.pdf(bins, np.mean(data[labels==val, 1]), np.std(data[labels==
                              val, 1])), 0, alpha=0.4, color=colors[i])

        ax2.spines[['top', 'right', 'bottom']].set_visible(False)
        ax2.tick_params(bottom=False, top=False, labelbottom=False, right=False, left=False, labelleft=False)
        ax.set_xlabel('Feature 1', fontsize=10)
        ax.set_ylabel('Feature 2', fontsize=10)
        ax.tick_params(axis='x', length=1.5, width=1, which='both', bottom=True, top=False, labelbottom=True,
                       labeltop=False, pad=0)
        ax.tick_params(axis='y', length=1.5, width=1, which="both", bottom=False, top=False, labelbottom=True,
                       labeltop=True, pad=0)
            
    elif data.shape[-1] > 2:
        fig = plt.figure(figsize=[4, 3])
        ax = fig.add_axes((0.02, -0.05, 0.9, 0.9), projection="3d")
        ax1 = fig.add_axes((0.22, 0.67, 0.52, 0.16))
        ax2 = fig.add_axes((0.8, 0.18, 0.13, 0.47))
        ax3 = fig.add_axes((-0.05, 0.18, 0.13, 0.47))
        
        for i, val in enumerate(classes):
            
            ax.plot3D(data[labels==val, 0], data[labels==val, 1], data[labels==val, 2], '.', markersize=10, 
                      color=colors[i], label=val)
            
            _, bins = np.histogram(data[labels==val, 0], density=True)
            ax1.plot(bins, stats.norm.pdf(bins, np.mean(data[labels==val, 0]), np.std(data[labels==val, 0])),
                     linewidth=2.5, color=colors[i])
            ax1.fill_between(bins, y1=stats.norm.pdf(bins, np.mean(data[labels==val, 0]), np.std(data[labels==
                             val, 0])), y2=0, alpha=0.4, color=colors[i])
            
            _, bins = np.histogram(data[labels==val, 1], density=True)
            ax2.plot(stats.norm.pdf(bins, np.mean(data[labels==val, 1]), np.std(data[labels==val, 1])), bins,
                     linewidth=2.5, color=colors[i])
            ax2.fill_betweenx(bins, stats.norm.pdf(bins, np.mean(data[labels==val, 1]), np.std(data[labels==
                              val, 1])), 0, alpha=0.4, color=colors[i])

            _, bins = np.histogram(data[labels==val, 2], density=True)
            ax3.plot(-stats.norm.pdf(bins, np.mean(data[labels==val, 2]), np.std(data[labels==val, 2])), bins,
                     linewidth=2.5, color=colors[i])
            ax3.fill_betweenx(bins, 0, -stats.norm.pdf(bins, np.mean(data[labels==val, 2]), np.std(data[labels
                              ==val, 2])), alpha=0.4, color=colors[i])
        
        ax.view_init(5, -120)
        ax.set_xlabel('Feature 1', fontsize=10)
        ax.set_ylabel('Feature 2', fontsize=10)
        ax.set_zlabel('Feature 3', fontsize=10, labelpad=-5, va='center') # labelpad=1,
        ax.tick_params(axis='x', length=1.5, width=1, which='both', bottom=True, top=False, labelbottom=True, 
                       labeltop=False, pad=-6, rotation=-90)
        ax.tick_params(axis='y', length=1.5, width=1, which="both", bottom=False, top=False, labelbottom=True, 
                       labeltop=True, pad=-6, rotation=90)
        ax.tick_params(axis='z', which='both', bottom=False, top=False, labelbottom=True, labeltop=False, 
                       pad=-2)
        
        ax2.spines[['top', 'right', 'bottom']].set_visible(False)
        ax3.spines[['top', 'bottom', 'left']].set_visible(False)
        ax2.tick_params(bottom=False, top=False, labelbottom=False, right=False, left=False, labelleft=False)
        ax3.tick_params(bottom=False, top=False, labelbottom=False, right=False, left=False, labelleft=False)

    ax.grid(True, linestyle='--', which='major', color='grey', alpha=0.3)
    ax1.set_title(title, fontsize=10, pad=0, y=1)
    ax1.spines[['top', 'left', 'right']].set_visible(False)
    ax1.tick_params(bottom=False, top=False, labelbottom=False, right=False, left=False, labelleft=False)
    ax.legend(title='Class', fontsize=9, loc=location_legend, ncol=3, handlelength=0, handletextpad=0.25, 
              frameon=True, labelcolor='linecolor')

    fig.subplots_adjust(wspace=0, hspace=0)
    plt.autoscale(enable=True, axis="x", tight=True)
    # ax.yaxis.set_ticks(np.linspace(ax.get_yticks()[1], ax.get_yticks()[-2], int(len(ax.get_yticks()) / 2), 
    # dtype='int'))
    # ax.tick_params(direction='in', colors='grey', grid_color='r', grid_alpha=0.5)