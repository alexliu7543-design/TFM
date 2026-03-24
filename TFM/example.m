%% Purpose
% This code is designed for debugging parameters in image processing.
% It generates images after various processing steps, focusing on
% manually evaluating the effectiveness of tracking.
close all;
clearvars; % Clear variables, avoiding 'clear all' to keep functions loaded

%% Load Files
BaseDir = 'D:\OneDrive - HKUST Connect\experiment\T240930_BSM\code\code\';
addpath(BaseDir);

RefDir = 'D:\OneDrive - HKUST Connect\experiment\T250521_TFM_HierarchicalRelax\T250519_Calibration\T250519_Calibration_100Pa\';
addpath(RefDir);
imageNamesRef = dir(fullfile(RefDir, '*.bmp'));
imageNamesRef = {imageNamesRef.name}';

workingDir = RefDir; % Set working directory

Out_Dir = 'D:\OneDrive - HKUST Connect\experiment\T250521_TFM_HierarchicalRelax\T250519_Calibration\T250519_Calibration_100Pa\Output\example';
mkdir(Out_Dir); % Create output directory if it doesn't exist
addpath(workingDir);

imageNames = dir(fullfile(workingDir, '*.bmp'));
imageNames = {imageNames.name}';

%% Set Parameters
th = 0.01; % Threshold to recognize beads
lnoise = 0.8; % Noise level for bandpass filtering
lobject = 5; % Object size for bandpass filtering
pksz = 4; % Size for finding peak points
ctsz = 3; % Size for calculating the centroid of brightness
maxdisp = 7; % Maximum displacement

%% Process Reference Image
ref = 3; % Reference image index
file_name = fullfile(RefDir, imageNamesRef{ref});
im1 = imread(file_name);
a = im2double(im1(:,:,2)); % Convert to double and use green channel
b = bpass(a, lnoise, lobject); % Bandpass filter
pk = pkfnd(b, th, pksz); % Find peak points
cnt = cntrd(b, pk, ctsz); % Calculate centroids

% Plotting results
figure(1);
colormap('gray');

% Subplot 1: Processed Image
subplot(2, 2, 1);
imagesc(b);
hold on;
plot(pk(:, 1), pk(:, 2), 'bo', 'LineWidth', 2); % Plot peak points
plot(cnt(:, 1), cnt(:, 2), 'rx', 'LineWidth', 2); % Plot centroids
xlabel('x [pixels]');
ylabel('y [pixels]');
axis equal;
xlim([40 80]);
ylim([40 60]);
axis on;
hold off;

% Subplot 2: Original Image
subplot(2, 2, 2);
imagesc(a);
hold on;
plot(pk(:, 1), pk(:, 2), 'bo', 'LineWidth', 2);
plot(cnt(:, 1), cnt(:, 2), 'rx', 'LineWidth', 2);
xlabel('x [pixels]');
ylabel('y [pixels]');
axis equal;
xlim([40 80]);
ylim([40 60]);
axis on;
hold off;
time =1;
cnt1 = zeros(length(cnt),3);
for k = 1:length(cnt)
    cnt1(k,1) = cnt(k,1);
    cnt1(k,2) = cnt(k,2);
    cnt1(k,3) = time;
end
% cut a part image around boundary
xmn = min(cnt1(:,1));
ymn = min(cnt1(:,2));
xmx = max(cnt1(:,1));
ymx = max(cnt1(:,2));

condition = (cnt1(:,1) >= xmn + maxdisp) & ...
    (cnt1(:,2) >= ymn + maxdisp) & ...
    (cnt1(:,1) <= xmx - maxdisp) & ...
    (cnt1(:,2) <= ymx - maxdisp);

cnt1 = cnt1(condition, :);


%% Process Another Image
kk = 16; % Index for another image
file_name = fullfile(workingDir, imageNames{kk});
im1 = imread(file_name);
a = im2double(im1(:,:,2));
b = bpass(a, lnoise, lobject);
pk = pkfnd(b, th, pksz);
cnt = cntrd(b, pk, ctsz);

