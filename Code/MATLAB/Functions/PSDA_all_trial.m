function PSDA=PSDA_all_trial(X,F_stim,Num_Sample_Neigh,fs, Num_Harmonic)
Step= fs*(Num_Sample_Neigh/2)/size(X,1);         % Number of freaquency neighborhood for each frequency stimulation
F= linspace(0,fs/2,floor(size(X,1)/2)+1);        % x_axis: Hz

PSDA=zeros(size(F_stim,2),1);
PS=zeros(size(X,2),Num_Harmonic);
for i=1:size(F_stim,2)                                      % First loop for frequencies stimulation
    for j=1:size(X,2)                                       % Second loop for read all channels
        Xi= X(:,j);
        X_fft= fft(Xi,size(Xi,1));                          % Fourier transfrom
        X_fft= X_fft(1:floor(size(Xi,1)/2)+1);
        PSD= abs(X_fft).^2;
        for q=1:Num_Harmonic                                % Third loop for harmonic frequencies stimulation
            indxfk= find((F>=q*F_stim(i)-0.2) & (F<=q*F_stim(i)+0.2));  % Find the index frequency stimulation
            ind= find((F>=q*F_stim(i)-Step) & (F<=q*F_stim(i)+Step));   % Find the frequencies around each frequency stimulation
            PS(j,q) = 10*log10((Num_Sample_Neigh*max(PSD(indxfk)))/(sum(PSD(ind))-max(PSD(indxfk))));
        end
    end
    PSDA(i)= max(max(PS,[],2));
end
end