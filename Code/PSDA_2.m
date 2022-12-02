function Stotal=PSDA_2(X,f_stim,n,fs)
Stotal=zeros(size(f_stim,2),1);
SK=zeros(1,size(X,2));
for i=1:size(f_stim,2)
for j=1:size(X,2)
    Xi= X(:,j);
    %% PSDA
    % fourier transfrom
    m= size(Xi,1);
    fx= fft(Xi,m);
    fx= fx(1:floor(m/2)+1);
    PSD= abs(fx).^2;
    f= linspace(0,fs/2,floor(m/2)+1);
    %%
    fres= fs/m;
    Step= fres*(n/2);
    %% 13
    indxfk= find((f>=f_stim(i)-0.2) & (f<=f_stim(i)+0.2));
    indx= find((f>=f_stim(i)-Step) & (f<=f_stim(i)+Step));
    SK(j) = 10 * log10( ( n* max(PSD(indxfk)) ) /  (sum(PSD(indx)) - max(PSD(indxfk))) );
end
Stotal(i)= max(SK);
end
end