% Subplot 3: Processed Another Image
subplot(2, 2, 3);
imagesc(b);
hold on;
plot(pk(:, 1), pk(:, 2), 'bo', 'LineWidth', 2);
plot(cnt(:, 1), cnt(:, 2), 'rx', 'LineWidth', 2);
xlabel('x [pixels]');
ylabel('y [pixels]');
axis equal;
xlim([40 80]);
ylim([40 60]);
axis on;
hold off;

% Subplot 4: Original Another Image
subplot(2, 2, 4);
imagesc(a);
hold on;
plot(pk(:, 1), pk(:, 2), 'bo', 'LineWidth', 2);
plot(cnt(:, 1), cnt(:, 2), 'rx', 'LineWidth', 2);
xlabel('x [pixels]');
ylabel('y [pixels]');
axis equal;
xlim([40 80]);
ylim([40 60]);
axis on;
hold off;
time = 2;
cnt2 = zeros(length(cnt),3);
for k = 1:length(cnt)
    cnt2(k,1) = cnt(k,1);
    cnt2(k,2) = cnt(k,2);
    cnt2(k,3) = time;
end

%% Save Figure
savefile_name = sprintf('Position_%d_vs_%d.fig', ref, kk);
saveas(gcf, fullfile(Out_Dir, savefile_name));


%% tracking displacement field
disp(size(cnt1));
disp(size(cnt2));
Pos_list = [cnt1
    cnt2];

%% Plot the two images to identify the rough displacement
% figure,imagesc(im1-im2);
% axis image;
%colormap(jet);

track_result = track(Pos_list,maxdisp); %why is it 10


num_tracked = max(track_result(:,4));



%dis=zeros(num_tracked,2);
%p1 = zeros(num_tracked,2);
%p2 = zeros(num_tracked,2);
dis=zeros(1,2);
p1 = zeros(1,2);
p2 = zeros(1,2);
count = 0;

for i = 2:num_tracked
    temp = find(track_result(:,4) == i);
    if numel(temp) == 2

        x1 = track_result(temp(1),1);
        y1 = track_result(temp(1),2);
        x2 = track_result(temp(2),1);
        y2 = track_result(temp(2),2);

        if x1~=0 && y1~=0 && x2~=0 && y2~=0

            count = count+1;
            dis(count,1) =x2-x1;
            dis(count,2) = y2-y1;

            p1(count,1) = x1;
            p1(count,2) = y1;

            p2(count,1) = x2;
            p2(count,2) = y2;


        end
    end
end
d = struct();
d(1).r = p1;
d(2).r = p2;
d(1).dr = zeros(length(p1),2);
d(2).dr = dis;
nb_beads = length(d(1).r); % Total number of beads
disp(['Number of beads without drop = ' num2str(nb_beads)]);

%% take every u into consider to contrast its angle with nearest n u, remove those u which exceed the threthold
r = d(1).r; % Get the position array
dr = d(2).dr; % Get the corresponding data array
n = 15; % Number of nearest points to find

num_points = size(r, 1); % Total number of points
n = min(n, num_points - 1); % Adjust n to be at most num_points - 1

% Initialize an array to store the indices of the nearest n points for each point
nearest_indices = zeros(size(r, 1), n);

% Initialize a cell array to store extracted elements
extracted_values = cell(size(r, 1), 1);
% Initialize arrays to store corresponding dx and dy
dx_values = cell(num_points, 1);
dy_values = cell(num_points, 1);

% Calculate distances and find the nearest n points
for i = 1:size(r, 1)
    % Calculate the distance from the current point to all other points
    distances = sqrt(sum((r - r(i, :)).^2, 2)); % Calculate Euclidean distance

    % Set the distance to itself to a very large number to exclude it from the nearest points
    distances(i) = inf; % Exclude the current point from its nearest neighbors

    % Sort distances and get the indices of the nearest n points
    [sorted_distances, sorted_indices] = sort(distances, 'ascend'); % Sort the distances

    % Store the indices of the nearest n points in a row vector
    nearest_indices(i, :) = sorted_indices(1:n); % Take the first n indices

    % Extract the elements corresponding to the nearest n points from d(2).dr
    extracted_values{i} = dr(nearest_indices(i, :), :); % Extract corresponding elements

    % Store dx and dy for the nearest n points
    dx_values{i} = extracted_values{i}(:, 1); % Get dx
    dy_values{i} = extracted_values{i}(:, 2); % Get dy
end

