function x_car=car_filter(input)
mean_= mean(input,2);                   
for j=1:size(input,2)
    input(:,j)=input(:,j)-mean_;
end
x_car = input;
end