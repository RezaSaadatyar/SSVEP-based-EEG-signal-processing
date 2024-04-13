function features = pca_feature_extraction(data, num_features)
% ================================== (2023-2024) ======================================
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
if size(data, 1) < size(data, 2); data = data'; end
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