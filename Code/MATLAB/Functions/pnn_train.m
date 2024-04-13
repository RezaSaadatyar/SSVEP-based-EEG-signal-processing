function [predict_labels, wkk] = pnn_train(train_features, train_labels, sigma_pnn, type)
% ================================== (2023-2024) ======================================
% ======================== Presented by: Reza Saadatyar ===============================
% ====================== E-mail: Reza.Saadatyar@outlook.com ===========================

% This function trains a Probabilistic Neural Network (PNN) classifier.
% Inputs:
%   - train_features: Training data features.
%   - train_labels: Labels of the training data.
%   - sigma_pnn: Standard deviation parameter for PNN.
%   - type: Type of distance metric ('Euclidean' or 'Mahalanobis').
% Outputs:
%   - predict_labels: Predicted labels for the training data.
%   - wkk: Normalized training features.
%% ===================== Flowchart for the pnn_train function =========================
% Start
% 1. Normalize the training features `train_features` by subtracting the mean and dividing 
%    by the standard deviation along each feature dimension. Store the normalized 
%    features in `wkk`.
% 2. Initialize a matrix `okk` with dimensions equal to the number of training features
%    by the number of training features, filled with zeros.
% 3. Train the PNN:
%     a. Iterate through each training feature:
%         i. Normalize the current training feature `xn` by subtracting the mean and 
%            dividing by the standard deviation.
%         ii. If the `type` is 'Euclidean':
%             - Compute the dot product between the normalized training features `wkk` 
%               and the current normalized feature `xn`. Store the result in `zkk`.
%             - Compute the output of the PNN for the current feature using the formula
%               `exp((zkk - 1) / sigma_pnn)`. Store the result in the corresponding 
%                column of `okk`.
%         iii. If the `type` is 'Mahalanobis':
%             - Compute the Euclidean distance `r` between the current normalized 
%               feature `xn` and each row of `wkk`.
%             - Compute the output of the PNN for the current feature using the formula
%               `(1 / sqrt(2 * pi * sigma_pnn)) * exp(-(r) / (2 * sigma_pnn))`. Store 
%                the result in the corresponding column of `okk`.
% 4. Identify the unique classes in the training labels and store them in `classes`.
% 5. Count the number of unique classes and store the result in `class`.
% 6. Initialize a cell array `index` with dimensions 1 by `class`.
% 7. Initialize a matrix `s` with dimensions equal to the number of unique classes by 
%    the number of training features, filled with zeros.
% 8. Accumulate the outputs for each class:
%     a. For each unique class `ii`:
%         i. Find the indices of training features corresponding to class `ii` and 
%            store them in `index{ii}`.
%     b. For each unique class `j`:
%         i. Compute the sum of the PNN outputs for the training features belonging to 
%            class `j` and store the result in the `j`-th row of `s`.
% 9. Predict the labels for the training data by selecting the class with the maximum 
%    sum of PNN outputs for each training feature. Store the predicted labels in 
%    `predict_labels`.
% End
%% ====================================================================================
    % Normalize training features
    wkk = (train_features - repmat(mean(train_features, 2), 1, size(train_features, 2)))...
        ./ repmat(std(train_features, 0, 2), 1, size(train_features, 2));

    okk = zeros(size(train_features, 2));
    
    % Train the PNN
    for jj = 1:size(train_features, 2)
        xn = (train_features(:, jj) - mean(train_features, 2)) ./ std(train_features,...
            0, 2);
        if strcmp(type, 'Euclidean')
            zkk = wkk' * xn;
            okk(:, jj) = exp((zkk - 1) / sigma_pnn);
        else
            r = sqrt(sum((repmat(xn, 1, size(wkk, 2)) - wkk).^2));
            okk(:, jj) = (1 / sqrt(2 * pi * sigma_pnn)) * exp(-(r) / (2 * sigma_pnn));
        end
    end

    classes = unique(train_labels);
    class = numel(classes);
    index = cell(1, class);
    s = zeros(class, size(train_features, 2));
    
    % Accumulate outputs for each class
    for ii = 1:class
        index{ii} = find(train_labels == classes(ii));
    end

    for j = 1:class
        s(j, :) = sum(okk(index{j}, :));
    end
    [~, predict_labels] = max(s); % Predict labels
end