% Calculate the mean and standard deviation for dx and dy
mean_dx = zeros(num_points, 1);
std_dx = zeros(num_points, 1);
mean_dy = zeros(num_points, 1);
std_dy = zeros(num_points, 1);
thresholds_upper_dx = zeros(num_points, 1);
thresholds_lower_dx = zeros(num_points, 1);
thresholds_upper_dy = zeros(num_points, 1);
thresholds_lower_dy = zeros(num_points, 1);

for i = 1:num_points
    mean_dx(i) = mean(dx_values{i}); % Calculate mean dx
    std_dx(i) = std(dx_values{i}); % Calculate standard deviation of dx
    mean_dy(i) = mean(dy_values{i}); % Calculate mean dy
    std_dy(i) = std(dy_values{i}); % Calculate standard deviation of dy

    % Calculate thresholds for dx
    thresholds_upper_dx(i) = mean_dx(i) + 3 * std_dx(i);
    thresholds_lower_dx(i) = mean_dx(i) - 3 * std_dx(i);

    % Calculate thresholds for dy
    thresholds_upper_dy(i) = mean_dy(i) + 3 * std_dy(i);
    thresholds_lower_dy(i) = mean_dy(i) - 3 * std_dy(i);
end

% Check if either dx or dy for each point exceeds the thresholds
out_of_bounds = false(num_points, 1); % Initialize the flag for out-of-bounds points
outlier_indices = []; % Initialize the indices of out-of-bounds points

for i = 1:num_points
    % Extract the current point's dx and dy
    dx_current = dr(i, 1); % Current point's dx
    dy_current = dr(i, 2); % Current point's dy

    % Check if current point's dx or dy exceeds the threshold
    if dx_current > thresholds_upper_dx(i) || dx_current < thresholds_lower_dx(i) || ...
            dy_current > thresholds_upper_dy(i) || dy_current < thresholds_lower_dy(i)
        out_of_bounds(i) = true; % Mark as out-of-bounds
        outlier_indices = [outlier_indices; i]; % Collect out-of-bounds indices
    end
end

% Remove out-of-bounds points
d(1).r(outlier_indices, :) = []; % Remove corresponding rows from d(1).r
d(2).r(outlier_indices, :) = [];
d(1).dr(outlier_indices, :) = [];
d(2).dr(outlier_indices, :) = [];

nb_beads = length(d(1).r); % Total number of beads
disp(['Number of beads after drop = ' num2str(nb_beads)]);

disp(numel(find(d(1).r(:,1)==0)));

r1 = d(1).r;
r2 = d(2).r;
dr = d(2).dr;
figure(2)
hold on;
plot(r1(:,1),r1(:,2),'rx');
plot(r2(:,1),r2(:,2),'gx');
quiver(r1(:,1),r1(:,2),dr(:,1),dr(:,2),'off','blue');
axis equal;
xlim([00 100]);
ylim([00 100]);
xlabel('x [pixels]');
ylabel('y [pixels]');
axis on;
hold off;
savefile_name = sprintf('Displacement_%d_vs_%d.fig', ref, kk);
saveas(gcf,fullfile(Out_Dir,savefile_name))


%% Create the grid to interpolate the particle tracking data onto
% This section should remain unchanged if adapting to 3D TFM.
tref = 1; % Reference time index
min_feature_size=4;
% This is the spatial resolution of the stress measurement in units of the grid spacing.
% The smaller min_feature_size the better your spatial resoltuion, but
% the worse signal to noise in the stress.
% Subtract off displacements from reference time
for i = 1:length(d)
    d(i).dr = d(i).dr - d(tref).dr; % Center displacements around reference time
end

% Select number of points for interpolated grid
ovr = 1; % Spatial oversampling (ovr=1 gives grid spacing= avg interparticle distance, ovr should be <= 1)
nb_beads = length(d(1).r); % Total number of beads
% disp(['Number of beads = ' num2str(nb_beads)]);

% Calculate the number of points on each side of the interpolation grid
nx = round(ovr * sqrt(nb_beads)); % Grid size estimation
if mod(nx, 2) == 0
    nx = nx + 1; % Ensure an odd number of points in grid
end

% Padding settings to reduce artifacts in stress calculation
fracpad = 0.5; % Fraction of extra padding on each side of the original data
npad = round(fracpad * nx); % Calculate padding size

