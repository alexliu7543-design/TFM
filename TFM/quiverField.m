clc; clear all;
parpool('local', 8);
BaseDir = 'F:\Che\T251117_TFM\code\code\';
addpath(BaseDir);
tic

dir = 'F:\Che\T251117_TFM\T251117_Dow_Ratio0d8_Phi00_Relaxation_Strain5\Output\';
out_dir = 'F:\Che\T251117_TFM\T251117_Dow_Ratio0d8_Phi00_Relaxation_Strain5\Output\quiverField\';
mkdir(out_dir);

parfor k = 6:205
    % 加载数据
    ux = getfield(load([dir,'ux_',num2str(k),'.mat']),char(fieldnames(load([dir,'ux_',num2str(k),'.mat']))));

    uy = getfield(load([dir,'uy_',num2str(k),'.mat']),char(fieldnames(load([dir,'uy_',num2str(k),'.mat']))));

    X = getfield(load([dir,'X_',num2str(k),'.mat']),char(fieldnames(load([dir,'X_',num2str(k),'.mat']))));

    Y = getfield(load([dir,'Y_',num2str(k),'.mat']),char(fieldnames(load([dir,'Y_',num2str(k),'.mat']))));

    % 创建新的图形句柄
    fighandle = figure;
    quiver(X(1,:) * 3.1609, Y(:,1) * 3.1609, ux, uy);
    axis([0 880 * 5 0 660 * 5]);
    axis equal;
    set(gca, 'fontsize', 20, 'Fontname', 'Times New Roman');
    
    xticks([0 1000 2000 3000 4000]);
    yticks([0 1000 2000 3000]);
    ylabel('y (\mum)', 'fontsize', 25, 'Fontname', 'Times New Roman', 'linewidth', 2);
    xlabel('x (\mum)', 'fontsize', 25, 'Fontname', 'Times New Roman', 'linewidth', 2);
    
    set(gca, 'fontsize', 22, 'TickLabelInterpreter', 'latex');
    title('d $\vec{r}$ after interpolation', 'Interpreter', 'latex', 'FontSize', 22);
    
    % 保存图形并关闭
    saveas(fighandle, [out_dir, num2str(k), '.bmp']);
    close(fighandle);
end

delete(gcp('nocreate'));
toc