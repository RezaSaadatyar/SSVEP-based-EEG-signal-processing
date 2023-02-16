function S = MSI(X,Data_Ref,Num_Harmonic)

Num_Channel= size(X,2);    % Size X ---> N×Num_Channel and Data_Ref --->2Nh ×N;

% N is the number of samples, and Nh is the number of harmonics for the sine and cosine components
% Article: Multivariate synchronization index for frequency recognition of SSVEP-based brain–computer interface.
% matrix C includes both the autocorrelation and crosscorrelation of X and Data_Ref, and the autocorrelation will 
% inﬂuence the synchronization measure. To reduce these inﬂuences, the following linear transformation is adopted
%% ----------------------------- Step 1: Covariance matrixs ---------------------
C= cov([X,Data_Ref]);
C11= C(1:Num_Channel,1:Num_Channel);
C22= C(Num_Channel+1:end,Num_Channel+1:end);
C12= C(1:Num_Channel,Num_Channel+1:end);
C21= C(Num_Channel+1:end,1:Num_Channel);
%% -------------------- Step 2: Transformed corrleation matrix ------------------
R= [eye(Num_Channel)                        (sqrt(C11)\(C12+eps))/(sqrt(C22)+eps);
   (sqrt(C22)\(C21+eps))/(sqrt(C11)+eps)    eye(2*Num_Harmonic)];  
%% -------------------- Step 3: Eigenvalues of matrix ---------------------------
[~,Landa]= eig(R);
Landa= diag(Landa);
Landa= Landa./sum(Landa);     % Normalize eigenvalues
%% --------------- Step 4: Synchronization index between two signals ------------
S= 1 + (sum(Landa.*log(Landa)) / log(Num_Channel+2*Num_Harmonic));
% If the two sets of signals are uncorrelated, C12 = C21 = 0, and R will be diagonal. Then, S should be zero.
% If the two sets of signals are perfectly correlated, R will have ones on the main diagonal and zeros elsewhere. 
% Only one normalized eigenvalue is one, and the other eigenvalues are zeros.Therefore, S should be one. 
% For other situations, the S value should range from zero to one.
end