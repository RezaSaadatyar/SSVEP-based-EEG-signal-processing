function y = elm(train_features, test_features, train_labels, test_labels, num_neurons)
% ================================== (2023-2024) ======================================
% ======================== Presented by: Reza Saadatyar ===============================
% ====================== E-mail: Reza.Saadatyar@outlook.com ===========================

% Parameters:
% - train_features: Training data features.
% - test_features: Test data features.
% - train_labels: Labels of the training data.
% - test_labels: Labels of the test data.
% - num_neurons: Number of neurons in the hidden layer.
%% ========================= Flowchart for the elm function ===========================
% Start
% 1. Convert `train_labels` and `test_labels` to one-hot encoding.
% 2. Initialize weights between input and hidden layers (`w`) with random values sampled
%    from a normal distribution with mean 0 and standard deviation 0.01.
% 3. Compute the hidden layer output (`h`) by applying the hyperbolic tangent activation
%    function to the product of weights `w` and training features. Add a row of -1s to 
%    account for the bias term.
% 4. Compute the weights between hidden and output layers (`beta`) using the 
%    Moore-Penrose pseudoinverse.
% 5. Compute the hidden layer output for the test data (`h`) in a similar manner as step 3.
% 6. Calculate the predicted labels (`y`) by multiplying `beta` and `h`, and applying 
%    the sign function to obtain binary predictions.
% 7. Transform the binary predictions (`y`) to probabilities (`y1`) using the logistic 
%    sigmoid function.
% 8. Calculate the accuracy of the predictions by comparing the predicted labels (`y1`)
%    to the true labels (`test_labels`). Convert the predictions and true labels to 
%    indices and compare them. Divide the number of correct predictions by the total 
%    number of predictions and multiply by 100 to get the accuracy percentage.
% End
%% ====================================================================================
train_labels = full(ind2vec(train_labels));
test_labels = full(ind2vec(test_labels));

% Weights between input and hidden layers
w = randn(num_neurons, size(train_features, 1)) * 0.01;      

h = [-ones(1, size(tanh(w * train_features), 2)); tanh(w * train_features)];

% Weights between hidden and output layers
beta = (((h * h') \ h) * train_labels')';                     
% test Trained ELM
h = [-ones(1, size(tanh(w * test_features), 2)); tanh(w * test_features)]; 

y = sign(beta * h);
y1 = (1 ./ (1 + exp(-2 * y)));

accuracy = sum(vec2ind(y1) == vec2ind(test_labels)) / length(test_labels) * 100;

end