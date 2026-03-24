% Clear workspace and command window
clear all; clc;

%% ==================== INPUT PARAMETERS SETUP ====================
% Data paths
dataDir = 'F:\Che\T251205_TFM\T251205_BSM_Data';
cd(dataDir);
fileName = 'T251205_Dow_Ratio1_Phi60_Str9.csv';
expName = 'T251205_Dow_Ratio1_Phi60_Str9';

% TFM images directory
tfmImageDir = 'F:\Che\T251205_TFM\T251205_Dow_Ratio1_Phi60_Str9\Output\mappxPart4\';
outputVideoPath = 'F:\Che\T251205_TFM\T251205_Dow_Ratio1_Phi60_Str9\Output\mappxPart4\Part_stress_evolution.avi';

% TFM stress calculation directory
tfmStressDir = 'F:\Che\T251205_TFM\T251205_Dow_Ratio1_Phi60_Str9\Output\';

%% ==================== DATA PROCESSING ====================
% Read rheometer data
[intervals, time] = read_rheometer_data_general(fileName, expName, 'Time');
[~, strain] = read_rheometer_data_general(fileName, expName, 'Shear Strain');
[~, stress] = read_rheometer_data_general(fileName, expName, 'Shear Stress');

% Preprocess data
time = time(:)-5; stress = stress(:); intervals = intervals(:);
selectedIdx = find(intervals == 2 | intervals == 3); % Select specific strain interval
time = time(selectedIdx); 
stress = stress(selectedIdx);

%% ==================== TFM IMAGES AND STRESS LOADING ====================
% Load TFM images and calculate stress
startFrame = 6;
endFrame = 1003;
tfmImages = cell(1, endFrame-startFrame+1);
tfmStress = zeros(1, endFrame-startFrame+1);
tfmTime = zeros(1, endFrame-startFrame+1);
factor = 1;

% Define rectangular region for average stress calculation (in units)
rectX = [500 600]; % X-range [x_min, x_max]
rectY = [1000 1100]; % Y-range [y_min, y_max]
rectAvgStress = zeros(1, endFrame-startFrame+1); % To store average stress in rectangle

for k = startFrame:endFrame
    % Load TFM image
    tfmImages{k-startFrame+1} = imread(fullfile(tfmImageDir, [num2str(k), '.bmp']));
    
    % Calculate TFM stress
    data = load(fullfile(tfmStressDir, ['sx_', num2str(k), '.mat']));
    sx = data.sx;
    tfmStress(k-startFrame+1) = mean(sx(sx~=0));
    tfmTime(k-startFrame+1) = factor*(k-startFrame+1);
    
    % Load position data
    X = getfield(load(fullfile(tfmStressDir, ['X_', num2str(k), '.mat'])), ...
        char(fieldnames(load(fullfile(tfmStressDir, ['X_', num2str(k), '.mat'])))));
    Y = getfield(load(fullfile(tfmStressDir, ['Y_', num2str(k), '.mat'])), ...
        char(fieldnames(load(fullfile(tfmStressDir, ['Y_', num2str(k), '.mat'])))));
    
    % Convert rectangle coordinates from pixels to actual units if needed
    % (assuming the same scaling factor 3.1609 as in your original code)
    scaleFactor = 3.1609;
    rectX_scaled = rectX / scaleFactor;
    rectY_scaled = rectY / scaleFactor;
    X_scaled = X * 1;
    Y_scaled = Y * 1;
    % Find points within the rectangular region
    inRect = X_scaled >= rectX_scaled(1) & X_scaled <= rectX_scaled(2) & ...
             Y_scaled >= rectY_scaled(1) & Y_scaled <= rectY_scaled(2);
    
    % Calculate average stress in the rectangle
    rectSx = sx(inRect);
    rectAvgStress(k-startFrame+1) = mean(rectSx(rectSx~=0));
end

%% ==================== VIDEO GENERATION ====================
% Video settings
fps = 10; % Frame rate
videoWriter = VideoWriter(outputVideoPath);
videoWriter.FrameRate = fps;
open(videoWriter);

% Create figure with specified size
fig = figure('Units', 'normalized', 'Position', [0.1, 0.1, 0.8, 0.6]);

% Main loop for creating animation frames
for frameIdx = 1:length(time)
    clf; % Clear current figure
    
    % ===== Subplot 1: TFM Image with Rectangle =====
    subplot(1, 2, 1, 'Position', [0.05, 0.1, 0.4, 0.8]);
    if frameIdx <= length(tfmImages)
        imshow(tfmImages{frameIdx});
    else
        text(0.5, 0.5, 'No TFM Image', 'HorizontalAlignment', 'center');
    end
    
    % ===== Subplot 2: Stress-Time Curves =====
    subplot(1, 2, 2, 'Position', [0.55, 0.1, 0.4, 0.8]);
    hold on;
    
    % Plot rheometer historical data
    plot(time, stress, 'b-', 'LineWidth', 1.5);
    
    % Plot TFM historical data
    plot(tfmTime, tfmStress, 'r-', 'LineWidth', 1.5);
    
    % Plot rectangle average stress historical data
    plot(tfmTime, rectAvgStress, 'g-', 'LineWidth', 1.5);
    
    % Highlight current rheometer data point
    scatter(time(frameIdx), stress(frameIdx), ...
           'MarkerEdgeColor', [0.2 0.4 0.8], ...
           'MarkerFaceColor', [0.2 0.4 0.8], ...
           'SizeData', 60, ...
           'LineWidth', 1.5);
    
    % Highlight current TFM data point (if available)
    if frameIdx <= length(tfmStress)
        scatter(tfmTime(frameIdx), tfmStress(frameIdx), ...
               'MarkerEdgeColor', [0.8 0.2 0.2], ...
               'MarkerFaceColor', [0.8 0.2 0.2], ...
               'SizeData', 60, ...
               'LineWidth', 1.5);
    end
    
    % Highlight current rectangle average stress point (if available)
    if frameIdx <= length(rectAvgStress)
        scatter(tfmTime(frameIdx), rectAvgStress(frameIdx), ...
               'MarkerEdgeColor', [0.2 0.8 0.2], ...
               'MarkerFaceColor', [0.2 0.8 0.2], ...
               'SizeData', 60, ...
               'LineWidth', 1.5);
    end
    
    % Set axis properties
    set(gca, 'XScale', 'log', 'YScale', 'linear');
    xlabel('Time (s)', 'Interpreter', 'latex', 'FontSize', 12);
    ylabel('$\sigma(t)$ [Pa]', 'Interpreter', 'latex', 'FontSize', 12);
    % ylim([-1,1]);
    title('Stress Relaxation', 'FontSize', 12);
    legend({'Rheometer', 'TFM', 'Rect Avg Stress'}, 'Location', 'best');
    box on;
    
    % Consistent styling
    set(gca, 'FontName', 'Times New Roman', 'FontSize', 11, 'LineWidth', 1.5);
    
    % Capture frame and write to video
    currentFrame = getframe(gcf);
    writeVideo(videoWriter, currentFrame);
end

% Close video file
close(videoWriter);
disp('Video generation completed successfully!');