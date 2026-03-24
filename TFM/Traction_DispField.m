%% This code is for tracking beads to get the displacement field

clear all;
tic;
%% Load files
BaseDir = 'F:\Che\T251205_TFM\code\code\';
addpath(BaseDir);

RefDir = 'F:\Che\T251216_TFM\T251216_Dow_Ratio1d5_Phi63_400Pa\';
addpath(RefDir);
imageNamesRef = dir(fullfile(RefDir,'*.bmp'));
imageNamesRef = {imageNamesRef.name}';

workingDir = RefDir;

%workingDir = 'E:\CompositeTFM\Sept29\Calibration\100Pa\';

Out_Dir = 'F:\Che\T251216_TFM\T251216_Dow_Ratio1d5_Phi63_400Pa\Output\';
mkdir(Out_Dir);
addpath(workingDir);

imageNames = dir(fullfile(workingDir,'*.bmp'));
imageNames = {imageNames.name}';

%% Set Parameters
th = 0.01; % Threshold to recognize beads
lnoise = 0.8; % Noise level for bandpass filtering
lobject = 5; % Object size for bandpass filtering
pksz = 4; % Size for finding  peak points
ctsz = 3; % Size for calculating the centroid of brightness
maxdisp = 7; % Maximum displacement (pixels)

ref = 3;
draw = 1;
file_name = [RefDir imageNamesRef{ref}];
time = 1;
[cnt1,im1] = identify_single_image(file_name,draw,th,time,lnoise,lobject,pksz,ctsz); %particle:cnt1(1)~x,cnt1(2)~y,im1~gray intensity
% delete(gcp("nocreate"))
parpool('local',32);
draw = 2;
parfor kk =  6:105
    time = 2;
    file_name = [workingDir imageNames{kk}];
    [cnt2,im2] = identify_single_image(file_name,draw,th,time,lnoise,lobject,pksz,ctsz);

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
        hold on;
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

                %          arrow1(y1,x1,y2,x2,30/180*pi,0.8,'k',3);
                %quiver(p1(:,1),p1(:,2),dis(:,1),dis(:,2),0,'r');

            end
        end
    end
    d = struct();
    d(1).r = p1;
    d(2).r = p2;
    d(1).dr = zeros(length(p1),2);
    d(2).dr = dis;

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
    disp(numel(find(d(1).r(:,1)==0)));

    parsave([Out_Dir,'test_d_',num2str(kk),'.mat'],d);

    close all
end

delete(gcp('nocreate'))
%exit;
toc
