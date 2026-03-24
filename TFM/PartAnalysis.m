parpool ('local',32)
BaseDir = 'F:\Che\T251205_TFM\code\';
addpath(BaseDir);
tic

dir     = 'F:\Che\T251205_TFM\T251205_Dow_Ratio1_Phi60_Str9\Output\';
out_dir = 'F:\Che\T251205_TFM\T251205_Dow_Ratio1_Phi60_Str9\PartAnylysis\';
mkdir(out_dir);

st = 6;
ed = 1003;

% 创建数组来存储每个k的平均值

avg_values = zeros(1, ed); % 预分配数组

parfor k= st:ed
    %close all

    sx = getfield(load([dir,'sx_',num2str(k),'.mat']),char(fieldnames(load([dir,'sx_',num2str(k),'.mat']))));
    X = getfield(load([dir,'X_',num2str(k),'.mat']),char(fieldnames(load([dir,'X_',num2str(k),'.mat']))));
    Y = getfield(load([dir,'Y_',num2str(k),'.mat']),char(fieldnames(load([dir,'Y_',num2str(k),'.mat']))));

    % 统计指定区域内的sx平均值
    X_micron = X * 3.1609;
    Y_micron = Y * 3.1609;
    
    % 定义统计区域的边界（10-100微米）
    x_min = 500;
    x_max = 1500;
    y_min = 800;
    y_max = 1800;
    % 创建逻辑索引，选择10-100微米范围内的点
    mask = (X_micron >= x_min) & (X_micron <= x_max) & (Y_micron >= y_min) & (Y_micron <= y_max);
    
    % 计算选定区域内sx的平均值
    selected_sx = sx(mask);
    avg_sx = mean(selected_sx, 'all', 'omitnan');
    
    % 存储平均值
    avg_values(k) = avg_sx;
    
    % 可选：在命令行显示结果
    fprintf('k=%d: 区域(10-100μm)内sx平均值 = %.4f Pa\n', k, avg_sx);

    % 原有的绘图代码
    figure(1)
    imagesc(X(1,:)*3.1609,Y(:,1)*3.1609,sx);
    colorbar;
    colormap('jet');
    set(gca, 'clim', [1000 4000])
    axis([0 880*5 0 660*5]);
    set(gca,'fontsize',20,'Fontname','Times New Roman')
    a = findall(gcf,'type','axes');
    xticks([0 1000 2000 3000 4000]);
    yticks([0 1000 2000 3000]);
    colormap(jet);
    ylabel('y (\mum)','fontsize',25,'Fontname','Times New Roman','linewidth',2);
    xlabel('x (\mum)','fontsize',25,'Fontname','Times New Roman','linewidth',2);
    hold on
    
    % === 新增：绘制统计区域边框 ===
    % 绘制矩形边框
    rectangle('Position', [x_min, y_min, x_max-x_min, y_max-y_min], ...
              'EdgeColor', 'white', 'LineWidth', 3, 'LineStyle', '-');
    
    % 可选：添加区域标签
    text(x_min-5, y_max+20, '统计区域', ...
         'FontSize', 14, 'Color', 'white', 'FontWeight', 'bold', ...
         'HorizontalAlignment', 'right', 'BackgroundColor', 'black');
    
    % 可选：在矩形内部显示平均值
    text((x_min+x_max)/2, (y_min+y_max)/2, sprintf('Avg: %.1f Pa', avg_sx), ...
         'FontSize', 12, 'Color', 'white', 'FontWeight', 'bold', ...
         'HorizontalAlignment', 'center', 'BackgroundColor', 'black', ...
         'VerticalAlignment', 'middle');

    set(gca,'GridLineStyle',':','GridColor','r','GridAlpha',0.5,'linewidth',2)
    set(gca,'fontsize',22,'TickLabelInterpreter','latex')
    text(4420,-160,'$\rm\sigma_{zx}\,\rm(Pa)$','Interpreter','latex','FontSize',22,'linewidth',2,'rotation',0)

    fighandle=figure(1);
    set(fighandle,'position',[600,200,800,600]);
    saveas(gcf,[out_dir,num2str(k),'.bmp']);

end

% 保存平均值数据到文件
save([out_dir,'sx_averages.mat'], 'avg_values');

% 可选：创建平均值随k变化的图表
figure(2);

plot(st:ed, avg_values(st:ed), 'bo-', 'LineWidth', 2, 'MarkerSize', 6);
xlabel('k');
ylabel('平均应力 (Pa)');
grid on;
saveas(gcf, [out_dir, 'sx_averages_plot.fig']);


delete(gcp('nocreate'))
toc