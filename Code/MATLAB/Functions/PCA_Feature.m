function [W] = PCA_Feature(TrainInputs,nfeature)
% step1: normalization
mu_p= mean(TrainInputs,2);reptMu= repmat(mu_p,1,size(TrainInputs,2));Xn= TrainInputs- reptMu;
% step2: calculate covariance matrix
C= cov(Xn');
% step3: eigen value decomposition
[U,D]= eig(C);
% step4: sort eigen value and eigen vectors
D= diag(D);[~,ind]=sort(D,'descend');U= U(:,ind);
% step5: select m best eigen vectors
W= U(:,1:nfeature);
end