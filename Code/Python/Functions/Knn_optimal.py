import numpy as np
from sklearn import neighbors
import matplotlib.pyplot as plt

# ============================================= KNN_optimal ==================================================  
def knn_optimal(data_train, label_train, data_test, label_test, display_optimal_k="off", n=21, fig_size=(3.5, 2.5)):
    """
    ================================ Presented by: Reza Saadatyar (2023-2024) ================================
    ================================= E-mail: Reza.Saadatyar@outlook.com =====================================
    This function finds the optimal number of neighbors (k) for a k-Nearest Neighbors classifier.
    Inputs:
    - data_train: Training data features.
    - label_train: Labels of the training data.
    - data_test: Test data features.
    - label_test: Labels of the test data.
    - display_optimal_k: Whether to display the optimal k value on the plot ("on" or "off").
    - n: Maximum number of neighbors to consider.
    - fig_size: Size of the figure for plotting (width, height).
    Outputs:
    - optimal_k: Optimal number of neighbors for the KNN classifier.
    ================================ Flowchart for the KNN_optimal function ==================================
    1. Start.
    2. Check if the number of rows in the training data is less than the number of columns:
        a. If true, transpose the training and test data matrices.
    3. Initialize an array t from 1 to n - 1, where n is the specified maximum number of neighbors.
    4. Initialize arrays for storing training and test accuracies for different values of k.
    5. Iterate over values of k from 1 to n - 1:
        a. Create a KNN classifier with Minkowski distance metric and k neighbors.
        b. Fit the model on the training data and calculate the training accuracy.
        c. Evaluate the model on the test data and calculate the test accuracy.
    6. If display_optimal_k is set to "on":
        a. Plot the training and test accuracies against the number of neighbors.
        b. Set x-axis ticks to the values of t.
        c. Add legend and labels to the plot.
        d. Rotate x-axis labels by 90 degrees.
        e. Set the title of the plot to indicate the optimal k value.
    7. Return the optimal number of neighbors based on the maximum test accuracy.
    8. End the function.
    ==========================================================================================================
    """
    if np.shape(data_train)[0] < np.shape(data_train)[1]:  # Convert Data training & Test >>>> m*n; m > n
        data_train = data_train.T
        data_test = data_test.T
    t = np.arange(1, n)
    accuracy_train = np.zeros(n-1)
    accuracy_test = np.zeros(n-1)
    for i in range(1 , n):
        model = neighbors.KNeighborsClassifier(metric='minkowski', n_neighbors=i)
        model.fit(data_train, label_train)
        accuracy_train[i-1] = model.score(data_train, label_train)
        accuracy_test[i-1] = model.score(data_test, label_test)
    
    if display_optimal_k == "on":
        
        plt.figure(figsize=fig_size)
        plt.plot(t, accuracy_train, label="Training")
        plt.plot(t, accuracy_test, label="Test")
        plt.xticks(t)
        plt.legend(fontsize=8)
        
        plt.xlabel("Number of neighbors")
        plt.ylabel("Accuracy")
        plt.title(f"Optimal_k for KNN: {t[np.argmax(accuracy_test)]}", fontsize=10)
        plt.tick_params(axis='x', rotation=90)

    return t[np.argmax(accuracy_test)]