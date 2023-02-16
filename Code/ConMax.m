function [Acc,Sen,Spe,Pre,Fm,MCC]=ConMax(labelTargetTest,label)
if iscell(label)
    aa=strcmp(labelTargetTest,label);aa=aa(aa~=0); Acc=(length(aa)/length(label))*100;
else
    aa=(label-labelTargetTest);aa=aa(aa==0); Acc=(length(aa)/length(label))*100;
end
CMax=confusionmat(labelTargetTest,label);Sen=[];Spe=[];Pre=[];Fm=[];MCC=[];
if length(CMax)==2
    Tp=CMax(1,1);Tn=CMax(2,2);Fn=CMax(2,1);Fp=CMax(1,2);
    Sen=(Tp/(Tp+Fn))*100;Spe=(Tn/(Tn+Fp)*100);Pre=(Tp/(Tp+Fp))*100;
    Fm=(2*Tp/(2*Tp+Fp+Fn))*100;MCC=((Tp*Tn-Fp*Fn)/(sqrt((Tp+Fp)*(Tp+Fn)*...
        (Tn+Fp)*(Tn+Fn))))*100;
else
    for i=1:length(CMax);Sen=[Sen,(CMax(i,i)/sum(CMax(i,:),2))*100];end;%#ok
    for i=1:length(CMax)
        ss=sum(CMax(:))-sum(CMax(i,:),2)-sum(CMax(:,i),1)+CMax(i,i);
        yy= sum(CMax(:))-sum(CMax(i,:),2);Spe=[Spe,(ss/yy)*100];%#ok
    end
    for i=1:length(CMax);Pre=[Pre,(CMax(i,i)/sum(CMax(:,i),1))*100];end%#ok
    for i=1:length(CMax);Fm=[Fm,(2*CMax(i,i)/(sum(CMax(:,i),1)+sum(CMax(i,:),2)))*100];end%#ok
    for i=1:length(CMax)
        TN=sum(CMax(:))-sum(CMax(i,:),2)-sum(CMax(:,i),1)+CMax(i,i);
        FP=sum(CMax(:,i),1)-CMax(i,i);FN=sum(CMax(i,:),2)-CMax(i,i);
        num=CMax(i,i)*TN-(FP*FN);dem=(CMax(i,i)+FP)*(CMax(i,i)+FN)*(TN+FP)*(TN+FN);
        MCC=[MCC,(num/sqrt(dem))*100];%#ok
    end
    Sen=sum(Sen,2)/length(CMax);Spe=sum(Spe,2)/length(CMax);Pre=sum(Pre,2)/length(CMax);
    Fm=sum(Fm,2)/length(CMax);MCC=sum(MCC,2)/length(CMax);
end
% p=subplot(1,1,1,'Parent',ax);
% ax1=plotroc(labelTargetTest,label);

% [tpr,fpr,thresholds] = roc(labelTargetTest,label);
% labels = cell(1,length(CMax));
% for i=1:length(CMax),labels{i}=['Class ' num2str(i)]; end
% figure;
%
% plot(fpr,tpr)
% legend (labels)
%
end