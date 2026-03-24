parpool ('local',32)
BaseDir = 'F:\Che\T251117_TFM\code\code\';
addpath(BaseDir);
tic

dir     = 'F:\Che\T251216_TFM\T251216_Dow_Ratio1d5_Phi63_400Pa\Output\';
out_dir = 'F:\Che\T251216_TFM\T251216_Dow_Ratio1d5_Phi63_400Pa\Output\mappx\';
mkdir(out_dir);
% set(0,'DefaultFigureVisible', 'off')
parfor k= 6:105
    %close all

    %load([dir,'updated/','sx_',num2str(k),'.mat']);
    %load([dir,'updated/','X_',num2str(k),'.mat']);
    %load([dir,'updated/','Y_',num2str(k),'.mat']);

    sx = getfield(load([dir,'sx_',num2str(k),'.mat']),char(fieldnames(load([dir,'sx_',num2str(k),'.mat']))));

    X = getfield(load([dir,'X_',num2str(k),'.mat']),char(fieldnames(load([dir,'X_',num2str(k),'.mat']))));

    Y = getfield(load([dir,'Y_',num2str(k),'.mat']),char(fieldnames(load([dir,'Y_',num2str(k),'.mat']))));

    %set(0,'DefaultFigureVisible', 'off')
    figure(1)
    imagesc(X(1,:)*3.1609,Y(:,1)*3.1609,sx);
    colorbar;
    % bwr = @(n)interp1([1 2 3], [40 120 181; 255 255 255; 200 36 35]./255, linspace(1, 3, n), 'linear');
    % colormap(bwr(64));
    colormap('jet');
    set(gca, 'clim', [0 400])
    %clim([-300 300])
    axis([0 880*5 0 660*5]);
    %axis equal;
    %  caxis([0 15])
    % text(1500,525,'\it\tau\rm{ (Pa)}','Fontname','Times New Roman','ROtation',0,'fontsize',22)
    %axis([0 1392 0 1040]);
    set(gca,'fontsize',20,'Fontname','Times New Roman')
    a = findall(gcf,'type','axes')
    %     set(a,'XTickLabel',[])
    %     set(a,'YTickLabel',[])
    xticks([0 1000 2000 3000 4000]);
    yticks([0 1000 2000 3000]);
    %hc=colorbar;
    colormap(jet);
    ylabel('y (\mum)','fontsize',25,'Fontname','Times New Roman','linewidth',2);
    xlabel('x (\mum)','fontsize',25,'Fontname','Times New Roman','linewidth',2);
    %   colorbar off;
    %set(hc,'YTick',-20:5:80);
    % set(hc,'YTick',-200:200:1000);
    %     set(hc,'YTickLabel',{'-10000','-5000','0','5000','10000'}) %具体刻度赋值
    hold on
    set(gca,'GridLineStyle',':','GridColor','r','GridAlpha',0.5,'linewidth',2)
    set(gca,'fontsize',22,'TickLabelInterpreter','latex')
    %text(100,200,'$\rm t = 91.3\,s$','Interpreter','latex','FontSize',24,'color','w','linewidth',2,'rotation',0)
    text(4420,-160,'$\rm\sigma_{zx}\,\rm(Pa)$','Interpreter','latex','FontSize',22,'linewidth',2,'rotation',0)

    fighandle=figure(1);
    % set(fighandle,'position',[500,0,1000,400]);
    set(fighandle,'position',[600,200,800,600]);

    saveas(gcf,[out_dir,num2str(k),'.bmp']);

end
delete(gcp('nocreate'))
%exit;


toc
