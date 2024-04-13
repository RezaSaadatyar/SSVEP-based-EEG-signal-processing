function [acc, sen, spe, pre, fm, mcc] = confusion_matrix(label_test, label)
% ================================== (2023-2024) ======================================
% ======================== Presented by: Reza Saadatyar ===============================
% ====================== E-mail: Reza.Saadatyar@outlook.com ===========================

% This function calculates various performance metrics for a confusion matrix.
% Inputs:
%   - label_test: The predicted labels.
%   - label: The true labels.
% Outputs:
%   - acc: Accuracy.
%   - sen: Sensitivity.
%   - spe: Specificity.
%   - pre: Precision.
%   - fm: F-measure.
%   - mcc: Matthews correlation coefficient.
%% ================== Flowchart for the confusion_matrix function =====================
% Start
% 1. Check if the `label` input is a cell array:
%     a. If yes, compute accuracy by comparing each element of `label_test` with `label`.
%     b. If no, compute accuracy by subtracting `label_test` from `label` and counting 
%     the number of zero differences.
% 2. Compute the confusion matrix `cmax` using the `confusionmat` function.
% 3. Initialize sensitivity (`sen`), specificity (`spe`), precision (`pre`), F-measure 
% (`fm`), and Matthews correlation coefficient (`mcc`).
% 4. Check the length of `cmax`:
%     a. If it's 2, perform calculations for binary classification:
%         i. Compute True Positives (Tp), True Negatives (Tn), False Negatives (Fn), 
%            and False Positives (Fp).
%         ii. Calculate sensitivity, specificity, precision, F-measure, and Matthews 
%             correlation coefficient.
%     b. If it's greater than 2, perform calculations for multiclass classification:
%         i. Iterate through each class in the confusion matrix.
%         ii. Calculate sensitivity, specificity, precision, F-measure, and Matthews 
%             correlation coefficient for each class.
% 5. Calculate the average sensitivity, specificity, precision, F-measure, and Matthews 
%    correlation coefficient for multiclass classification.
% 6. Return accuracy, sensitivity, specificity, precision, F-measure, and Matthews 
%    correlation coefficient.
% End
%% ====================================================================================
if iscell(label)
    % Check if the labels are cell arrays
    aa = strcmp(label_test, label);
    aa = aa(aa~=0);
    acc = (length(aa) / length(label)) * 100; % Accuracy
else
    aa = (label - label_test);
    aa = aa(aa == 0);
    acc = (length(aa) / length(label)) * 100; % Accuracy
end
cmax = confusionmat(label_test, label); % Compute confusion matrix
sen = []; spe = []; pre = []; fm = []; mcc = []; % Initialize metrics
if length(cmax) == 2
    % Binary classification
    Tp = cmax(1, 1); Tn = cmax(2, 2); Fn = cmax(2, 1); Fp = cmax(1, 2);
    sen = (Tp / (Tp + Fn)) * 100; % Sensitivity
    spe = (Tn / (Tn + Fp)) * 100; % Specificity
    pre = (Tp / (Tp + Fp)) * 100; % Precision
    fm = (2 * Tp / (2 * Tp + Fp + Fn)) * 100; % F-measure
    mcc = ((Tp * Tn - Fp * Fn) / (sqrt((Tp + Fp) * (Tp + Fn) * (Tn + Fp) * (Tn +...
        Fn)))) * 100; % Matthews correlation coefficient
else
    % Multiclass classification
    for i = 1:length(cmax)
        sen = [sen, (cmax(i, i) / sum(cmax(i, :), 2)) * 100]; %#ok Sensitivity
    end
    for i = 1:length(cmax)
        ss = sum(cmax(:)) - sum(cmax(i, :), 2) - sum(cmax(:,i), 1) + cmax(i, i);
        yy = sum(cmax(:)) - sum(cmax(i, :), 2);
        spe = [spe, (ss / yy) * 100]; %#ok Specificity
    end
    for i = 1:length(cmax)
        pre = [pre, (cmax(i, i) / sum(cmax(:, i), 1)) * 100]; %#ok Precision
    end
    for i = 1:length(cmax)
        fm = [fm, (2 * cmax(i, i) / (sum(cmax(:, i), 1) + sum(cmax(i, :), 2))) *...
            100]; %#ok F-measure
    end
    for i = 1:length(cmax)
        TN = sum(cmax(:)) - sum(cmax(i, :), 2) - sum(cmax(:, i), 1) + cmax(i, i);
        FP = sum(cmax(:, i), 1) - cmax(i, i);
        FN = sum(cmax(i, :), 2) - cmax(i, i);
        num = cmax(i, i) * TN - (FP * FN);
        dem = (cmax(i, i) + FP) * (cmax(i, i) + FN) * (TN + FP) * (TN + FN);
        mcc = [mcc, (num / sqrt(dem)) * 100]; %#ok Matthews correlation coefficient
    end
    sen = sum(sen, 2) / length(cmax);
    spe = sum(spe, 2) / length(cmax);
    pre = sum(pre, 2) / length(cmax);
    fm = sum(fm, 2) / length(cmax);
    mcc = sum(mcc, 2) / length(cmax);
end
end