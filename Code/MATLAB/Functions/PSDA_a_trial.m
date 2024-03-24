function [Max_Freq,Label]=PSDA_a_trial(fs, Xi,Num_Sample_Neigh,F_stim, Num_Harmonic)

F= linspace(0,fs/2,floor(size(Xi,1)/2)+1);
Step= fs*(Num_Sample_Neigh/2)/size(Xi,1);                   % Number of freaquency neighborhood for each frequency stimulation        
PSDA = zeros(size(F_stim,2),Num_Harmonic);                  % PSDA for frequencies stimulation and their harmonics
Legend = cell(1,Num_Harmonic*length(F_stim));               % Legend 
k = 0;                                       

X_fft= fft(Xi,size(Xi,1));                                  % FFT
X_fft= X_fft(1:floor(size(Xi,1)/2)+1);
PSD= abs(X_fft).^2;

figure()
plot(F(2:end), PSD(2:end),'linewidth',1.5); 
for i=1:size(F_stim,2)                                               % First loop for frequencies stimulation
    for j=1:Num_Harmonic                                             % Second loop for harmonic frequencies stimulation
        k = k+1;
        indxfk= find((F>=j*F_stim(i)-0.2) & (F<=j*F_stim(i)+0.2));   % Find the index frequency stimulation
        ind= find((F>=j*F_stim(i)-Step) & (F<=j*F_stim(i)+Step));    % Find the frequencies around each frequency stimulation
        PSDA(i,j) = 10 * log10((Num_Sample_Neigh* max(PSD(indxfk)))/(sum(PSD(ind))- max(PSD(indxfk)))); % PSDA
        hold on
        plot(F(ind), PSD(ind),'linewidth',2.5)
        Legend{k} = ['F_{stim}_' num2str(i) '_._H_' num2str(j) ':' num2str(F_stim(i)*j)];
    end

end
xlim([2 F(end)])
[Max_Freq,Label]= max(max(PSDA,[],2));

legend(['PSD',Legend],FontSize=8,FontWeight="bold",NumColumns=2)
title('Freq stimulation:13Hz; Trial:87; PSDA method for a channel','FontSize',10,'FontWeight','bold')
xlabel('F(Hz)','FontSize',10,'FontWeight','bold')
ylabel('PSD','FontSize',10,'FontWeight','bold')
end