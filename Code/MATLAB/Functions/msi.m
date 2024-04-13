function s = msi(data, data_ref, num_harmonic)
% ================================== (2023-2024) ======================================
% ======================== Presented by: Reza Saadatyar ===============================
% ====================== E-mail: Reza.Saadatyar@outlook.com ===========================

% Inputs:
% - data: Input data matrix.
% - data_ref: Reference data matrix.
% - num_harmonic: Number of harmonic components.
%% ======================= Flowchart for the msi function =============================
% Start
% 1. If the number of rows in the data matrix is less than the number of columns, 
%    transpose the data matrix.
% 2. Determine the number of channels in the data.
% 3. Compute the covariance matrix `c` which includes both the autocorrelation and cross-
%    correlation of `data` and `data_ref`.
% 4. Extract submatrices `c1`, `c2`, `c12`, and `c21` from `c`.
% 5. Construct the transformed correlation matrix `r` using the linear transformation.
% 6. Perform eigenvalue decomposition on `r` to obtain eigenvalues.
% 7. Normalize the eigenvalues.
% 8. Compute the synchronization index `s` using the normalized eigenvalues.
% 9. Output the synchronization index `s`.
% End
%% ====================================================================================
% n is the number of samples, and n_h is the number of harmonics for the sine and cosine 
% components
% Article: Multivariate synchronization index for frequency recognition of SSVEP-based 
% brain–computer interface.
% matrix c includes both the autocorrelation and crosscorrelation of x and data_ref, and
% the autocorrelation will inﬂuence the synchronization measure. To reduce these inﬂuences, 
% the following linear transformation is adopted.
%% ------------------------------- Step 1: Covariance matrixs -------------------------
if size(data, 1) < size(data, 2)
    data = data.T;
end

num_channel = size(data, 2);    % Size x ---> n × num_Channel and data_ref --->2n_h ×n;
c = cov([data, data_ref]);
c1 = c(1:num_channel, 1:num_channel);
c2 = c(num_channel + 1:end, num_channel + 1:end);
c12 = c(1:num_channel, num_channel + 1:end);
c21 = c(num_channel + 1:end, 1:num_channel);
%% ---------------------- Step 2: Transformed corrleation matrix ----------------------
r = [eye(num_channel)                real((sqrt(c1) \ (c12 + eps)) / (sqrt(c2) + eps));
    real((sqrt(c2) \ (c21 + eps)) / (sqrt(c1) + eps))   eye(2 * num_harmonic)];  
%% ----------------------- Step 3: Eigenvalues of matrix ------------------------------
[~, landa] = eig(r);
landa = diag(landa);
landa = landa./sum(landa);     % Normalize eigenvalues
%% ----------------- Step 4: Synchronization index between two signals ----------------
s = 1 + (sum(landa.*log(landa)) / log(num_channel + 2 * num_harmonic));

% If the two sets of signals are uncorrelated, c12 = c21 = 0, and R will be diagonal. 
% Then, S should be zero.
% If the two sets of signals are perfectly correlated, r will have ones on the main 
% diagonal and zeros elsewhere. 
% Only one normalized eigenvalue is one, and the other eigenvalues are zeros.Therefore,
% s should be one. 
% For other situations, the s value should range from zero to one.
end