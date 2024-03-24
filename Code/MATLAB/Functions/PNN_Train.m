function [Predict_Labels, wkk] = PNN_Train(Train_Features,Train_Labels,Sigma_PNN,Type)

wkk = (Train_Features-repmat(mean(Train_Features,2),1,size(Train_Features,2)))./repmat(std(Train_Features,0,2),1,size(Train_Features,2));
okk=zeros(size(Train_Features,2));
for jj=1:size(Train_Features,2)                       % Train
    xn=(Train_Features(:,jj)-mean(Train_Features,2))./std(Train_Features,0,2);
    if strcmp(Type,'Euclidean');zkk=wkk'*xn;okk(:,jj)=exp((zkk-1)/Sigma_PNN);else
        r=sqrt(sum((repmat(xn,1,size(wkk,2))-wkk).^2));
        okk(:,jj) = (1/ sqrt(2*pi*Sigma_PNN))*exp(-(r)/(2*Sigma_PNN));
    end
end

L = unique(Train_Labels);class = numel(L);index = cell(1,class);S = zeros(class,size(Train_Features,2));
for ii=1:class;index{ii} = find(Train_Labels==L(ii));end

for j=1:class;S(j,:) = sum(okk(index{j},:));end;[~,Predict_Labels] = max(S);

end