% Calculate the boundaries of the data set
xmn = min(d(tref).r(:, 1)); % Minimum x-value
xmx = max(d(tref).r(:, 1)); % Maximum x-value
ymn = min(d(tref).r(:, 2)); % Minimum y-value
ymx = max(d(tref).r(:, 2)); % Maximum y-value

disp(['xmn = ' num2str(xmn)]);
disp(['xmx = ' num2str(xmx)]);
disp(['ymn = ' num2str(ymn)]);
disp(['ymx = ' num2str(ymx)]);

% Calculate distance between the grid points
dx = max((xmx - xmn) / nx, (ymx - ymn) / nx);
disp(['dx = ' num2str(dx)]);
disp(['nx = ' num2str(nx)]);

% Calculate the center of the data set
c = 0.5 * [xmn + xmx, ymn + ymx];

% Construct the grid for interpolation
xi = linspace(-(nx - 1) / 2 - npad, (nx - 1) / 2 + npad, nx + 2 * npad) * dx + c(1);
yi = linspace(-(nx - 1) / 2 - npad, (nx - 1) / 2 + npad, nx + 2 * npad) * dx + c(2);

% Create a meshgrid for interpolation
[X, Y] = meshgrid(xi, yi); % Matrix of grid points

%% Interpolate the particle track data onto the grid
for i = 1:length(d)
    % Interpolate the displacements onto the grid
    d(i).dx_interp = surface_interpolate(d(i).r(:, 1), d(i).r(:, 2), d(i).dr(:, 1), X, Y, 10);
    d(i).dy_interp = surface_interpolate(d(i).r(:, 1), d(i).r(:, 2), d(i).dr(:, 2), X, Y, 10);

    % Find indices of all NaNs in interpolated results
    ind2 = find(isnan(d(i).dx_interp));

    % Create field of view array (fov) at each time point
    d(i).fov = ones(size(X)); % Initialize FOV array
    d(i).fov(ind2) = 0; % Set zeros outside of field of view
end

%% displacement distribution
% Assume u is your data array
% Calculate the data
u = sqrt(d(i).dx_interp.^2 + d(i).dy_interp.^2);

figure;
imagesc(X(1,:), Y(:,1),u);
axis image;
colormap(jet);
colorbar;
axis([0 1392 0 1040]);
% clim([min_val, max_val]);
% axis(nr * 2 + [0 nr 0 nr]);
title('$| \vec{u} |$','Interpreter','latex','FontSize',20);

% Set font properties for axes
set(gca, 'FontSize', 20, 'FontName', 'Times New Roman', 'TickLabelInterpreter', 'latex');

% Add axis labels
xlabel('x [pixels]', 'FontSize', 25, 'FontName', 'Times New Roman', 'LineWidth', 2);
ylabel('y [pixels]', 'FontSize', 25, 'FontName', 'Times New Roman', 'LineWidth', 2);

% Customize grid appearance
set(gca, 'GridLineStyle', ':', 'GridColor', 'r', 'GridAlpha', 0.5, 'LineWidth', 2);



% % Remove NaN values
% [row_indices, col_indices] = find(~isnan(u)); % Get row and column indices of non-NaN values
% 
% % Determine the limits of the non-NaN values
% min_row = min(row_indices);
% max_row = max(row_indices);
% min_col = min(col_indices);
% max_col = max(col_indices);
% 
% % Crop the matrix to remove surrounding NaN values
% u_cropped = u(min_row:max_row, min_col:max_col);
% % Set the number of rows per group
% num_rows_per_group = 6; % You can adjust this value as needed
% num_points = size(u_cropped,1); % Total number of points in the array
% 
% % Calculate the number of groups
% num_groups = floor(num_points / num_rows_per_group); 
% 
% % Initialize arrays to store the mean values and center points of each group
% group_means = zeros(num_groups, 1);
% group_centers = zeros(num_groups, 1);
% 
% % Divide u into groups and calculate mean values
% for k = 1:num_groups
%     % Determine the indices for the current group
%     start_index = (k-1) * num_rows_per_group + 1;
%     end_index = start_index + num_rows_per_group - 1;
% 
%     % Calculate the mean value for the current group
%     group_means(k) = mean(u_cropped(start_index:end_index),"all");
% 
%     % Calculate the center point for the current group
%     group_centers(k) = (start_index + end_index) / 2;
% end
% 
% % Plot the scatter plot
% figure;
% scatter(group_centers*dx, group_means, 'filled');
% xlabel('y [pixels]','Interpreter','latex','FontSize',18);
% ylabel('$|\vec{u}|$ [pixels]','Interpreter','latex','FontSize',18);
% title('displacement distribution along radius');
% grid on;


