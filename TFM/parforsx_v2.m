parpool ('local',8)
BaseDir = 'D:\OneDrive - HKUST Connect\experiment\T240930_BSM\code\code\';
addpath(BaseDir);
tic

dir     = 'D:\OneDrive - HKUST Connect\experiment\T250608_LittleGelTest\T250608_Relaxation_Strain5\Output\';
out_dir = 'D:\OneDrive - HKUST Connect\experiment\T250608_LittleGelTest\T250608_Relaxation_Strain5\Output3\mappx\';
mkdir(out_dir);

parfor k= 6:100


    sx = getfield(load([dir,'sx_',num2str(k),'.mat']),char(fieldnames(load([dir,'sx_',num2str(k),'.mat']))));

    X = getfield(load([dir,'X_',num2str(k),'.mat']),char(fieldnames(load([dir,'X_',num2str(k),'.mat']))));

    Y = getfield(load([dir,'Y_',num2str(k),'.mat']),char(fieldnames(load([dir,'Y_',num2str(k),'.mat']))));

    figure(1)
    imagesc(X(1,:)*3.1609,Y(:,1)*3.1609,sx);
    colorbar;

    colormap('jet');
    set(gca, 'clim', [-20 160])

    axis([0 880*5 0 660*5]);
    set(gca,'fontsize',20,'Fontname','Times New Roman')
    a = findall(gcf,'type','axes');

    hold on
    set(gca,'GridLineStyle',':','GridColor','r','GridAlpha',0.5,'linewidth',2)
    set(gca,'fontsize',22,'TickLabelInterpreter','latex')

    text(4420,-160,'$\rm\sigma_{zx}\,\rm(Pa)$','Interpreter','latex','FontSize',22,'linewidth',2,'rotation',0)
    set(gca, 'XTick', [], 'YTick', []);
    fighandle=figure(1);

    set(fighandle,'position',[600,200,800,600]);
    % 修改为1000微米比例尺
    bar_length = 1000;  % 1000微米
    bar_x_start = 200;  % 距离右边界100微米（转换为像素单位）
    bar_y_pos = 100;  % 距离底部50微米（转换为像素单位）
    line([bar_x_start, bar_x_start + bar_length], [bar_y_pos, bar_y_pos], ...
        'LineWidth', 4, 'Color', 'white');
    text(bar_x_start + bar_length/2, bar_y_pos + 80, '1000 μm', ...
        'Color', 'white', 'FontSize', 18, 'HorizontalAlignment', 'center');
    saveas(gcf,[out_dir,num2str(k),'.svg']);

end
delete(gcp('nocreate'))
%exit;


toc
