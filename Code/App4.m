clc;clear;close all
%% 
Data=load('SSVEP.mat');
X= Data.data_L1_13Hz;   % (number samples, number channel, number trials)
fs=256;
%% Applying filtering to all trials
wn= [49.2 50.6]/(fs/2);
[b,a]= butter(4,wn,"stop");

for i=1:size(X,3)
    X_Filter= filtfilt(b,a,X(:,:,i));
   Mean= mean(X_Filter,2);    % CAR filter
    for j=1:size(X_Filter,2)
        X_Filter(:,j)=X_Filter(:,j)-Mean;
    end
    X(:,:,i)=X_Filter;
end

