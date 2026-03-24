function newcode_spatial_correlation(dd)
% This function gives the spatial correlation function of a stress distribution.
% stress_map is
% sqrt(((d(i).stress_x.*d(i).fov).^2)+((d(i).stress_y.*d(i).fov).^2)) in
% the 436th row of Xulab_test_master.m

% First remove the padded boundaries with zero values.
[r,c] = find(dd~=0);
% N is the number of pixels being considered.
N = numel(c);
disp(['number of pixel = ' num2str(N)]);

min_r = min(r);
max_r = max(r);
min_c = min(c);
max_c = max(c);

Mat_reduce = dd(min_r:max_r,min_c:max_c);
mean_stress = mean(mean(Mat_reduce));
disp([' mean stress = ' num2str(mean_stress)]);

figure,imshow(Mat_reduce);
stress_product = [];
dis = [];
for i = 1:N
%    disp(i);
    
    for j = 1:N
        temp = (dd(r(i),c(i))-mean_stress)*(dd(r(j),c(j))-mean_stress);
        stress_product = [stress_product temp];
        dis = [dis sqrt((r(i)-r(j))^2+(c(i)-c(j))^2)];
    end
end

disp(var(Mat_reduce(:)));

figure,plot(dis,stress_product/var(Mat_reduce(:)),'.');

bin_number = 50;
x = dis;
y = stress_product/var(Mat_reduce(:));

[x_out,y_out,y_out_un] = bin_average(x,y,bin_number);
hold on;
errorbar(x_out,y_out,y_out_un,'ro-','LineWidth',2);

figure;
hold on;
errorbar(x_out,y_out,y_out_un,'ro-','LineWidth',2);


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


