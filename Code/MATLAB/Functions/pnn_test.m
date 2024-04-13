function predict_labels = pnn_test(train_data, test_data, train_labels, wkk, sigma_pnn,...
         type_pnn)
% ================================== (2023-2024) ======================================
% ======================== Presented by: Reza Saadatyar ===============================
% ====================== E-mail: Reza.Saadatyar@outlook.com ===========================

% This function tests a Probabilistic Neural Network (PNN) classifier.
% Inputs:
%   - train_data: Training data.
%   - test_data: Test data.
%   - train_labels: Labels of the training data.
%   - wkk: Normalized training features.
%   - sigma_pnn: Standard deviation parameter for PNN.
%   - type: Type of distance metric ('Euclidean' or 'Mahalanobis').
% Output:
%   - predict_labels: Predicted labels for the test data.
%% ====================== Flowchart for the pnn_test function =========================
% Start
% 1. Initialize a matrix `okk` with dimensions equal to the number of training data 
%    points by the number of test data points, filled with zeros.
% 2. Test the PNN:
%     a. Iterate through each test data point:
%         i. Normalize the current test data point `xn` by subtracting the mean and 
%            dividing by the standard deviation of the training data.
%         ii. If the `type` is 'Euclidean':
%             - Compute the dot product between the normalized training features `wkk` 
%               and the current normalized test data point `xn`. Store the result in 
%               `zkk`.
%             - Compute the output of the PNN for the current test data point using the
%               formula `exp((zkk - 1) / sigma_pnn)`. Store the result in the 
%               corresponding column of `okk`.
%         iii. If the `type` is 'Mahalanobis':
%             - Compute the Euclidean distance `r` between the current normalized test 
%               data point `xn` and each row of `wkk`.
%             - Compute the output of the PNN for the current test data point using the 
%               formula `(1 / sqrt(2 * pi * sigma_pnn)) * exp(-(r) / (2 * sigma_pnn))`.
%               Store the result in the corresponding column of `okk`.
% 3. Initialize a matrix `s` with dimensions equal to the number of unique classes in 
%    `train_labels` by the number of test data points, filled with zeros.
% 4. Identify the unique classes in `train_labels` and store them in `classes`.
% 5. Initialize a cell array `index` with dimensions 1 by the number of unique classes.
% 6. Accumulate the outputs for each class:
%     a. For each unique class `ii`:
%         i. Find the indices of training data points corresponding to class `ii` and 
%            store them in `index{ii}`.
%     b. For each unique class `j`:
%         i. Compute the sum of the PNN outputs for the training data points belonging 
%            to class `j` and store the result in the `j`-th row of `s`.
% 7. Predict the labels for the test data by selecting the class with the maximum sum 
%    of PNN outputs for each test data point. Store the predicted labels in `predict_labels`.
% End
%% ====================================================================================
okk = zeros(size(train_data, 2), size(test_data, 2));   
    % Test the PNN
    for jj = 1:size(test_data, 2)
        xn = (test_data(:, jj) - mean(train_data, 2)) ./ std(train_data, 0, 2);
        if strcmp(type_pnn, 'Euclidean')
            zkk = wkk' * xn;
            okk(:, jj) = exp((zkk - 1) / sigma_pnn);
        else
            r = sqrt(sum((repmat(xn, 1, size(wkk, 2)) - wkk).^2));
            okk(:, jj) = (1 / sqrt(2 * pi * sigma_pnn)) * exp(-(r) / (2 * sigma_pnn));
        end
    end
    
    s = zeros(numel(unique(train_labels)), size(test_data, 2));
    classes = unique(train_labels);
    for ii = 1:numel(unique(train_labels))
        index{ii} = find(train_labels == classes(ii));
    end
    
    for j = 1:numel(unique(train_labels))
        s(j, :) = sum(okk(index{j}, :));
    end
    [~, predict_labels] = max(s); % Predict labels
end