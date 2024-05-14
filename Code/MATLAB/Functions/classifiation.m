function classifiation(features, labels, k_fold, num_neigh_knn, kernel_svm, ...
    distr_bayesian, discrim_type_lda, num_neurons_elm, num_center_rbf, sigma_pnn, ...
    type_pnn)
% ================================== (2023-2024) ======================================
% ======================== Presented by: Reza Saadatyar ===============================
% ====================== E-mail: Reza.Saadatyar@outlook.com ===========================
% Example:
% k_fold = 5;
% num_neigh_knn = 3;
% kernel_svm = 'linear';
% distr_bayesian = 'normal';  % 'normal','kernel'
% % 'linear','quadratic','diaglinear','diagquadratic','pseudolinear','pseudoquadratic'
% discrimtype_lda = 'linear'; 
% num_neurons_elm = 12;
% Num_Neurons = 15;
% num_center_rbf = 20;
% sigma_pnn = 0.1;
% type_pnn = 'Euclidean';      % 'Euclidean';'Correlation'
% classifiation(features, labels, k_fold, num_neigh_knn, kernel_svm, distr_bayesian, ...
%               discrimtype_lda, num_neurons_elm, num_center_rbf, sigma_pnn, type_pnn)

% This function performs classification using various classifiers and evaluates them 
% using k-fold cross-validation.
% Inputs:
%   - features: Features matrix.
%   - labels: Label vector.
%   - k_fold: Number of folds for cross-validation.
%   - num_neigh_knn: Number of neighbors for k-NN classifier.
%   - kernel_svm: Kernel function for SVM.
%   - distr_bayesian: Distribution names for Naive Bayes.
%   - discrim_type_lda: Discriminant type for LDA.
%   - num_neurons_elm: Number of neurons for ELM.
%   - num_center_rbf: Number of centers for RBF.
%   - sigma_pnn: Standard deviation parameter for PNN.
%   - type_pnn: Type of distance metric for PNN.
%% ===================== Flowchart for the classifiation function =====================
% Start
% 1. Preprocess data:
%     a. If the number of rows in `labels` is less than the number of columns, transpose
%        `labels`.
%     b. If the number of columns in `labels` is greater than 1, convert `labels` to 
%        indices.
%     c. If the number of rows in `features` is less than the number of columns, 
%        transpose `features`.
% 2. Perform k-fold cross-validation:
%     a. Generate indices for k-fold cross-validation using `cvpartition` with `k_fold`.
%     b. Initialize arrays to store evaluation results for each classifier and fold.
% 3. For each fold:
%     a. Split the data into training and test sets based on the current fold indices.
%     b. Train and test each classifier:
%         i. K-Nearest Neighbors (KNN):
%             - Train KNN classifier using `fitcknn` with specified parameters.
%             - Predict labels for training and test data.
%             - Evaluate performance using the confusion_matrix function.
%             - Store evaluation results in `tr_knn` and `te_knn`.
%         ii. Support Vector Machine (SVM):
%             - Train SVM classifier using `fitcecoc` with specified parameters.
%             - Predict labels for training and test data.
%             - Evaluate performance using the confusion_matrix function.
%             - Store evaluation results in `tr_svm` and `te_svm`.
%         iii. Decision Tree (Tree):
%             - Train decision tree classifier using `fitctree`.
%             - Predict labels for training and test data.
%             - Evaluate performance using the confusion_matrix function.
%             - Store evaluation results in `tr_tr` and `te_tr`.
%         iv. Naive Bayes (NB):
%             - Train Naive Bayes classifier using `fitcnb` with specified parameters.
%             - Predict labels for training and test data.
%             - Evaluate performance using the confusion_matrix function.
%             - Store evaluation results in `tr_nb` and `te_nb`.
%         v. Linear Discriminant Analysis (LDA):
%             - Train LDA classifier using `fitcdiscr` with specified parameters.
%             - Predict labels for training and test data.
%             - Evaluate performance using the confusion_matrix function.
%             - Store evaluation results in `tr_lda` and `te_lda`.
%         vi. Radial Basis Function Network (RBF):
%             - Train RBF network using custom `rbf_train` function with specified 
%               parameters.
%             - Predict labels for training and test data using custom `rbf_test` 
%               function.
%             - Evaluate performance using the confusion_matrix function.
%             - Store evaluation results in `tr_rbf` and `te_rbf`.
%         vii. Principal Component Analysis (PCA):
%             - Train PCA model using custom `pca_train` function.
%             - Predict labels for training and test data using custom `pca_test` 
%               function.
%             - Evaluate performance using the confusion_matrix function.
%             - Store evaluation results in `tr_pca` and `te_pca`.
%         viii. Probabilistic Neural Network (PNN):
%             - Train PNN using custom `pnn_train` function with specified parameters.
%             - Predict labels for training and test data using custom `pnn_test` 
%               function.
%             - Evaluate performance using the confusion_matrix function.
%             - Store evaluation results in `tr_pnn` and `te_pnn`.
%         ix. Extreme Learning Machine (ELM):
%             - Normalize training and test features.
%             - Initialize weights for ELM.
%             - Compute hidden layer output for training and test data.
%             - Train and test ELM by calculating output labels and evaluating 
%               performance.
%             - Store evaluation results in `tr_elm` and `te_elm`.
% End
%% ====================================================================================
% Data preprocessing
if size(labels, 1) < size(labels, 2); labels = labels'; if size(labels, 2) > 1
        labels = vec2ind(labels'); end

if size(features, 1) < size(features, 2); features = features'; end

indx = cvpartition(labels, 'k', k_fold);      % k-fold cross validation
% Initialize arrays to store evaluation results
tr_knn = zeros(k_fold, 6); te_knn = tr_knn; 
tr_svm = tr_knn; te_svm = tr_knn;
tr_tr = tr_knn; te_tr = tr_knn;
tr_nb = tr_knn; te_nb = tr_knn;
tr_lda = tr_knn; te_lda = tr_knn;
tr_elm = tr_knn; te_elm = tr_knn;
tr_rbf = tr_knn; te_rbf = tr_knn;
tr_pca = tr_knn; te_pca = tr_knn;
tr_pnn = tr_knn; te_pnn = tr_knn;

% Perform k-fold cross-validation
for i = 1:k_fold
    train_ind = indx.training(i); test_ind = indx.test(i);
    train_features = features(train_ind, :); train_labels = labels(train_ind, :);
    test_features = features(test_ind, :); test_labels = labels(test_ind, :);
    % ------------------------------------ KNN ----------------------------------------
    mdl = fitcknn(train_features, train_labels, 'NumNeighbors', num_neigh_knn);
    predict_labels = predict(mdl, train_features);
    [acc, sen, spe, pre, fm, mcc] = confusion_matrix(train_labels, predict_labels);
    tr_knn(i, :) = [acc, sen, spe, pre, fm, mcc];
    predict_labels = predict(mdl, test_features);
    [acc, sen, spe, pre, fm, mcc] = confusion_matrix(test_labels, predict_labels);
    te_knn(i, :) = [acc, sen, spe, pre, fm, mcc];
    % ---------------------------------- SVM ------------------------------------------
    SVM = templateSVM('Standardize', 1, 'KernelFunction', kernel_svm);
    mdl = fitcecoc(train_features, train_labels, 'Learners', SVM, 'FitPosterior', 1,...
        'ClassNames', unique(labels), 'Verbose', 0);
    predict_labels = predict(mdl, train_features);
    [acc, sen, spe, pre, fm, mcc] = confusion_matrix(train_labels, predict_labels);
    tr_svm(i, :) = [acc, sen, spe, pre, fm, mcc];
    predict_labels = predict(mdl, test_features);
    [acc, sen, spe, pre, fm, mcc] = confusion_matrix(test_labels, predict_labels);
    te_svm(i, :) = [acc, sen, spe, pre, fm, mcc];
    % ------------------------------------ Tree ---------------------------------------
    mdl = fitctree(train_features, train_labels);
    predict_labels = predict(mdl, train_features);
    [acc, sen, spe, pre, fm, mcc] = confusion_matrix(train_labels, predict_labels);
    tr_tr(i, :) = [acc, sen, spe, pre, fm, mcc];
    predict_labels = predict(mdl, test_features);
    [acc, sen, spe, pre, fm, mcc] = confusion_matrix(test_labels, predict_labels);
    te_tr(i, :) = [acc, sen, spe, pre, fm, mcc];
    % ----------------------------------- Naive Bayesian ------------------------------
    mdl = fitcnb(train_features, train_labels, 'DistributionNames', distr_bayesian, ...
        'ClassNames', unique(labels));
    predict_labels = predict(mdl, train_features);
    [acc, sen, spe, pre, fm, mcc] = confusion_matrix(train_labels, predict_labels);
    tr_nb(i, :) = [acc, sen, spe, pre, fm, mcc];
    predict_labels = predict(mdl, test_features);
    [acc, sen, spe, pre, fm, mcc] = confusion_matrix(test_labels, predict_labels);
    te_nb(i, :) = [acc, sen, spe, pre, fm, mcc];
    % ----------------------------------- LDA -----------------------------------------
    mdl = fitcdiscr(train_features, train_labels, 'DiscrimType', discrim_type_lda);
    predict_labels = predict(mdl, train_features);
    [acc, sen, spe, pre, fm, mcc] = confusion_matrix(train_labels, predict_labels);
    tr_lda(i, :) = [acc, sen, spe, pre, fm, mcc];
    predict_labels = predict(mdl, test_features);
    [acc, sen, spe, pre, fm, mcc] = confusion_matrix(test_labels, predict_labels);
    te_lda(i, :) = [acc, sen, spe, pre, fm, mcc];
    % ------------------------------------- RBF ---------------------------------------
    [weigth, sigma, centers] = rbf_train(train_features', train_labels, num_center_rbf);
    predict_labels = rbf_test(train_features', train_labels, weigth, sigma, centers,...
        num_center_rbf);
    [acc, sen, spe, pre, fm, mcc] = confusion_matrix(train_labels, predict_labels);
    tr_rbf(i, :) = [acc, sen, spe, pre, fm, mcc];
    predict_labels = rbf_test(test_features', test_labels, weigth, sigma, centers,...
        num_center_rbf);
    [acc, sen, spe, pre, fm, mcc] = confusion_matrix(test_labels, predict_labels);
    te_rbf(i, :) = [acc, sen, spe, pre, fm, mcc];
    % ----------------------------------- PCA -----------------------------------------
    % Train PCA
    mdl = pca_train(train_features', train_labels', size(train_features, 2));
    predict_labels = pca_test(mdl, train_features');
    [acc, sen, spe, pre, fm, mcc] = confusion_matrix(train_labels', predict_labels);
    tr_pca(i, :) = [acc, sen, spe, pre, fm, mcc];
    predict_labels = pca_test(mdl, test_features');     % Test PCA
    [acc, sen, spe, pre, fm, mcc] = confusion_matrix(test_labels', predict_labels);
    te_pca(i, :) = [acc, sen, spe, pre, fm, mcc];
    % ------------------------------------- PNN ---------------------------------------
    [predict_labels, wkk] = pnn_train(train_features', train_labels', sigma_pnn, type_pnn);
    [acc, sen, spe, pre, fm, mcc] = confusion_matrix(train_labels', predict_labels);
    tr_pnn(i, :) = [acc sen spe pre fm mcc];

    predict_labels = pnn_test(train_features', test_features', train_labels, wkk, ...
                              sigma_pnn, type_pnn);
    [acc, sen, spe, pre, fm, mcc] = confusion_matrix(test_labels', predict_labels);
    te_pnn(i, :)=[acc sen spe pre fm mcc];
    % ------------------------------------ ELM ----------------------------------------
    train_features = [-ones(1, size(train_features', 2)); train_features'];
    test_features = [-ones(1, size(test_features', 2)); test_features'];
    w = randn(num_neurons_elm, size(train_features, 1)) * 0.01;
    h = [-ones(1, size(w * train_features, 2)); tanh(w * train_features)]; 
    hsinv = (h * h' + 2 * eps) \ (h );
    beta = (hsinv * (full(ind2vec(train_labels')))')';
    predict_labels = vec2ind(1./ (1 + exp(-2 * beta * h)));   % Train
    [acc, sen, spe, pre, fm, mcc] = confusion_matrix(train_labels, predict_labels');
    tr_elm(i, :) = [acc, sen, spe, pre, fm, mcc];

    h = [-ones(1, size(w * test_features, 2)); tanh(w * test_features)];  % Test
    predict_labels = vec2ind(1./ (1 + exp(-2 * beta * h)));
    [acc, sen, spe, pre, fm, mcc] = confusion_matrix(test_labels, predict_labels');
    te_elm(i, :) = [acc, sen, spe, pre, fm, mcc];
end
figure();
subplot(211)
Mean = [mean(tr_knn); mean(tr_svm); mean(tr_tr); mean(tr_nb); mean(tr_lda); ...
        mean(tr_rbf); mean(tr_pca); mean(tr_pnn); mean(tr_elm)];
Std = [std(tr_knn); std(tr_svm); std(tr_tr); std(tr_nb); std(tr_lda); ...
       std(tr_rbf); std(tr_pca); std(tr_pnn); std(tr_elm)];
b = bar(Mean, 'BarWidth', 1); 
b(1).FaceColor = 'r'; b(2).FaceColor = 'g'; b(3).FaceColor = 'b'; b(4).FaceColor = 'c';
b(5).FaceColor = 'm'; b(6).FaceColor = 'y';
ylim([0 105]); ylabel('%'); hold on; ax = gca; ax.YGrid = 'on'; ax.XTickLabel = {};
x = zeros(size(Mean, 2), size(Mean, 1));
for i = 1:size(Mean, 2)
    x(i, :) = b(i).XEndPoints;
end
errorbar(x', Mean, Std, '.k', 'LineWidth', 1.2);
lgd = legend({'Accuracy', 'Sensitivity', 'Specificity', 'Precision', 'F-measure', 'MCC'}, ...
             'Location', 'southeast', 'NumColumns', 2);
title(lgd, 'Training')

subplot(212)
Mean = [mean(te_knn); mean(te_svm); mean(te_tr); mean(te_nb); mean(te_lda); ...
        mean(te_rbf); mean(te_pca); mean(te_pnn); mean(te_elm)];
Std = [std(te_knn); std(te_svm); std(te_tr); std(te_nb); std(te_lda); ...
       std(te_rbf); std(te_pca); std(te_pnn); std(te_elm)];
b = bar(Mean, 'BarWidth', 1); 
b(1).FaceColor = 'r'; b(2).FaceColor = 'g'; b(3).FaceColor = 'b'; b(4).FaceColor = 'c'; 
b(5).FaceColor = 'm'; b(6).FaceColor = 'y';
ylim([0 105]); ylabel('%'); hold on; ax = gca; ax.YGrid = 'on';
x = zeros(size(Mean, 2), size(Mean, 1));
for i = 1:size(Mean, 2)
    x(i, :) = b(i).XEndPoints;
end
errorbar(x', Mean, Std, '.k', 'LineWidth', 1.2);
lgd = legend({'Accuracy', 'Sensitivity', 'Specificity', 'Precision', 'F-measure', 'MCC'}, ...
             'Location', 'southeast', 'NumColumns', 2);
title(lgd, 'Test')
ax.XTickLabel = {'KNN', 'SVM', 'DT', 'Bayesian', 'LDA', 'RBF', 'PCA', 'PNN', 'ELM'};

end