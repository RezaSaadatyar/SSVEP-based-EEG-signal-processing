% =========================== SSVEP (2023-2024) ============================
% ================== Presented by: Reza Saadatyar ==========================
% ================= E-mail: Reza.Saadatyar92@gmail.com =====================
clc;clear;close all
%% ------------------ Step 1: Convert gdf data to mat ---------------------------
% biosig4octmat ---> biosig ---> run the install code
folderPath = 'C:\Users\rsaad\OneDrive\Desktop\SSVEP-main\Data';           % Add address data
filename=dir(fullfile(folderPath, '*.gdf'));                              % Read data with gdf format

[Signal,Inform]= sload(filename(1).name);    % filename(1).name: 'Subject2-[2012.04.07-19.27.02].gdf'                  
%% -------------------------------- Step 2:Split trials --------------------------
% Label_01 ---> 13Hz stimulation (33025)
% Label_02 ---> 21Hz stimulation (33026)
% Label_03 ---> 17Hz stimulation (33027).
Labels = Inform.EVENT.TYP;
Time_start_trial = Inform.EVENT.POS;
Fs = 256;
Time_trial = 5;                              % Second
Duration_trial = Fs*Time_trial;              % Fs*time each trial
Numb_Channels = 8;

for i=1:3
    Lab = [33025,33026,33027];
    Numb_Trials=find(Labels==Lab(i));
    Data=zeros(Duration_trial,Numb_Channels,length(Numb_Trials));
    for j=1:length(Numb_Trials)
        Data(:, : ,j)=Signal(Time_start_trial(Numb_Trials(j)):Time_start_trial(Numb_Trials(j))+Duration_trial-1,:);
    end
    eval(['Data_' num2str(i) ' = Data;'])
end



