function labeltest = PCA_Test(mdl,datatest)
userlabel=mdl.userlabel;nfeature=mdl.nfeature;
Mu=mdl.Mu;C=numel(userlabel);W=mdl.W;dn=zeros(C,size(datatest,2));
for i=1:C
    Xn= datatest-repmat(Mu(:,i),1,size(datatest,2));
    if nfeature==1
        dn(i,:)=((W(:,:,i)'*Xn).^2);
    else
        dn(i,:)= sum((W(:,:,i)'*Xn).^2);
    end
end
[~,labeltest]= min(dn);
end