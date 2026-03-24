clear; clc;

%% Path settings
Dir = 'D:\OneDrive - HKUST Connect\experiment\T250606_WallSlipTest\T250606_Relaxation_Strain2\Output\';

% Load data
data = load(fullfile(Dir, 'sx_6.mat'));
sx = data.sx;  

%% Step 1: Remove the outer zero-stress region
% Find the boundaries of non-zero data
[row, col] = find(sx ~= 0);
min_row = min(row);
max_row = max(row);
min_col = min(col);
max_col = max(col);

% Crop the meaningful stress region
meaningful_sx = sx(min_row:max_row, min_col:max_col);

%% Step 2: Calculate row-wise averages in bins of N/40
N = size(meaningful_sx, 1);  % Total number of rows
bin_size = round(N/40);       % Size of each bin
num_bins = floor(N/bin_size); % Number of complete bins

% Initialize arrays for storing results
row_averages = zeros(num_bins, 1);
row_positions = zeros(num_bins, 1); % In mm (3.3mm per row)

% Calculate averages for complete bins
for i = 1:num_bins
    start_row = (i-1)*bin_size + 1;
    end_row = i*bin_size;
    
    % Extract the bin
    current_bin = meaningful_sx(start_row:end_row, :);
    
    % Calculate average stress (ignoring zeros if needed)
    row_averages(i) = mean(current_bin(current_bin ~= 0));
    
    % Calculate position (middle of the bin in mm)
    row_positions(i) = (start_row + end_row)/2 * 3.3; % 3.3mm per row
end

% Handle remaining rows if any
remaining_rows = N - num_bins*bin_size;
if remaining_rows > 0
    start_row = num_bins*bin_size + 1;
    end_row = N;
    
    current_bin = meaningful_sx(start_row:end_row, :);
    row_averages(end+1) = mean(current_bin(current_bin ~= 0));
    row_positions(end+1) = (start_row + end_row)/2 * 3.3;
end

%% Step 3: Analyze linear relationship
% Remove any NaN values (from bins with all zeros)
valid_idx = ~isnan(row_averages);
row_averages = row_averages(valid_idx);
row_positions = row_positions(valid_idx);

% Perform linear regression
X = [ones(length(row_positions), 1), row_positions(:)]; % Add constant term
b = X \ row_averages; % Regression coefficients

% Calculate R-squared
y_pred = X * b;
SS_tot = sum((row_averages - mean(row_averages)).^2);
SS_res = sum((row_averages - y_pred).^2);
R_squared = 1 - (SS_res / SS_tot);

%% Display results
fprintf('Linear regression results:\n');
fprintf('Slope: %.4f stress units/mm\n', b(2));
fprintf('Intercept: %.4f stress units\n', b(1));
fprintf('R-squared: %.4f\n', R_squared);

%% Plot results
figure;
plot(row_positions, row_averages, 'bo', 'DisplayName', 'Data');
hold on;
plot(row_positions, y_pred, 'r-', 'DisplayName', sprintf('Linear fit: y = %.3f*x + %.3f\nR² = %.3f', b(2), b(1), R_squared));
xlabel('Distance from reference (mm)');
ylabel('Average stress');
title('Stress vs Distance');
legend('Location', 'best');
grid on;