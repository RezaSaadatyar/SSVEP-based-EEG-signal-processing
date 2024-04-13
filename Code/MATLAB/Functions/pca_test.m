function label_test = pca_test(mdl, datatest)
% ================================== (2023-2024) ======================================
% ======================== Presented by: Reza Saadatyar ===============================
% ====================== E-mail: Reza.Saadatyar@outlook.com ===========================

% This function performs classification using a trained PCA model.
% Inputs:
%   - mdl: Trained PCA model.
%   - datatest: Data to be classified.
% Output:
%   - label_test: Predicted labels for the test data.
%% ====================== Flowchart for the pca_test function =========================
% Start
% 1. Get the unique labels stored in the trained PCA model `mdl` and assign them to the
%    variable `userlabel`.
% 2. Get the number of principal components stored in the trained PCA model `mdl` and 
%    assign it to the variable `nfeature`.
% 3. Get the mean vectors stored in the trained PCA model `mdl` and assign them to the 
%    variable `mu`.
% 4. Count the number of unique labels and store the result in `c`.
% 5. Get the eigenvectors stored in the trained PCA model `mdl` and assign them to the 
%    variable `w`.
% 6. Initialize a matrix `dn` with dimensions equal to the number of unique labels by 
%    the number of data points in `datatest`, filled with zeros. This matrix will store
%    the distances from each data point to each class centroid.
% 7. Iterate through each unique label:
%     a. Center the test data by subtracting the corresponding mean vector from `mu`.
%     b. If `nfeature` is 1, compute the squared distances for each data point using 
%        the single feature.
%     c. If `nfeature` is greater than 1, compute the squared distances for each data 
%        point using multiple features.
% 8. Predict the labels for the test data based on the minimum distances computed in 
%    step 7.
% 9. Return the predicted labels `label_test`.
% End
%% ====================================================================================
userlabel = mdl.userlabel; % Get unique labels from the model
num_features = mdl.num_features; % Number of principal components
mu = mdl.mu; % Mean vectors
c = numel(userlabel); % Count of unique labels
w = mdl.w; % Eigenvectors
dn = zeros(c, size(datatest, 2)); % Initialize distance matrix

for i = 1:c
    xn = datatest - repmat(mu(:, i), 1, size(datatest, 2)); % Center the test data
    if num_features == 1
        dn(i, :) = ((w(:, :, i)' * xn).^2); % Compute distances for single feature
    else
        dn(i, :) = sum((w(:, :, i)' * xn).^2);% Compute distances for multiple features
    end
end

[~, label_test] = min(dn); % Predict labels based on minimum distances
end
