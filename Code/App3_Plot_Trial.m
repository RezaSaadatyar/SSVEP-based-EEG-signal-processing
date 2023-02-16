% =========================== SSVEP (2023-2024) ============================
% ================== Presented by: Reza Saadatyar ==========================
% ================= E-mail: Reza.Saadatyar92@gmail.com =====================
clc;clear;close all
%% ------------------------------ Step 1: Laod Data ------------------------------
Data=load('Data.mat');
X= Data.Data1(:,:,1);   % (number samples, number channel, number trials)
%% ------------------------------- Step 2: Plot Result ---------------------------
name_elec= {'Oz', 'O1', 'O2', 'POz', 'PO3', 'PO4', 'PO7', 'PO8'};
Time= linspace(0,5,1280);
Numb_Channels = 8;
for i=1:Numb_Channels
    subplot(8,1,i)
    plot(Time,X(:,i),'linewidth',1)
    ax=gca;
    ax.XAxis.Visible = 'off';
    ax.YAxis.Visible = 'on';
    ylabel(name_elec(i),"FontSize",10,"FontWeight","bold")
    ax.YTick=[];
    if i==1;title('Freq stimulation=13Hz; Trial 1', 'FontSize',10,'FontWeight','bold');end
end


