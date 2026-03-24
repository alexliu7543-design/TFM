% Clear workspace and command window
clear all; clc;

%% ==================== INPUT PARAMETERS SETUP ====================
% Data paths
dataDir = 'F:\Che\T251205_TFM\T251205_BSM_Data';
cd(dataDir);
fileName = 'T251205_Dow_Ratio1_Phi60_Str9.csv';
expName = 'T251205_Dow_Ratio1_Phi60_Str9';

% TFM images directory
tfmPartImageDir = 'F:\Che\T251205_TFM\T251205_Dow_Ratio1_Phi60_Str9\Output\Part_mappx1\';
outputVideoPath = 'F:\Che\T251205_TFM\T251205_Dow_Ratio1_Phi60_Str9\Output\Part_mappx1\Part_stress_evolution1.avi';

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
rectX = [100 200]; % X-range [x_min, x_max]
rectY = [100 200]; % Y-range [y_min, y_max]
rectAvgStress = zeros(1, endFrame-startFrame+1); % To store average stress in rectangle

for k = startFrame:endFrame
    % Load position data and stress data
    X = getfield(load(fullfile(tfmStressDir, ['X_', num2str(k), '.mat'])), ...
        char(fieldnames(load(fullfile(tfmStressDir, ['X_', num2str(k), '.mat'])))));
    Y = getfield(load(fullfile(tfmStressDir, ['Y_', num2str(k), '.mat'])), ...
        char(fieldnames(load(fullfile(tfmStressDir, ['Y_', num2str(k), '.mat'])))));
    sx = getfield(load([dir,'sx_',num2str(k),'.mat']),char(fieldnames(load([dir,'sx_',num2str(k),'.mat']))));
     figure(1)

    % Convert rectangle coordinates from pixels to actual units if needed
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
    
    
    %%draw image with rectangle
    imagesc(X(1,:)*3.1609,Y(:,1)*3.1609,sx);
    hold on;
    rectangle('Position', [rectX(1), rectY(1), rectX(2)-rectX(1), rectY(2)-rectY(1)]*nor_Factor, ...
                 'EdgeColor', 'g', 'LineWidth', 2, 'LineStyle', '--');
    title(sprintf('TFM Image (t=%.2f s)', time(frameIdx)), 'FontSize', 10)
    colorbar;
    colormap('jet');
    set(gca, 'clim', [1000 4000])
    axis([0 880*5 0 660*5]);
    set(gca,'fontsize',20,'Fontname','Times New Roman')
    a = findall(gcf,'type','axes');
    xticks([0 1000 2000 3000 4000]);
    yticks([0 1000 2000 3000]);
    %hc=colorbar;
    colormap(jet);
    ylabel('y (\mum)','fontsize',25,'Fontname','Times New Roman','linewidth',2);
    xlabel('x (\mum)','fontsize',25,'Fontname','Times New Roman','linewidth',2);
    set(gca,'GridLineStyle',':','GridColor','r','GridAlpha',0.5,'linewidth',2)
    set(gca,'fontsize',22,'TickLabelInterpreter','latex')
    text(4420,-160,'$\rm\sigma_{zx}\,\rm(Pa)$','Interpreter','latex','FontSize',22,'linewidth',2,'rotation',0)

    fighandle=figure(1);
    set(fighandle,'position',[600,200,800,600]);

    saveas(gcf,[out_dir,num2str(k),'.bmp']);


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
        imgx_range = xlim;
        img_width = imgx_range(2)-imgx_range(1);
        imgy_range = ylim;
        img_height = imgy_range(2)-imgy_range(1);
        hold on;
        % Draw rectangle on the image
        nor_Factor = img_width/4400;
        
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







parpool ('local',32)
BaseDir = 'F:\Che\T251117_TFM\code\code\';
addpath(BaseDir);
tic

dir     = 'F:\Che\T251205_TFM\T251205_Dow_Ratio1_Phi60_Str9\Output\';
out_dir = 'F:\Che\T251205_TFM\T251205_Dow_Ratio1_Phi60_Str9\Output\mappx\';
mkdir(out_dir);
parfor k= 6:1004

    sx = getfield(load([dir,'sx_',num2str(k),'.mat']),char(fieldnames(load([dir,'sx_',num2str(k),'.mat']))));

    X = getfield(load([dir,'X_',num2str(k),'.mat']),char(fieldnames(load([dir,'X_',num2str(k),'.mat']))));

    Y = getfield(load([dir,'Y_',num2str(k),'.mat']),char(fieldnames(load([dir,'Y_',num2str(k),'.mat']))));

    %set(0,'DefaultFigureVisible', 'off')
   

end
delete(gcp('nocreate'))

toc
