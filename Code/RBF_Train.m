function [Weigth, Sigma, Centers] = RBF_Train(Train_Features,Train_Labels,Num_Center_RBF)
Train_Labels = full(ind2vec(Train_Labels'));
[~,Centers] = kmeans(Train_Features',Num_Center_RBF); Centers = Centers';
Distance = zeros(Num_Center_RBF);
for ii=1:Num_Center_RBF;for j=1:Num_Center_RBF;Distance(ii,j) = sqrt(sum((Centers(:,ii)-Centers(:,j)).^2));end;end
Sigma = max(Distance(:))/sqrt(2*Num_Center_RBF);Wh = zeros(Num_Center_RBF+1,size(Train_Features,2));
for ii=1:size(Train_Features,2);Phi = zeros(1,Num_Center_RBF);
    for j= 1:Num_Center_RBF;Phi(j) = exp(-(sqrt(sum((Train_Features(:,ii)-Centers(:,j)).^2)))/(2*Sigma));end
    Wh(:,ii) = [-1,Phi];
end
Weigth=((Wh*Wh')\(Wh*Train_Labels'))';
end