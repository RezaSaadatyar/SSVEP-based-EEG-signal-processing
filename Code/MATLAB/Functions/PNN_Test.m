function Predict_Labels = PNN_Test(Train_Features,Test_Features,Train_Labels,wkk,Sigma_PNN,Type)
 okk = zeros(size(Train_Features,2),size(Test_Features,2));
    for jj=1:size(Test_Features,2)
        xn = (Test_Features(:,jj)-mean(Train_Features,2))./std(Train_Features,0,2);
        if strcmp(Type,'Euclidean');zkk = wkk'*xn;okk(:,jj) = exp((zkk-1)/Sigma_PNN);else
            r = sqrt(sum((repmat(xn,1,size(wkk,2))-wkk).^2));
            okk(:,jj) = (1/sqrt(2*pi*Sigma_PNN))*exp(-(r)/(2*Sigma_PNN));
        end
    end
    S = zeros(numel(unique(Train_Labels)),size(Test_Features,2));L = unique(Train_Labels);
    for ii=1:numel(unique(Train_Labels));index{ii}=find(Train_Labels==L(ii));end
    for j=1:numel(unique(Train_Labels));S(j,:)=sum(okk(index{j},:));end;[~,Predict_Labels]= max(S);
end