%% Plot raw data and interpolated results
figure;
% Scatter plot of raw data
scatter3(d(2).r(:, 1), d(2).r(:, 2), d(2).dr(:, 1), 'filled', 'MarkerEdgeColor', 'k');
hold on;

% Surface plot of interpolated outcomes
surf(X, Y, d(2).dx_interp, 'EdgeColor', 'none'); % Plot interpolated surface
colorbar;  % Display color bar to indicate values
xlim([100 200]);
ylim([100 200]);
xlabel('X(Pixels)'); % Label for X-axis
ylabel('Y(Pixels)'); % Label for Y-axis
zlabel('dx(Pixels)'); % Label for Z-axis
title('2D Surface Interpolation for x-displacement'); % Title of the plot
view(45, 30); % Set view angle
grid on; % Enable grid
hold off; % Release current figure

%% Calculate Q matrix. This is the matrix that relates tractions and displacements
% in Fourier space. The original derivation and expression for Q is in Xu
% et al. PNAS 107, 14964-14967 (2010). Note that this example code is for
% 2d traction force microscopy (where out-of-plane tractions are assumed to
% be negligible). If performing 3d TFM, ensure that the arguments to calcQ
% are modified appropriately. (see documentation for calcQ)
thick = 80e-6;
EM = 21000*800/1074;
nu = 0.48;
[nr,~]=size(X);
pix = 4.4/1392/1000;

fracpad=2;  %fraction of field of view to pad displacements on either side of current fov+extrapolated to get high k contributions to Q
% It seems that this extrapolation is necessary to calculate Q.
nr2 = round((1+2*fracpad)*nr);
if mod(nr2,2)==0
    nr2=nr2+1;
end


% now the input has units: thick (meter), EM (pa), dx (in meter)
% !!!
Q = calcQ(thick,thick,EM,nu,nr2,dx,2); % Q matrix that interpolates between displacements and stresses at the substrate surface in Fourier space.

%% calculate filter for the displacement data (in Fourier space).
% This is effectively a low-pass exponential filter.
% No changes should be necessary if modifying code for 3d TFM.
[nr,nc]=size(X);

fracpad=2;  %fraction of field of view to pad displacements on either side of current fov+extrapolated to get high k contributions to Q
% It seems that this extrapolation is necessary to calculate Q.
nr2 = round((1+2*fracpad)*nr);
if mod(nr2,2)==0
    nr2=nr2+1;
end

qmax=nr2/(pi*min_feature_size);

