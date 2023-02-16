function Classifiation(Features,Labels,K_Fold,NumNeigh_KNN,Kernel_SVM,Distr_Bayesian,...
    DiscrimType_LDA,NumNeurons_ELM,NumCenter_RBF,Sigma_PNN,Type_PNN)
if size(Labels,1)<size(Labels,2);Labels=Labels';if size(Labels,2)>1; Labels=vec2ind(Labels');end
 elseif size(Features,1)<size(Features,2);Features=Features';end


Indx = cvpartition(Labels,'k',K_Fold);               % k-fold cross validation
Tr_Perf_KNN = zeros(K_Fold,6);Te_Perf_KNN = Tr_Perf_KNN;
Tr_Perf_SVM = Tr_Perf_KNN;Te_Perf_SVM = Tr_Perf_KNN;
Tr_Perf_Tr = Tr_Perf_KNN;Te_Perf_Tr = Tr_Perf_KNN;
Tr_Perf_NB = Tr_Perf_KNN;Te_Perf_NB = Tr_Perf_KNN;
Tr_Perf_LDA = Tr_Perf_KNN;Te_Perf_LDA = Tr_Perf_KNN;
Tr_Perf_ELM = Tr_Perf_KNN;Te_Perf_ELM = Tr_Perf_KNN;
Tr_Perf_RBF = Tr_Perf_KNN;Te_Perf_RBF = Tr_Perf_KNN;
Tr_Perf_PCA = Tr_Perf_KNN;Te_Perf_PCA = Tr_Perf_KNN;
Tr_Perf_PNN = Tr_Perf_KNN;Te_Perf_PNN = Tr_Perf_KNN;
for i = 1:K_Fold
    Train_Indx = Indx.training(i);Test_Indx = Indx.test(i);
    Train_Features = Features(Train_Indx,:);Train_Labels = Labels(Train_Indx,:);
    Test_Features = Features(Test_Indx,:);Test_Labels = Labels(Test_Indx,:);
    % ------------------------------ KNN -----------------------------------
    mdl = fitcknn(Train_Features,Train_Labels,'NumNeighbors',NumNeigh_KNN);
    Predict_Labels = predict(mdl,Train_Features);
    [Acc,Sen,Spe,Pre,Fm,MCC] = ConMax(Train_Labels,Predict_Labels);
    Tr_Perf_KNN(i,:) = [Acc,Sen,Spe,Pre,Fm,MCC];
    Predict_Labels = predict(mdl,Test_Features);
    [Acc,Sen,Spe,Pre,Fm,MCC] = ConMax(Test_Labels,Predict_Labels);
    Te_Perf_KNN(i,:) = [Acc,Sen,Spe,Pre,Fm,MCC];
    % ------------------------------ SVM ----------------------------------
    SVM = templateSVM('Standardize',1,'KernelFunction',Kernel_SVM);
    mdl = fitcecoc(Train_Features,Train_Labels,'Learners',SVM,'FitPosterior',1,...
        'ClassNames',unique(Labels),'Verbose',2);
    Predict_Labels = predict(mdl,Train_Features);
    [Acc,Sen,Spe,Pre,Fm,MCC] = ConMax(Train_Labels,Predict_Labels);
    Tr_Perf_SVM(i,:) = [Acc,Sen,Spe,Pre,Fm,MCC];
    Predict_Labels = predict(mdl,Test_Features);
    [Acc,Sen,Spe,Pre,Fm,MCC] = ConMax(Test_Labels,Predict_Labels);
    Te_Perf_SVM(i,:) = [Acc,Sen,Spe,Pre,Fm,MCC];
    % ------------------------------- Tree --------------------------------
    mdl = fitctree(Train_Features,Train_Labels);
    Predict_Labels = predict(mdl,Train_Features);
    [Acc,Sen,Spe,Pre,Fm,MCC] = ConMax(Train_Labels,Predict_Labels);
    Tr_Perf_Tr(i,:) = [Acc,Sen,Spe,Pre,Fm,MCC];
    Predict_Labels = predict(mdl,Test_Features);
    [Acc,Sen,Spe,Pre,Fm,MCC] = ConMax(Test_Labels,Predict_Labels);
    Te_Perf_Tr(i,:) = [Acc,Sen,Spe,Pre,Fm,MCC];
    % ------------------------------- Naive Bayesian ----------------------
    mdl=fitcnb(Train_Features,Train_Labels,'DistributionNames',Distr_Bayesian,'ClassNames',unique(Labels));
    Predict_Labels = predict(mdl,Train_Features);
    [Acc,Sen,Spe,Pre,Fm,MCC] = ConMax(Train_Labels,Predict_Labels);
    Tr_Perf_NB(i,:) = [Acc,Sen,Spe,Pre,Fm,MCC];
    Predict_Labels = predict(mdl,Test_Features);
    [Acc,Sen,Spe,Pre,Fm,MCC] = ConMax(Test_Labels,Predict_Labels);
    Te_Perf_NB(i,:) = [Acc,Sen,Spe,Pre,Fm,MCC] ;
    % -------------------------------- LDA --------------------------------
    mdl = fitcdiscr(Train_Features,Train_Labels,'DiscrimType',DiscrimType_LDA);
    Predict_Labels = predict(mdl,Train_Features);
    [Acc,Sen,Spe,Pre,Fm,MCC] = ConMax(Train_Labels,Predict_Labels);
    Tr_Perf_LDA(i,:) = [Acc,Sen,Spe,Pre,Fm,MCC];
    Predict_Labels = predict(mdl,Test_Features);
    [Acc,Sen,Spe,Pre,Fm,MCC] = ConMax(Test_Labels,Predict_Labels);
    Te_Perf_LDA(i,:) = [Acc,Sen,Spe,Pre,Fm,MCC];
    % -------------------------------- RBF --------------------------------
    [Weigth, Sigma, Centers] = RBF_Train(Train_Features',Train_Labels,NumCenter_RBF);
    Predict_Labels = RBF_Predict(Train_Features',Train_Labels,Weigth,Sigma,Centers,NumCenter_RBF);
    [Acc,Sen,Spe,Pre,Fm,MCC] = ConMax(Train_Labels,Predict_Labels);
    Tr_Perf_RBF(i,:) = [Acc,Sen,Spe,Pre,Fm,MCC];
    Predict_Labels = RBF_Predict(Test_Features',Test_Labels,Weigth,Sigma,Centers,NumCenter_RBF);
    [Acc,Sen,Spe,Pre,Fm,MCC] = ConMax(Test_Labels,Predict_Labels);
    Te_Perf_RBF(i,:) = [Acc,Sen,Spe,Pre,Fm,MCC];
    % -------------------------------- PCA --------------------------------
    mdl = PCA_Train(Train_Features',Train_Labels',size(Train_Features,2)); % Train PCA
    Predict_Labels = PCA_Test(mdl,Train_Features');
    [Acc,Sen,Spe,Pre,Fm,MCC] = ConMax(Train_Labels',Predict_Labels);
    Tr_Perf_PCA(i,:) = [Acc,Sen,Spe,Pre,Fm,MCC];
    Predict_Labels = PCA_Test(mdl,Test_Features');                         % Test PCA
    [Acc,Sen,Spe,Pre,Fm,MCC] = ConMax(Test_Labels',Predict_Labels);
    Te_Perf_PCA(i,:) = [Acc,Sen,Spe,Pre,Fm,MCC];
    % -------------------------------- PNN --------------------------------
    [Predict_Labels, wkk] = PNN_Train(Train_Features',Train_Labels',Sigma_PNN,Type_PNN);
    [AccT,Sen,Spe,Pre,Fm,MCC] = ConMax(Train_Labels',Predict_Labels);
    Tr_Perf_PNN(i,:) = [AccT Sen Spe Pre Fm MCC];

    Predict_Labels = PNN_Test(Train_Features',Test_Features',Train_Labels,wkk,Sigma_PNN,Type_PNN);

    [Acc, Sen, Spe, Pre, Fm, MCC]=ConMax(Test_Labels',Predict_Labels);
    Te_Perf_PNN(i,:)=[Acc Sen Spe Pre Fm MCC];
    % -------------------------------- ELM --------------------------------
    Train_Features = [-ones(1,size(Train_Features',2));Train_Features'];
    Test_Features = [-ones(1,size(Test_Features',2));Test_Features'];
    w = randn(NumNeurons_ELM,size(Train_Features,1))*0.01;
    H=[-ones(1,size(w*Train_Features,2));tanh(w*Train_Features)];Hsinv=(H*H'+0.0002)\(H);
    beta=(Hsinv*(full(ind2vec(Train_Labels')))')';

    Predict_Labels = vec2ind(1./(1+exp(-2*beta*H)));             % Train
    [Acc,Sen,Spe,Pre,Fm,MCC] = ConMax(Train_Labels,Predict_Labels');
    Tr_Perf_ELM(i,:) = [Acc,Sen,Spe,Pre,Fm,MCC];

    H=[-ones(1,size(w*Test_Features,2));tanh(w*Test_Features)];  % Test
    Predict_Labels=vec2ind(1./(1+exp(-2*beta*H)));
    [Acc,Sen,Spe,Pre,Fm,MCC] = ConMax(Test_Labels,Predict_Labels');
    Te_Perf_ELM(i,:) = [Acc,Sen,Spe,Pre,Fm,MCC];
end
figure();
subplot(211)
Mean=[mean(Tr_Perf_KNN);mean(Tr_Perf_SVM);mean(Tr_Perf_Tr);mean(Tr_Perf_NB);mean(Tr_Perf_LDA);...
    mean(Tr_Perf_RBF);mean(Tr_Perf_PCA);mean(Tr_Perf_PNN);mean(Tr_Perf_ELM)];
Std=[std(Tr_Perf_KNN);std(Tr_Perf_SVM);std(Tr_Perf_Tr);std(Tr_Perf_NB);std(Tr_Perf_LDA);...
   std(Tr_Perf_RBF);std(Tr_Perf_PCA);std(Tr_Perf_PNN);std(Tr_Perf_ELM)];
b=bar( Mean,'BarWidth',1); 
b(1).FaceColor='r';b(2).FaceColor='g';b(3).FaceColor='b';b(4).FaceColor='c';b(5).FaceColor='m';b(6).FaceColor='y';
ylim([0 105]);ylabel('%');hold on;ax=gca;ax.YGrid='on';ax.XTickLabel={};
x=zeros(size(Mean,2),size(Mean,1));
for i = 1:size(Mean,2); x(i,:) = b(i).XEndPoints;end
errorbar(x',Mean,Std,'.k','LineWidth',1.2);
lgd=legend({'Accuracy','Sensitivity','Specificity','Precision','F-measure','MCC'},'Location','southeast','NumColumns',2);
title(lgd,'Training')

subplot(212)
Mean=[mean(Te_Perf_KNN);mean(Te_Perf_SVM);mean(Te_Perf_Tr);mean(Te_Perf_NB);mean(Te_Perf_LDA);...
    mean(Te_Perf_RBF);mean(Te_Perf_PCA);mean(Te_Perf_PNN);mean(Te_Perf_ELM)];
Std=[std(Te_Perf_KNN);std(Te_Perf_SVM);std(Te_Perf_Tr);std(Te_Perf_NB);std(Te_Perf_LDA);...
   std(Te_Perf_RBF);std(Te_Perf_PCA);std(Te_Perf_PNN);std(Te_Perf_ELM)];
b=bar( Mean,'BarWidth',1); 
b(1).FaceColor='r';b(2).FaceColor='g';b(3).FaceColor='b';b(4).FaceColor='c';b(5).FaceColor='m';b(6).FaceColor='y';
ylim([0 105]);ylabel('%');hold on;ax=gca;ax.YGrid='on';
x=zeros(size(Mean,2),size(Mean,1));
for i = 1:size(Mean,2); x(i,:) = b(i).XEndPoints;end
errorbar(x',Mean,Std,'.k','LineWidth',1.2);
lgd=legend({'Accuracy','Sensitivity','Specificity','Precision','F-measure','MCC'},'Location','southeast','NumColumns',2);
title(lgd,'Test')
ax.XTickLabel={'KNN','SVM','DT','Bayesian','LDA','RBF','PCA','PNN','ELM'};
end