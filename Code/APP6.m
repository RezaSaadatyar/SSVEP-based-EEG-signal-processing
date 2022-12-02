clc;clear;close all
%%
Data=load('SSVEP.mat');
data= cat(3,Data.data_L1_13Hz,Data.data_L2_21Hz,Data.data_L3_17Hz);
label= [ones(1,size(Data.data_L1_13Hz,3)), 2*ones(1,size(Data.data_L2_21Hz,3)),3*ones(1,size(Data.data_L3_17Hz,3))];
fs=256;
%% PSDA
f_stim(1)= 13;
f_stim(2)= 21;
f_stim(3)= 17;
%% Applying filtering to first trial
wn= [49.2 50.6]/(fs/2);
[b,a]= butter(4,wn,"stop");
%%
chn= 1:8;
n=30;
ouput=zeros(1,size(data,3));
for i=1:size(data,3)
    X= data(:,:,i);
    X= filtfilt(b,a,X);
    Mean= mean(X,2);    % CAR filter
    for j=1:size(X,2)
        X(:,j)=X(:,j)-Mean;
    end
    Stotal=PSDA_2(X(:,chn),f_stim,n,fs);
    [~,ind]= max(Stotal);
    ouput(i)= ind;
end
Accuracy=sum((label==ouput))/size(ouput,2)*100;
disp(['Total accuracy: ', num2str(round(Accuracy,2)), ' %'])

