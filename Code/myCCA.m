function [rho] = myCCA(A,B)
%% Cannonical Correlation Analysis
if size(A,2) <=  size(B,2)
    X=A;
    Y=B;
else
    X=B;
    Y=A;
end
%% step 2: calculate covariance matrixs
XY= [X,Y];
Cv= cov(XY);
p= size(X,2);
Cxx= Cv(1:p,1:p);
Cyy= Cv(p+1:end,p+1:end);
Cxy= Cv(1:p,p+1:end);
% Cyx= Cxy';
Cyx= Cv(p+1:end,1:p);
%% step 3: build your eigen value decomposition problem
C= inv(Cyy+eps) * Cyx * inv(Cxx+eps) * Cxy;
%% step 4:  eigen value decomposition
[~,D]= eig(C);
%% step 5: diag,sort, sqrt
D= diag(real(D));
D= sort(D,'descend');
rho= sqrt(D(1:p));
end

