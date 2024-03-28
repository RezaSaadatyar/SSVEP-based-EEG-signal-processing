% =========================== SSVEP (2023-2024) ============================
% ================== Presented by: Reza Saadatyar ==========================
% ================= E-mail: Reza.Saadatyar92@gmail.com =====================
clc;            % Clear command window
clear;          % Clear workspace variables
close all;      % Close all figures
%% ------------------------------ Step 1: Load Data ------------------------------
addpath(genpath(cd)) % Add the current directory and its subfolders to the MATLAB search path
% Let the user select a mat file containing EEG data
filename = uigetfile({'*.mat','mat file';'*.*','All Files'},'File Selection','multiselect','off');
data = load(filename); % Load the data from the selected mat file

x = data.data1;  % Extract EEG data for the first trial (number samples, number channel, number trials)

fs=256;
time = (0:size(x,1)-1)*1/fs;   % Time vector
%% -------------------------- Step 2: Filtering all trials ---------------------
wn= [49.2 50.6]/(fs/2);
[b,a]= butter(4,wn,"stop");

x_car = zeros(size(x,1),size(x,2),size(x,3));  % (number samples, number channel, number trials)
for i=1:size(x,3)
    x_filter= filtfilt(b,a,x(:,:,i));
    x_car(:,:,i)= car_filter(x_filter);        % CAR filter
end
%% --------------------------- Step 3: Plot Results ----------------------------
figure()
subplot(2,1,1)
plot(time,x(:,1,1),'linewidth',0.5)
title('Freq stimulation=13Hz; OZ; Trial 1', FontSize=10,FontWeight='bold')
legend({'Raw signal'}, FontSize=8,FontWeight="bold")
subplot(2,1,2)
plot(time,x_car(:,1,1),'linewidth',0.5)
legend({'Filter CAR'}, FontSize=8,FontWeight="bold")
xlabel('Time(sec)',FontSize=10,FontWeight="bold")

