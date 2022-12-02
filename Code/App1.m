clc;clear;close all
%% 
Data=load('SSVEP.mat');
X= Data.data_L1_13Hz(:,:,1);   % (number samples, number channel, number trials)

name_elec= {'Oz', 'O1', 'O2', 'POz', 'PO3', 'PO4', 'PO7', 'PO8'};
t= linspace(0,5,1280);

for i=1:8
    subplot(8,1,i)
    plot(t,X(:,i),'linewidth',1)
    ax=gca;
    ax.XAxis.Visible = 'off';
    ax.YAxis.Visible = 'on';
    ylabel(name_elec(i),"FontSize",12,"FontWeight","bold")
    ax.YTick=[];
    drawnow
    if i==1;title('Freq stimulation=13Hz; Trial 1', 'FontSize',12,'FontWeight','bold');end
end


