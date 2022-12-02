function [Max_Freq,Label]=PSDA_1(fs, PSD,n,fstim,m)
f= linspace(0,fs/2,floor(m/2)+1);
fres= fs/m;
Step= fres*(n/2);
S = zeros(1,size(fstim,2));
for i=1:size(fstim,2)
    indxfk= find((f>=fstim(i)-0.2) & (f<=fstim(i)+0.2));
    indx= find((f>=fstim(i)-Step) & (f<=fstim(i)+Step));
    S(i) = 10 * log10( ( n* max(PSD(indxfk)) ) /  (sum(PSD(indx))- max(PSD(indxfk))) );
    hold on
    plot(f(indx), PSD(indx),'linewidth',2)
end
xlim([2 f(end)])
[Max_Freq,Label]= max(S);
end