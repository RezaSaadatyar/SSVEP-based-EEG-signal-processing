import numpy as np
from sklearn import metrics
import matplotlib.pyplot as plt

# ============================================== Roc curve ===================================================
def roc_curve(model, data_train=None, data_test=None, label_train=None, label_test=None, k_fold=None,
              type_class=None, fig_size_Roc=(5, 3)):
    """
    ================================ Presented by: Reza Saadatyar (2023-2024) ================================
    ================================= E-mail: Reza.Saadatyar@outlook.com =====================================
    Inputs:
    - model: The trained classification model.
    - data_train: The training data.
    - data_test: The test data.
    - label_train: The labels corresponding to the training data.
    - label_test: The labels corresponding to the test data.
    - k_fold: The fold number for cross-validation.
    - type_class: The type of classification.
    - display_Roc_classes: Whether to display the ROC curves for each class.
    - fig_size_Roc: The size of the ROC curve plot.

    Outputs:
    - mean_tpr_tr: The mean true positive rate for the training data.
    - mean_tpr_te: The mean true positive rate for the test data.
    - mean_auc_tr: The mean Area Under the Curve (AUC) for the training data.
    - mean_auc_te: The mean AUC for the test data.
    ================================== Flowchart for the Roc curve function ==================================
    1. Start.
    2. Initialize lists and variables to store false positive rate (fpr), true positive rate (tpr), and ROC AUC
       for each class and fold.
    3. Binarize the labels for each class using one-hot encoding.
    4. Predict the class probabilities for each class using the trained model.
    5. Calculate the ROC curve for each class:
        a. Compute fpr and tpr using metrics.roc_curve for both training and test data.
        b. Calculate the area under the ROC curve (ROC AUC) for each class.
    6. Calculate the mean true positive rate across all folds and classes.
    7. Plot ROC curves for each class and compute macro-average and micro-average ROC curves:
        a. Plot ROC curves for each class using fpr and tpr.
        b. Plot macro-average and micro-average ROC curves.
        c. Compute ROC AUC for macro-average and micro-average curves.
    8. Set axis limits, titles, labels, grid, and legend for the plots.
    9. Return mean true positive rates and ROC AUC for training and test data.
    10. End.
    ==========================================================================================================
    """
    mean_tpr_tr, mean_tpr_te, mean_auc_tr, mean_auc_te = [], [], [], []
    mean_fpr = np.linspace(0, 1, 100)
    if data_train is not None and data_test is None:
        fig1, ax1 = plt.subplots(nrows=1, ncols=1, figsize=fig_size_Roc, constrained_layout=True)
    elif data_test is not None and data_train is None:
        fig1, ax2 = plt.subplots(nrows=1, ncols=1, figsize=fig_size_Roc, constrained_layout=True)
    else:
        fig1, (ax1, ax2) = plt.subplots(nrows=1, ncols=2, figsize=fig_size_Roc, constrained_layout=True)
    # ======================================== Section train model  ==========================================
    # Initialize lists fpr, tpr, and roc_auc for each class
    mean_tpr_tr, fpr_tr, tpr_tr, roc_auc_tr = 0.0, dict(), dict(), []
    # -------------------------------- Binarize the labels for each class ------------------------------------
    if data_train is not None:
        num_classes = np.max(label_train) + 1
        label_tr = np.eye(num_classes)[label_train]
        y_scores_tr = model.predict_proba(data_train)   # Predict the labels for each class
        for i in range(label_tr.shape[1]):              # ROC curve for each class 
            fpr_tr[i], tpr_tr[i], _ = metrics.roc_curve(label_tr[:, i], y_scores_tr[:, i])
            roc_auc_tr.append(metrics.auc(fpr_tr[i], tpr_tr[i]))
            mean_tpr_tr += np.interp(mean_fpr, fpr_tr[i], tpr_tr[i]) # Interpolate the mean_tpr at mean_fpr
            mean_tpr_tr[0] = 0.0
            
        mean_tpr_tr = mean_tpr_tr / (i+1) # Calculate mean true positive rate across all folds and classes
        mean_auc_tr = metrics.auc(mean_fpr, mean_tpr_tr)
        # Compute macro-average ROC curve and ROC area (First aggregate all false positive rates)
        all_fpr_tr = np.unique(np.concatenate([fpr_tr[i] for i in range(label_tr.shape[1])]))
        avg_tpr_tr = np.zeros_like(all_fpr_tr)        # Interpolate all ROC curves at this points
        for i in range(label_tr.shape[1]):
            avg_tpr_tr += np.interp(all_fpr_tr, fpr_tr[i], tpr_tr[i])
            
        avg_tpr_tr /= label_tr.shape[1]               # Finally average it and compute AUC
        fpr_tr[i+1] = all_fpr_tr
        tpr_tr[i+1] = avg_tpr_tr
        roc_auc_tr.append(metrics.auc(fpr_tr[i+1], tpr_tr[i+1]))
        # Compute micro-average ROC curve and ROC area 
        fpr_tr[i+2], tpr_tr[i+2], _ = metrics.roc_curve(label_tr.ravel(), y_scores_tr.ravel())
        roc_auc_tr.append(metrics.auc(fpr_tr[i+2], tpr_tr[i+2]))
        
        for i in range(label_tr.shape[1]):        # Plot ROC curve for each class 
            ax1.plot(fpr_tr[i], tpr_tr[i], lw=1.2, label=f"Class {i}:{roc_auc_tr[i]:.2f}")
            
        ax1.plot([0, 1], [0, 1], linestyle='--', color='gray', lw=1.2) # Plot Macro avg & Micro avg 
        ax1.plot(fpr_tr[i+1], tpr_tr[i+1] , color='blue', linestyle='-', lw=1.2, label=f"Macro avg:{roc_auc_tr[i+1]:.2f}")
        ax1.plot(fpr_tr[i+2], tpr_tr[i+2] , color='g', linestyle='-', lw=1.2, label=f"Micro avg:{roc_auc_tr[i+2]:.2f}")
        ax1.axis(xmin=-0.03, xmax=1, ymin=-0.03, ymax=1.03)    # Set x-axis and y-axis limits in a single line
        ax1.set_title("Train model", fontsize=10, pad=0, loc="left")
        ax1.grid(True, linestyle='--', which='major', color='grey', alpha=0.5, axis="y")
        ax1.legend(title="AUC", loc='lower right',fontsize=9, ncol=1, frameon=True, labelcolor='linecolor', handlelength=0)
        ax1.set_xlabel('False Positive Rate (FPR)', fontsize=10)
        ax1.set_ylabel('True Positive Rate (TPR)', fontsize=10)
    # ========================================= Section test model ===========================================
    # Initialize lists fpr, tpr, and roc_auc for each class
    mean_tpr_te, fpr_te, tpr_te, roc_auc_te = 0.0, dict(), dict(), []
    # -------------------------------- Binarize the labels for each class ------------------------------------
    if data_test is not None:
        num_classes = np.max(label_test) + 1
        label_te = np.eye(num_classes)[label_test]
        y_scores_te = model.predict_proba(data_test)    # Predict the labels for each class
        for i in range(label_tr.shape[1]):              # ROC curve for each class 
            fpr_te[i], tpr_te[i], _ = metrics.roc_curve(label_te[:, i], y_scores_te[:, i])
            roc_auc_te.append(metrics.auc(fpr_te[i], tpr_te[i]))
            mean_tpr_te += np.interp(mean_fpr, fpr_te[i], tpr_te[i])  # Interpolate the mean_tpr at mean_fpr
            mean_tpr_te[0] = 0.0
            
        mean_tpr_te = mean_tpr_te / (i+1) # Calculate mean true positive rate across all folds and classes
        mean_auc_te = metrics.auc(mean_fpr, mean_tpr_te)
        # Compute macro-average ROC curve and ROC area (First aggregate all false positive rates)
        all_fpr_te = np.unique(np.concatenate([fpr_te[i] for i in range(label_te.shape[1])]))
        avg_tpr_te = np.zeros_like(all_fpr_te)        # Interpolate all ROC curves at this points
        for i in range(label_tr.shape[1]):
            avg_tpr_te += np.interp(all_fpr_te, fpr_te[i], tpr_te[i])
            
        avg_tpr_te /= label_te.shape[1]               # Finally average it and compute AUC
        fpr_te[i+1] = all_fpr_te
        tpr_te[i+1] = avg_tpr_te
        roc_auc_te.append(metrics.auc(fpr_te[i+1], tpr_te[i+1]))
        # Compute micro-average ROC curve and ROC area
        fpr_te[i+2], tpr_te[i+2], _ = metrics.roc_curve(label_te.ravel(), y_scores_te.ravel())
        roc_auc_te.append(metrics.auc(fpr_te[i+2], tpr_te[i+2]))
        
        for i in range(label_tr.shape[1]):            #  Plot ROC curve for each class
            ax2.plot(fpr_te[i], tpr_te[i], lw=1.2, label=f"Class {i}:{roc_auc_te[i]:.2f}")

        ax2.plot([0, 1], [0, 1], linestyle='--', color='gray', lw=1.2) # Plot Macro avg & Micro avg 
        ax2.plot(fpr_te[i+1], tpr_te[i+1] , color='blue', linestyle='-', lw=1.2, label=f"Macro avg:{roc_auc_te[i+1]:.2f}")
        ax2.plot(fpr_te[i+2], tpr_te[i+2] , color='g', linestyle='-', lw=1.2, label=f"Micro avg:{roc_auc_te[i+2]:.2f}")
        ax2.axis(xmin=-0.03, xmax=1, ymin=-0.03, ymax=1.03)     # Set x-axis and y-axis limits in a single line
        ax2.set_title("Test model", fontsize=10, pad=0, loc="right")
        ax2.set_xlabel('False Positive Rate (FPR)', fontsize=10)
        ax2.grid(True, linestyle='--', which='major', color='grey', alpha=0.5, axis="y")
        ax2.legend(title="AUC", loc='lower right',fontsize=9, ncol=1, frameon=True, labelcolor='linecolor', handlelength=0)

    # plt.autoscale(axis="x", tight=True, enable=True)
    fig1.suptitle(f"{type_class} ROC curve for the k-fold: {k_fold+1}", fontsize=10)

    return mean_tpr_tr, mean_tpr_te, mean_auc_tr, mean_auc_te
