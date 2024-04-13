function features = anova_feature_selection(data, labels, num_features)
% ================================== (2023-2024) ======================================
% ======================== Presented by: Reza Saadatyar ===============================
% ====================== E-mail: Reza.Saadatyar@outlook.com ===========================

% Inputs:
% - data: Input data matrix.
% - labels: Class labels corresponding to the data.
% - num_features: Number of features to select.
%% =============== Flowchart for the anova_feature_selection function =================
% Start
% 1. If the number of rows in the data matrix is less than the number of columns, 
%    transpose the data matrix.
% 2. If the number of rows in the labels matrix is less than the number of columns, 
%    transpose the labels matrix. If the number of columns in the labels matrix is 
%    greater than 1, convert it to indices using `vec2ind`.
% 3. If the number of rows in the data matrix is still less than the number of columns,
%    transpose the data matrix again.
% 4. If the specified number of features is greater than the total number of features 
%    in the data matrix, set the number of features to the total number of features.
% 5. Initialize an array `pvalue` to store the p-values for each feature.
% 6. For each feature in the data matrix:
%     a. Compute the p-value using ANOVA test with `anova1`.
% 7. Sort the p-values in ascending order and get the indices of the sorted features.
% 8. Select the top `num_features` features based on their indices.
% 9. Output the selected features.
% End
%% ====================================================================================
if size(data, 1) < size(data, 2); data = data'; end
if size(labels, 1) < size(labels, 2); labels = labels'; if size(labels, 2) > 1
        labels= vec2ind(labels'); end
end
if num_features > size(data, 2); num_features = size(data, 2); end

pvalue = zeros(size(data, 2), 1);

for i = 1:size(data, 2)
    pvalue(i) = anova1(data(:, i), labels, 'off');
end
[~, ind]= sort(pvalue, 'ascend');

features= data(:, ind(1:num_features));
end