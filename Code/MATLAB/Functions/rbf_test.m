function predict_labels = rbf_test(data, labels, weigth, sigma, centers, num_center_rbf)
% ================================== (2023-2024) ======================================
% ======================== Presented by: Reza Saadatyar ===============================
% ====================== E-mail: Reza.Saadatyar@outlook.com ===========================

% This function predicts labels using a trained Radial Basis Function (RBF) network.
% Inputs:
%   - data: Input data for prediction.
%   - labels: True labels of the data.
%   - weigth: Weights of the trained RBF network.
%   - sigma: Spread parameter of the RBF functions.
%   - centers: Centers of the RBF functions.
%   - num_center_rbf: Number of RBF centers.
% Output:
%   - predict_labels: Predicted labels.
%% ====================== Flowchart for the rbf_test function =========================
% Start
% 1. Initialize `predict_labels` matrix with zeros, where the number of rows is equal to
%    the number of classes and the number of columns is equal to the number of data
%    points in `data`.
% 2. Iterate through each data point in `data`:
%     a. Initialize the RBF feature vector `phi`.
%     b. Iterate through each RBF center:
%         i. Calculate the RBF value for the data point and the center using the
%            Gaussian RBF kernel formula.
%     c. Concatenate the bias term `-1` and the RBF values to form a row vector.
%     d. Compute the predicted labels for the data point by multiplying the weight
%        vector `weight` with the concatenated vector.
% 3. Convert the predicted labels from a binary matrix representation to numerical
%    labels using `vec2ind`.
% 4. Transpose the `predict_labels` matrix to get the final predicted labels.
% 5. Return the predicted labels.
% End
%% ====================================================================================
% Initialize predicted labels matrix
predict_labels = zeros(size(full(ind2vec(labels')), 1), size(data, 2));
for ii = 1:size(data, 2)
    phi = zeros(1, num_center_rbf); % Initialize RBF activations vector
    % Compute RBF activations using Gaussian function
    for j = 1:num_center_rbf
        phi(j) = exp(-(sqrt(sum((data(:, ii) - centers(:, j)).^2))) / (2 * sigma));
    end
    % Predict labels using the trained RBF network weights
    predict_labels(:, ii) = (weigth * [-1, phi]');
end
% Convert predicted labels to class indices
predict_labels = (vec2ind(predict_labels))';
end
