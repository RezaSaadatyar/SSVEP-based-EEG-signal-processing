function Predict_Labels = RBF_Predict(Input,Labels,Weigth,Sigma,Centers,Num_Center_RBF)

Predict_Labels = zeros(size(full(ind2vec(Labels')),1),size(Input,2));
for ii=1:size(Input,2);Phi = zeros(1,Num_Center_RBF);
    for j=1:Num_Center_RBF; Phi(j) = exp(-(sqrt(sum((Input(:,ii)-Centers(:,j)).^2)))/(2*Sigma));end
    Predict_Labels(:,ii) = (Weigth*[-1,Phi]');
end
Predict_Labels = (vec2ind(Predict_Labels))';
end