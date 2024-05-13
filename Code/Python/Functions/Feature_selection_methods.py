import numpy as np
from scipy.stats import f_oneway
from sklearn import feature_selection, preprocessing, linear_model, ensemble, svm

# ============================================= Feature selection ============================================
def feature_selecion_methods(data, labels, num_features, threshold_var=0.1, n_neighbors_MI=2, L1_Parameter= 0.2, 
                     type_feature_selection="var"): 
    
    # --------------------------- Convert data to ndarray if it's not already --------------------------------
    data = np.array(data) if not isinstance(data, np.ndarray) else data
    # -------- Transpose the data if it has more than one dimension and has fewer rows than columns ----------
    data = data.T if data.ndim > 1 and data.shape[0] < data.shape[-1] else data
    #  ------------------- Set num_features to total number of features if it exceeds ------------------------
    num_features = data.shape[1] if num_features > data.shape[1] else num_features
    # -------------------------------------- Filter Methods --------------------------------------------------
    if type_feature_selection.lower() == "var":             # Variance
      mod = feature_selection.VarianceThreshold()
      mod.fit(data)
      features = mod.transform(data)
    elif type_feature_selection.lower() == "anova":
      features = anova_feature_selection(data, labels, num_features)
    elif type_feature_selection.lower() == "mi":                 # Mutual information
      mod = feature_selection.mutual_info_classif(data, labels, n_neighbors=n_neighbors_MI)
      features = data[:, np.argsort(mod)[-num_features:]]
    elif type_feature_selection.lower() == "ufs":                # Univariate feature selection
      scaler = preprocessing.MinMaxScaler()             # Perform Min-Max scaling
      data = scaler.fit_transform(data)
      mod = feature_selection.SelectKBest(feature_selection.chi2, k=num_features)
      features = mod.fit_transform(data, labels)
   # elif type_feature_selection == 'FS':               # Fisher_score
   #    mod = fisher_score.fisher_score(data, labels)
   #    data = data[:, mod[-number_feature:]]
   # ----------------------------------- Wrapper Methods --------------------------------------------------------------
    elif type_feature_selection.lower() ==  "rfe":                # Recursive feature elimination
      mod = feature_selection.RFE(estimator=linear_model.LogisticRegression(max_iter=1000), n_features_to_select=num_features)
      mod.fit(data, labels)
      features = mod.transform(data)
   # elif type_feature_selection == 'FFS':              # Forward feature selection
   #    mod = linear_model.LogisticRegression(max_iter=1000)
   #    mod = SequentialFeatureSelector(mod, k_features=number_feature, forward=True, cv=5, scoring='accuracy')
   #    mod.fit(data, labels)
   #    data = data[:, mod.k_feature_idx_]              # Optimal number of feature
   # elif type_feature_selection == 'EFS':              # Exhaustive Feature Selection
   #         mod = ExhaustiveFeatureSelector(estimator=linear_model.LogisticRegression(max_iter=1000), min_features=1, max_features=number_feature, scoring='accuracy', cv=3)
   #         mod.fit(data, labels)
   #         data = data[:, mod.best_idx_]
   # elif type_feature_selection == 'FFS':              # Forward feature selection
   #    mod = linear_model.LogisticRegression(max_iter=1000)
   #    mod = SequentialFeatureSelector(mod, k_features=number_feature, forward=True, cv=5, scoring='accuracy')
   #    mod.fit(input_data, labels)
   #    data = input_data[:, mod.k_feature_idx_]        # Optimal number of feature
   # ----------------------------------- Embedded Methods --------------------------------------------------------------
    elif type_feature_selection.lower() == "rf":                 # Random forest
      mod = ensemble.RandomForestClassifier(n_estimators=10, random_state=0)
      mod.fit(data, labels)
      features = data[:, np.argsort(mod.feature_importances_)[-num_features:]]
    elif type_feature_selection.lower() ==  "l1fs":               # L1-based feature selection; The smaller C the fewer feature selected
      mod = svm.LinearSVC(C=L1_Parameter, penalty='l1', dual=False, max_iter=1000).fit(data, labels)
      mod = feature_selection.SelectFromModel(mod, prefit=True)
      features = mod.transform(data)
    elif type_feature_selection.lower() == "tfs":                # Tree-based feature selection
      mod = ensemble.ExtraTreesClassifier(n_estimators=100)
      mod.fit(data, labels)
      features = data[:, np.argsort(mod.feature_importances_)[-num_features:]]

    return features
  

def anova_feature_selection(data, labels, num_features):
    """
    Perform feature selection using ANOVA.

    Inputs:
    - data: Input data matrix.
    - labels: Class labels corresponding to the data.
    - num_features: Number of features to select.

    Output:
    - features: Selected features based on ANOVA.
    """

    pvalue = np.zeros(data.shape[1])

    # ------------------------- Compute p-values for each feature using ANOVA --------------------------------
    for i in range(data.shape[1]):
        pvalue[i] = f_oneway(data[:, i], labels)[1]
    # -------------------------- Sort p-values and get indices of sorted features ----------------------------
    ind = np.argsort(pvalue)
    # ----------------------------------- Select top num_features features -----------------------------------
    features = data[:, ind[:num_features]]

    return features