% Get distance from of a grid point from the centre of the array
y=repmat((1:nr2)'-nr2/2,1,nr2);
x=y';
q=sqrt(x.^2+y.^2); % nr2*nr2

% Make the filter
qmsk=exp(-(q./qmax).^2);
qmsk=ifftshift(qmsk);

% % Display qmsk as a 3D surface
% figure;
% surf(x, y, qmsk, 'EdgeColor', 'none'); % 'EdgeColor' set to 'none' for a smooth surface
% colormap(jet); % Set colormap
% colorbar; % Add colorbar
% xlabel('X Distance');
% ylabel('Y Distance');
% zlabel('Filter Value');
% title('3D Surface of the Low-Pass Exponential Filter (qmsk)');
% view(30, 30); % Adjust the view angle
% grid on; % Turn on the grid

% Make 1d Hann windows
[szr,szc]=size(d(1).dx_interp);
w_c=0.5*(1-cos(2*pi*(0:szc-1)/(szc-1)));
w_r=0.5*(1-cos(2*pi*(0:szr-1)/(szr-1)));

% Mesh Hann windows together to form 2d Hann window
[wnx,wny]=meshgrid(w_c,w_r);
wn=wnx.*wny;

% Pad the window
padwidth=(nr2-nr)/2;
padheight=(nr2-nr)/2;
[sz1,sz2]=size(wn);
wn=[zeros(sz1+2*padheight,padwidth) [zeros(padheight,sz2);wn;zeros(padheight,sz2)] zeros(sz1+2*padheight,padwidth)];

%% process disp and plot surface interpolationg after low-pass filter and Hanning window
% Get rid of NaN's in the interpolated displacement data
i = 2;
% Extrapolate missing values in x and y displacements
d(i).dx_interp = extrapdisp(d(i).dx_interp);
d(i).dy_interp = extrapdisp(d(i).dy_interp);

utmp = struct();

% Pad and filter x displacements, then multiply by the Hanning window function
[sz1, sz2] = size(d(i).dx_interp);
utmp(1).u = [
    zeros(sz1 + 2 * padheight, padwidth), ...
    [zeros(padheight, sz2); d(i).dx_interp; zeros(padheight, sz2)], ...
    zeros(sz1 + 2 * padheight, padwidth)
    ];

% Get min and max values for colormap scaling
min_val = min(utmp(1).u(:));
max_val = max(utmp(1).u(:));

% Display original padded displacement
figure;
imagesc(utmp(1).u);
axis image;
colormap(jet);
colorbar;
clim([min_val, max_val]);
axis(nr * 2 + [0 nr 0 nr]);
title('utmp(1).u by definition');


% % Perform Fourier transform and low-pass filtering
% uk = real(fftshift(fft2(utmp(1).u)));
% figure;
% imagesc(uk);
% axis image;
% colormap(jet);
% colorbar;
% axis(nr * 2 + [0 nr 0 nr]);
% title('kx in spectral space before filter');

% Apply the filter in spectral space
utmp(1).u = real(ifft2(qmsk .* fft2(utmp(1).u)));

% Display result after Fourier process
figure;
imagesc(utmp(1).u);
axis image;
colormap(jet);
colorbar;
clim([min_val, max_val]);
axis(nr * 2 + [0 nr 0 nr]);
title('utmp(1).u after Fourier process');

% % Show the transformed data in spectral space after filtering
% uk = real(fftshift(fft2(utmp(1).u)));
% figure;
% imagesc(uk);
% axis image;
% colormap(jet);
% colorbar;
% axis(nr * 2 + [0 nr 0 nr]);
% title('kx in spectral space after filter');


utmp(1).u = utmp(1).u*pix;

% % Display result after applying Hanning window
% figure;
% imagesc(utmp(1).u);
% axis image;
% colormap(jet);
% colorbar;
% clim([min_val, max_val]);
% axis(nr * 2 + [0 nr 0 nr]);
% title('utmp(1).u to convert stress');
%
% % Perform inverse Fourier transform
% utmp(1).u = real(ifft2(fft2(utmp(1).u)));
%
% % Display the final result after the Hanning window
% figure;
% imagesc(utmp(1).u);
% axis image;
% colormap(jet);
% colorbar;
% clim([min_val, max_val]);
% axis(nr * 2 + [0 nr 0 nr]);
% title('utmp(1).u after Hanning window');

% Pad and filter y displacements
utmp(2).u = [
    zeros(sz1 + 2 * padheight, padwidth), ...
    [zeros(padheight, sz2); d(i).dy_interp; zeros(padheight, sz2)], ...
    zeros(sz1 + 2 * padheight, padwidth)
    ];

% Apply Fourier transform and filtering for y displacement
utmp(2).u = real(ifft2(qmsk .* fft2(utmp(2).u)));
utmp(2).u = utmp(2).u*pix;

%% !!! Key step to convert displacements to stresses.

stmp = disp2stress(utmp,Q);

% Remove the padding
d(i).stress_x=stmp(1).s((nr2-nr)/2+1:((nr2-nr)/2+nr),(nr2-nr)/2+1:((nr2-nr)/2+nr));
d(i).stress_y=stmp(2).s((nr2-nr)/2+1:((nr2-nr)/2+nr),(nr2-nr)/2+1:((nr2-nr)/2+nr));

if length(stmp)== 3
    d(i).stress_z=stmp(3).s((nr2-nr)/2+1:((nr2-nr)/2+nr),(nr2-nr)/2+1:((nr2-nr)/2+nr));
end

d(i).ux=utmp(1).u((nr2-nr)/2+1:((nr2-nr)/2+nr),(nr2-nr)/2+1:((nr2-nr)/2+nr));
d(i).uy=utmp(2).u((nr2-nr)/2+1:((nr2-nr)/2+nr),(nr2-nr)/2+1:((nr2-nr)/2+nr));

% Calculate the strain energy density = u.sigma/2 - see Mertz et al. PRL
% 108, 198101 (2012).
d(i).sed = 1/2*d(i).stress_x.*d(i).ux + 1/2*d(i).stress_y.*d(i).uy;

figure;
imagesc(X(1,:)*3.1609, Y(:,1)*3.1609,d(2).ux*1e6);
axis image;
colormap(jet);
colorbar;
% Set axis limits
axis([0 880*5 0 660*5]);
title('$| \vec{u}_x |$','Interpreter','latex','FontSize',20);

% Set font properties for axes
set(gca, 'FontSize', 20, 'FontName', 'Times New Roman', 'TickLabelInterpreter', 'latex');
% Add axis labels
xlabel('x (\mum)', 'FontSize', 25, 'FontName', 'Times New Roman', 'LineWidth', 2);
ylabel('y (\mum)', 'FontSize', 25, 'FontName', 'Times New Roman', 'LineWidth', 2);
% Customize grid appearance
set(gca, 'GridLineStyle', ':', 'GridColor', 'r', 'GridAlpha', 0.5, 'LineWidth', 2);
% Add a label for stress component
text(4420, -160, '$u_x\,(\mu m)$', 'Interpreter', 'latex', 'FontSize', 22, 'LineWidth', 2, 'Rotation', 0);



% Create a figure for stress_x data visualization
figure;
% Display the stress_x data as an image
imagesc(X(1,:) * 3.1609, Y(:,1) * 3.1609, d(2).stress_x);
colorbar; % Add a color bar
colormap('jet'); % Set the colormap

% Set axis limits
axis([0 880*5 0 660*5]);

% Set font properties for axes
set(gca, 'FontSize', 20, 'FontName', 'Times New Roman', 'TickLabelInterpreter', 'latex');

% Set custom tick marks for x and y axes
xticks([0 1000 2000 3000 4000]);
yticks([0 1000 2000 3000]);

% Add axis labels
xlabel('x (\mum)', 'FontSize', 25, 'FontName', 'Times New Roman', 'LineWidth', 2);
ylabel('y (\mum)', 'FontSize', 25, 'FontName', 'Times New Roman', 'LineWidth', 2);

% Customize grid appearance
set(gca, 'GridLineStyle', ':', 'GridColor', 'r', 'GridAlpha', 0.5, 'LineWidth', 2);

% Add a label for stress component
text(4420, -160, '$\sigma_{zx}\,(Pa)$', 'Interpreter', 'latex', 'FontSize', 22, 'LineWidth', 2, 'Rotation', 0);


stt = sqrt(d(2).stress_x.^2 + d(2).stress_y.^2);

stt = stt(Y(:,1)>=0 & Y(:,1)<=1040,X(1,:)>0 & X(1,:)<=1392);

% Set the number of rows per group
num_rows_per_group = 6; % You can adjust this value as needed
num_points = size(stt,1); % Total number of points in the array

% Calculate the number of groups
num_groups = floor(num_points / num_rows_per_group); 

% Initialize arrays to store the mean values and center points of each group
group_means = zeros(num_groups, 1);
group_centers = zeros(num_groups, 1);

% Divide u into groups and calculate mean values
for k = 1:num_groups
    % Determine the indices for the current group
    start_index = (k-1) * num_rows_per_group + 1;
    end_index = start_index + num_rows_per_group - 1;

    % Calculate the mean value for the current group
    group_means(k) = mean(stt(start_index:end_index),"all");

    % Calculate the center point for the current group
    group_centers(k) = (start_index + end_index) / 2;
end

% Plot the scatter plot
figure;
scatter(group_centers*dx*3.1609, group_means, 'filled');
xlabel('$y [\mu m]$','Interpreter','latex','FontSize',18);
ylabel('$ \sigma $ [pa]','Interpreter','latex','FontSize',18);
title('stress along radius');
grid on;


