function X_CAR=CAR_Filter(Input)
Mean= mean(Input,2);                   
for j=1:size(Input,2)
    Input(:,j)=Input(:,j)-Mean;
end
X_CAR = Input;
end