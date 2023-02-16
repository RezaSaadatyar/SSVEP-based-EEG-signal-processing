function Output=Feature_Selection(Input,Labels,NumFeatures)
if size(Labels,1)<size(Labels,2);Labels=Labels';if size(Labels,2)>1; Labels=vec2ind(Labels');end
 elseif size(Input,1)<size(Input,2);Input=Input';end
if NumFeatures>size(Input,2);NumFeatures=size(Input,2);end

Pvalue=zeros(size(Input,2),1);

for i=1:size(Input,2)
    Pvalue(i)= anova1(Input(:,i),Labels,'off');
end
[Pvalue,Ind]= sort(Pvalue,'ascend');
figure()
plot(Pvalue,'--o','linewidth',1.5,'Color','b',MarkerSize=4)
ylabel('p-value');xlabel('Features')

Output= Input(:,Ind(1:NumFeatures));
end