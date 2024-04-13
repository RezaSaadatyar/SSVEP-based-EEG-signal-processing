function [weigth, sigma, centers] = rbf_train(train_features, train_labels, num_center_rbf)
% ================================== (2023-2024) ======================================
% ======================== Presented by: Reza Saadatyar ===============================
% ====================== E-mail: Reza.Saadatyar@outlook.com ===========================

% This function trains a Radial Basis Function (RBF) network.
% Inputs:
%   - train_features: Training features.
%   - train_labels: Training labels.
%   - num_center_rbf: Number of RBF centers.
% Outputs:
%   - weigth: Weights of the RBF network.
%   - sigma: Spread parameter of the RBF functions.
%   - centers: Centers of the RBF functions.
%% ====================== Flowchart for the rbf_train function ========================
% Strat
% 1. Convert `train_labels` to a binary matrix representation using `ind2vec`.
% 2. Perform K-means clustering on the transpose of `train_features` with `num_center_rbf`
%    clusters.
% 3. Assign the cluster centers to the variable `centers`.
% 4. Compute the pairwise Euclidean distance between all pairs of cluster centers and 
%    store them in the `distance` matrix.
% 5. Calculate the value of `sigma` as the maximum distance divided by the square root 
%    of twice the number of RBF centers.
% 6. Initialize the weight matrix `wh` with zeros.
% 7. Iterate through each feature in `train_features`:
%     a. Initialize the RBF feature vector `Phi`.
%     b. Iterate through each RBF center:
%         i. Calculate the RBF value for the feature and the center using the Gaussian 
%            RBF kernel formula.
%     c. Store the computed RBF values in the `Phi` vector.
%     d. Concatenate the bias term `-1` and the RBF values to form a row in the weight 
%        matrix `wh`.
% 8. Compute the weight vector `weight` using the least square
% End
%% ====================================================================================
train_labels = full(ind2vec(train_labels')); % Convert labels to one-hot encoding
% Cluster the features to find RBF centers
[~, centers] = kmeans(train_features', num_center_rbf); 
centers = centers'; % Transpose the centers matrix
distance = zeros(num_center_rbf); % Initialize distance matrix
% Calculate Euclidean distance between each pair of centers
for ii = 1:num_center_rbf
    for j = 1:num_center_rbf
        distance(ii, j) = sqrt(sum((centers(:, ii) - centers(:, j)).^2));
    end
end
sigma = max(distance(:)) / sqrt(2 * num_center_rbf); % Calculate sigma
% Initialize matrix to hold weighted inputs
wh = zeros(num_center_rbf + 1, size(train_features, 2)); 
% Compute the RBF activations for each training sample
for ii = 1:size(train_features, 2)
    Phi = zeros(1, num_center_rbf); % Initialize RBF activations vector
    % Compute RBF activations using Gaussian function
    for j = 1:num_center_rbf
        Phi(j) = exp(-(sqrt(sum((train_features(:, ii) - centers(:, j)).^2))) / (2 * sigma));
    end
    % Append -1 for bias term and RBF activations to the weighted inputs matrix
    wh(:, ii) = [-1, Phi];
end
% Compute the RBF network weights using the Moore-Penrose pseudo-inverse
weigth = ((wh * wh') \ (wh * train_labels'))';
end