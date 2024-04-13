function mdl = pca_train(data, labels, num_features)
% ================================== (2023-2024) ======================================
% ======================== Presented by: Reza Saadatyar ===============================
% ====================== E-mail: Reza.Saadatyar@outlook.com ===========================

% This function trains a Principal Component Analysis (PCA) model.
% Inputs:
%   - data: Input data for training.
%   - labels: True labels of the data.
%   - nfeature: Number of principal components to retain.
% Output:
%   - mdl: Trained PCA model containing the eigenvectors, mean vectors, unique labels, 
%     and number of features.
%% ====================== Flowchart for the pca_train function ========================
% Start
% 1. Get the unique labels from the `labels` input and store them in `userlabel`.
% 2. Count the number of unique labels and store the result in `c`.
% 3. Initialize a matrix `mu` with dimensions equal to the number of features by the 
%    number of unique labels, filled with zeros. This matrix will store the mean vectors
%    for each class.
% 4. Initialize a 3D array `w` with dimensions equal to the number of features by 
%    `nfeature` by the number of unique labels, filled with zeros. This array will store
%    the eigenvectors for each class.
% 5. Iterate through each unique label:
%     a. Extract the data points corresponding to the current label from `data`.
%     b. Compute the PCA features for the extracted data using the `PCA_Feature` 
%        function and store the result in the corresponding slice of the `w` array.
%     c. Compute the mean vector for the extracted data and store it in the corresponding
%        column of the `mu` matrix.
% 6. Create the model structure `mdl`:
%     - Assign the `w` array to the field `mdl.w`.
%     - Assign the `mu` matrix to the field `mdl.mu`.
%     - Assign the `userlabel` array to the field `mdl.userlabel`.
%     - Assign the `nfeature` parameter to the field `mdl.nfeature`.
% 7. Return the trained PCA model `mdl`.
% End
%% ====================================================================================
userlabel = unique(labels); % Get unique labels
c = numel(userlabel); % Count the number of unique labels
mu = zeros(size(data, 1), c); % Initialize mean vectors
w = zeros(size(data, 1), num_features, c); % Initialize eigenvectors
% Compute PCA for each class
for i = 1:c
    xc = data(:, labels == userlabel(i)); % Extract data for the current class
    w(:, :, i) = pca_features(xc, num_features); % Compute PCA features
    mu(:, i) = mean(xc, 2); % Compute mean vector
end
% Create the model structure
mdl.w = w; % Eigenvectors
mdl.mu = mu; % Mean vectors
mdl.userlabel = userlabel; % Unique labels
mdl.num_features = num_features; % Number of features
end


function features = pca_features(data, num_features)
% ======================== Presented by: Reza Saadatyar ===============================
% ====================== E-mail: Reza.Saadatyar@outlook.com ===========================
% Inputs:
% - data: Input data for PCA.
% - nfeature: Number of principal components to retain.
%% ================ Flowchart for the pca_featuer_extraction function =================
% Start
% 1. Calculate the mean vector `mu_p` of the input data `data`.
% 2. Repeat the mean vector `mu_p` to create a matrix `reptMu` with the same dimensions
%    as `data`.
% 3. Subtract the mean vector `mu_p` from each data point in `data` to center the data 
%    around zero, resulting in the matrix `xn`.
% 4. Compute the covariance matrix `c` of the centered data matrix `xn`.
% 5. Perform eigenvalue decomposition on the covariance matrix `c`, obtaining the 
%    eigenvectors `u` and eigenvalues `d`.
% 6. Extract the diagonal elements (eigenvalues) from the eigenvalue matrix `d`.
% 7. Sort the eigenvalues in descending order and rearrange the corresponding eigenvectors
%    accordingly.
% 8. Select the top `nfeature` eigenvectors from the sorted eigenvector matrix `u`.
% 9. Output the selected eigenvectors as the principal components `features`.
% End
%% ====================================================================================
if size(data, 1) > size(data, 2); data = data'; end
% --------------------------- Step 1: Normalization -----------------------------------
mu_p = mean(data, 2); % Calculate mean
reptMu = repmat(mu_p, 1, size(data, 2)); % Repeat mean to subtract from each data point
xn = data - reptMu; % Subtract mean from data
% ------------------------- Step 2: Calculate Covariance Matrix -----------------------
c = cov(xn'); % Compute covariance matrix
% ------------------------ Step 3: Eigenvalue Decomposition ---------------------------
[u, d] = eig(c); % Perform eigenvalue decomposition
% --------------------- Step 4: Sort Eigenvalues and Eigenvectors ---------------------
d = diag(d); % Extract diagonal elements (eigenvalues)
[~, ind] = sort(d, 'descend'); % Sort eigenvalues in descending order
u = u(:, ind); % Sort eigenvectors accordingly
% ------------------------ Step 5: Select Top Eigenvectors ----------------------------
features = u(:, 1:num_features); % Select the top 'nfeature' eigenvectors

end