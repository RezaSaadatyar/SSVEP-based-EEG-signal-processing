import numpy as np
from scipy.stats import f_oneway
from skfeature.function.similarity_based import fisher_score
from sklearn import feature_selection, preprocessing, linear_model, ensemble, svm

# ============================================= Feature selection ============================================
def feature_selecions(data, labels, num_features, threshold_var=0.1, n_neighbors_MI=2, L1_Parameter= 0.2,
                     type_feature_selection="var"):
  """
  ================================ Presented by: Reza Saadatyar (2023-2024) ==================================
  ================================= E-mail: Reza.Saadatyar@outlook.com =======================================
  This function performs feature selection based on different methods.
  Inputs:
  - data: The feature matrix.
  - labels: The labels corresponding to each sample.
  - num_features: The desired number of features to select.
  - threshold_var: The variance threshold for variance-based feature selection.
  - n_neighbors_MI: The number of neighbors for mutual information-based feature selection.
  - L1_Parameter: The parameter for L1-based feature selection.
  - type_feature_selection: The type of feature selection method to use:
      - "var": Variance thresholding.
      - "anova": Analysis of Variance (ANOVA).
      - "mi": Mutual information.
      - "ufs": Univariate feature selection.
      - "fs": Fisher score.
      - "rfe": Recursive feature elimination.
      - "ffs": Forward feature selection.
      - "bfs": Backward feature selection.
      - "rf": Random forest feature selection.
      - "l1fs": L1-based feature selection.
      - "tfs": Tree-based feature selection.
      
  Outputs:
  - features: The selected features.
  ============================== Flowchart for the Feature selection function ================================
  1. Start
  2. Convert the input data to a NumPy array if it's not already.
  3. Transpose the data if it has more than one dimension and fewer rows than columns.
  4. Set the number of features to the total number of features if it exceeds.
  5. Implement feature selection based on the specified method:
    a. Filter Methods:
        i. Variance thresholding: Filter features based on variance.
        ii. ANOVA: Compute p-values for each feature using ANOVA and select top features.
        iii. Mutual Information: Select features based on mutual information with class labels.
        iv. Univariate Feature Selection: Select top k features using chi-squared test.
        v. Fisher Score: Select top features based on Fisher score.
    b. Wrapper Methods:
        i. Recursive Feature Elimination (RFE): Select features recursively using logistic regression.
        ii. Forward Feature Selection (FFS): Select features forwardly based on logistic regression.
        iii. Backward Feature Selection (BFS): Select features backwardly based on logistic regression.
        iv. Random Forest: Select top features based on random forest feature importances.
        v. L1-based Feature Selection: Select features based on linear SVM with L1 regularization.
        vi. Tree-based Feature Selection: Select top features based on extra trees classifier.
  6. Return the selected features.
  7. End.
  ============================================================================================================
  """
  # ---------------------------- Convert data to ndarray if it's not already ---------------------------------
  data = np.array(data) if not isinstance(data, np.ndarray) else data
  # -------- Transpose the data if it has more than one dimension and has fewer rows than columns ----------
  data = data.T if data.ndim > 1 and data.shape[0] < data.shape[-1] else data
  #  ------------------- Set num_features to total number of features if it exceeds ------------------------
  num_features = data.shape[1] if num_features > data.shape[1] else num_features
  # -------------------------------------- Filter Methods --------------------------------------------------
  if type_feature_selection.lower() == "var":             # Variance
    mod = feature_selection.VarianceThreshold(threshold=threshold_var)
    mod.fit(data)
    features = mod.transform(data)
  elif type_feature_selection.lower() == "anova":
    pvalue = np.zeros(data.shape[1])
    for i in range(data.shape[1]):                        # Compute p-values for each feature using ANOVA
        pvalue[i] = f_oneway(data[:, i], labels)[1]
    ind = np.argsort(pvalue)                              # Sort p-values and get indices of sorted features 
    features = data[:, ind[:num_features]]                # Select top num_features features
  elif type_feature_selection.lower() == "mi":            # Mutual information
    mod = feature_selection.mutual_info_classif(data, labels, n_neighbors=n_neighbors_MI)
    features = data[:, np.argsort(mod)[-num_features:]]
  elif type_feature_selection.lower() == "ufs":           # Univariate feature selection
    scaler = preprocessing.MinMaxScaler()                 # Perform Min-Max scaling
    data = scaler.fit_transform(data)
    mod = feature_selection.SelectKBest(feature_selection.chi2, k=num_features)
    features = mod.fit_transform(data, labels)
  elif type_feature_selection.lower() == 'fs':            # Fisher_score
      mod = fisher_score.fisher_score(data, labels)
      features = data[:, mod[-num_features:]]
  # --------------------------------------- Wrapper Methods -------------------------------------------------
  elif type_feature_selection.lower() ==  "rfe":          # Recursive feature elimination
    mod = feature_selection.RFE(estimator=linear_model.LogisticRegression(max_iter=1000), n_features_to_select=
                                num_features)
    mod.fit(data, labels)
    features = mod.transform(data)
  elif type_feature_selection.lower() == 'ffs':           # Forward feature selection
      mod = linear_model.LogisticRegression(max_iter=1000)
      mod = feature_selection.SequentialFeatureSelector(mod, n_features_to_select=num_features, direction=
                                                        "forward", cv=5, scoring='accuracy')
      mod.fit(data, labels)
      features = data[:, mod.support_]                    # Optimal number of feature
  elif type_feature_selection.lower() == 'bfs':           # Backward feature selection
      mod = linear_model.LogisticRegression(max_iter=1000)
      mod = feature_selection.SequentialFeatureSelector(mod, n_features_to_select=num_features, direction=
                                                        "backward", cv=5, scoring='accuracy')
      mod.fit(data, labels)
      features = data[:, mod.support_]                    # Optimal number of feature
  elif type_feature_selection.lower() == "rf":            # Random forest
    mod = ensemble.RandomForestClassifier(n_estimators=10, random_state=0)
    mod.fit(data, labels)
    features = data[:, np.argsort(mod.feature_importances_)[-num_features:]]
  elif type_feature_selection.lower() ==  "l1fs":         # L1-based feature selection;The smaller C the fewer feature selected
    mod = svm.LinearSVC(C=L1_Parameter, penalty='l1', dual=False, max_iter=1000).fit(data, labels)
    mod = feature_selection.SelectFromModel(mod, prefit=True)
    features = mod.transform(data)
  elif type_feature_selection.lower() == "tfs":           # Tree-based feature selection
    mod = ensemble.ExtraTreesClassifier(n_estimators=100)
    mod.fit(data, labels)
    features = data[:, np.argsort(mod.feature_importances_)[-num_features:]]

  return features