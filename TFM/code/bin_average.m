function [x_out,y_out,y_out_un] = bin_average(x,y,bin_number)

x_out = zeros(1,bin_number);
y_out = zeros(1,bin_number);
y_out_un = zeros(1,bin_number);

dx = max(x)/bin_number;

for k = 1:bin_number
    x1 = (k-1)*dx;
    x2 = k*dx;
    x_out(k) = 1/2*(x1+x2);
    temp = find(x>=x1 & x<x2);
    y_out(k) = mean(y(temp));
    y_out_un(k) = std(y(temp))/sqrt(numel(temp));
end
end