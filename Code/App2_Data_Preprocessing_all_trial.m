% =========================== SSVEP (2023-2024) ============================
% ================== Presented by: Reza Saadatyar ==========================
% ================= E-mail: Reza.Saadatyar92@gmail.com =====================
clc;clear;close all
%% ------------------ Step 1: Convert gdf data to mat ---------------------------
% biosig4octmat ---> biosig ---> run the install code
%% --------------------- Step 2: Access data folders-----------------------------
folderPath = 'C:\Users\rsaad\OneDrive\Desktop\SSVEP-main\Data';                                     % Add address data
filename=dir(fullfile(folderPath, '*.gdf'));                             % Read data with gdf format
Fs = 256;
Time_trial = 5;                                                          % Second
Duration_trial = Fs*Time_trial;                                          % Fs*time each trial

for i = 1:length(filename)                                               % First loop ---> read all data
    [Signal,Inform]= sload(filename(i).name);
    %% -------------------------------- Step 3:Split trials -----------------------
    % Label_01 ---> 13Hz stimulation (33025)
    % Label_02 ---> 21Hz stimulation (33026)
    % Label_03 ---> 17Hz stimulation (33027).

    Labels= Inform.EVENT.TYP;
    Time_start_trial= Inform.EVENT.POS;

    for j=1:3                                                             % Second loop ---> read labels     
        Lab = [33025,33026,33027];
        Numb_Trials=find(Labels==Lab(j));
        Data=zeros(Duration_trial,Numb_Channels,length(Numb_Trials));
       
        for k=1:length(Numb_Trials)                                       % Third loop ---> Sorting trials based on each label in the Signal
            if exist('Data1','var') && (i>1) && (j==1)
                Data1(:, : ,size(Data1,3)+1)=Signal(Time_start_trial(Numb_Trials(k)):Time_start_trial(Numb_Trials(k))+Duration_trial-1,:);
            elseif exist('Data2','var') && (i>1) && (j==2)
                Data2(:, : ,size(Data2,3)+1)=Signal(Time_start_trial(Numb_Trials(k)):Time_start_trial(Numb_Trials(k))+Duration_trial-1,:);
            elseif exist('Data3','var') && (i>1) && (j==3)
                Data3(:, : ,size(Data3,3)+1)=Signal(Time_start_trial(Numb_Trials(k)):Time_start_trial(Numb_Trials(k))+Duration_trial-1,:);
            else
                Data(:, : ,k)=Signal(Time_start_trial(Numb_Trials(k)):Time_start_trial(Numb_Trials(k))+Duration_trial-1,:);
            end
        end
        if exist('Data1','var')==0 || exist('Data2','var')==0 || exist('Data3','var')==0
            eval(['Data' num2str(j)  ' = Data;'])
        end
    end
end
save('Data','Data1','Data2','Data3')



