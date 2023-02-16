function [y] = ELM(Train_Features,Test_Features,Train_Labels,Test_Labels,Num_Neurons)

Train_Labels=full(ind2vec(Train_Labels));
Test_Labels=full(ind2vec(Test_Labels));

w= randn(Num_Neurons,size(Train_Features,1))*0.01;      % Weights between input and hidden layers

H = [-ones(1,size(tanh(w*Train_Features),2));tanh(w*Train_Features)];

beta = (((H*H')\H)*Train_Labels')';                     % Weights between hidden and output layers

H = [-ones(1,size(tanh(w*Test_Features),2));tanh(w*Test_Features)]; % test Trained ELM

  y = sign(beta*H);
  y1=(1./(1+exp(-2*y)));

  accuracy = sum(vec2ind(y1)==vec2ind(Test_Labels)) / length(Test_Labels) *100;

end