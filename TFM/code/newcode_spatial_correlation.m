function [x_out,y_out,y_out_un]=newcode_spatial_correlation(sx)
% This function gives the spatial correlation function of a stress distribution.
% stress_map is
% sqrt(((d(i).stress_x.*d(i).fov).^2)+((d(i).stress_y.*d(i).fov).^2)) in
% the 436th row of Xulab_test_master.m

% First remove the padded boundaries with zero values.
[r,c] = find(sx~=0);
% N is the number of pixels being considered.
N = numel(c);
disp(['number of pixel = ' num2str(N)]);

min_r = min(r);
max_r = max(r);
min_c = min(c);
max_c = max(c);

Mat_reduce = sx(min_r:max_r,min_c:max_c);
mean_stress = mean(mean(Mat_reduce));
disp([' mean stress = ' num2str(mean_stress)]);

figure,imshow(Mat_reduce);
stress_product = [];
dis = [];
for i = 1:N
%    disp(i);
    
    for j = 1:N
        temp = (sx(r(i),c(i))-mean_stress)*(sx(r(j),c(j))-mean_stress);
        stress_product = [stress_product temp];
        dis = [dis sqrt((r(i)-r(j))^2+(c(i)-c(j))^2)];
    end
end

disp(var(Mat_reduce(:)));

%figure,plot(dis,stress_product/var(Mat_reduce(:)),'.');

bin_number = 50;
x = dis;
y = stress_product/var(Mat_reduce(:));

[x_out,y_out,y_out_un] = bin_average(x,y,bin_number);
% hold on;
% errorbar(x_out,y_out,y_out_un,'ro-','LineWidth',2);

% figure;
% hold on;
% errorbar(x_out,y_out,y_out_un,'ro-','LineWidth',2);
end
