clc,clear;

dir         = 'F:\Che\T251216_TFM\Calibration\';
figure(1)
% for k = 1:40
% load([dir,'1 Pa\updated\','ux_',num2str(10+k),'.mat']);
% ux(ux==0)=NaN;
% y2(k)=mean(ux(:),'omitnan');
% x2(k)=k*3;
% end
% xx1(1)=0;
% yy1(1)=0;
% yy11(1)=0;
% xx1(2)=1;
% yy1(2)=mean(y2)*1000000;
% yy11(2)=std2(y2)*1000000;
% 


for k = 30:80
load([dir,'T251216_Calibration_100Pa\Output\','ux_',num2str(k),'.mat']);
ux(ux==0)=NaN;
y3(k)=mean(ux(:),'omitnan');
x3(k)=k;
end
xx1(1)= 100;
yy1(1)=mean(y3)*1000000;
yy11(1)=std2(y3)*1000000;

for k = 30:80
load([dir,'T251216_Calibration_150Pa\Output\','ux_',num2str(k),'.mat']);
ux(ux==0)=NaN;
y4(k)=mean(ux(:),'omitnan');
x4(k)=k;
end
xx1(2)= 150;
yy1(2)=mean(y4)*1000000;
yy11(2)=std2(y4)*1000000;


for k = 30:80
load([dir,'T251216_Calibration_200Pa\Output\','ux_',num2str(k),'.mat']);
ux(ux==0)=NaN;
y5(k)=mean(ux(:),'omitnan');
x5(k)=k;
end
xx1(3)= 200;
yy1(3)=mean(y5)*1000000;
yy11(3)=std2(y5)*1000000;


for k = 30:80
load([dir,'T251216_Calibration_250Pa\Output\','ux_',num2str(k),'.mat']);
ux(ux==0)=NaN;
y6(k)=mean(ux(:),'omitnan');
x6(k)=k;
end
xx1(4)= 250;
yy1(4)=mean(y6)*1000000;
yy11(4)=std2(y6)*1000000;



% 
% %plot(x1,y1*1000000,'co','linewidth',1.2); hold on;
% plot(x2,y2*1000000,'o','Color',[235 0 139]/255,'linewidth',1.2); hold on;
plot(x5,y3*1000000,'d','Color',[255 170 0]/255,'linewidth',1.2); hold on;
plot(x5,y4*1000000,'^','Color',[0 183 206]/255,'linewidth',1.2); hold on;
plot(x5,y5*1000000,'s','Color',[0 0 255]/255,'linewidth',1.2); hold on;
plot(x5,y6*1000000,'p','Color',[115 0 230]/255,'linewidth',1.2); hold on;

set(gca,'GridLineStyle',':','GridColor','r','GridAlpha',0.5,'linewidth',2)
set(gca,'fontsize',18,'Fontname','Georgia','TickLabelInterpreter','latex')
ylabel('$\rm u_{x}$($\rm\mu$m)','Interpreter','latex','Fontname','Georgia','fontsize',22,'linewidth',4);
%ylabel('$\langle\rm\sigma_x\rangle\,\rm(Pa)$','Interpreter','latex','FontSize',22,'Fontname','Times New Roman','linewidth',2);
%xlabel('$\tau_{a}$(Pa)','Interpreter','latex','Fontname','Georgia','fontsize',22,'linewidth',4);
xlabel('$\rm{t}$(s)','Interpreter','latex','Fontname','Georgia','fontsize',22,'linewidth',4);
% set(gca,'YTick',[0 1 2 3 4]);
% axis([0. 85 -0 0.7])
%set(gca,'YTick',[0 0.2 0.4 0.6 0.8 1]);
axis([0. 90 0.0 5])
fighandle=figure(1);
set(fighandle,'position',[500,0,540,360]);


figure(3)

a1=polyfit(yy1,xx1,1);%1阶多项式最小二乘拟合

plot(yy1(1).*[a1(1)],xx1(1),'o','Color',[255 170 0]/255,'linewidth',1.2); hold on;
plot(yy1(2).*[a1(1)],xx1(2),'o','Color',[0 183 206]/255,'linewidth',1.2); hold on;
plot(yy1(3).*[a1(1)],xx1(3),'o','Color',[0 0 255]/255,'linewidth',1.2); hold on;
plot(yy1(4).*[a1(1)],xx1(4),'o','Color',[115 0 230]/255,'linewidth',1.2); hold on;

x2=(min(yy1):0.1:max(yy1));
yyy1=polyval(a1,x2);
plot(x2.*[a1(1)],yyy1,'k--','linewidth',1.2,'MarkerSize',6,'MarkerEdgeColor','r','MarkerFaceColor',[1 1 1]); 

set(gca,'GridLineStyle',':','GridColor','r','GridAlpha',0.5,'linewidth',2)
set(gca,'fontsize',18,'Fontname','Georgia','TickLabelInterpreter','latex')
xlabel('$\frac{G}{h}\Delta x,\rm(Pa)$','Interpreter','latex','FontSize',20,'Fontname','Times New Roman','linewidth',2);
ylabel('$\tau_{a}$(Pa)','Interpreter','latex','Fontname','Georgia','fontsize',20,'linewidth',2);

save(fullfile(dir,'a1.mat'), 'a1');


% figure(2)
% 
% % errorbar(xx1,yy1./[0.000967586],yy11./[0.000967586],'-','linewidth',1.2);
% % % set(gca,'XScale','log');
% % % set(gca,'YScale','log');
% % hold on;
% 
% a1=polyfit(xx1,yy1,1);%1阶多项式最小二乘拟合
% 
% % errorbar(xx1(2),yy1(2)./[0.0928],yy11(2)./[0.0928],'o','Color',[235 0 139]/255,'linewidth',1.2); hold on;
% errorbar(xx1(1),yy1(1)./[a1(1)],yy11(1)./[a1(1)],'o','Color',[255 170 0]/255,'linewidth',1.2); hold on;
% errorbar(xx1(2),yy1(2)./[a1(1)],yy11(2)./[a1(1)],'o','Color',[0 183 206]/255,'linewidth',1.2); hold on;
% %plot(x2,y5*1000000,'mo','linewidth',1.2); hold on;
% errorbar(xx1(3),yy1(3)./[a1(1)],yy11(3)./[a1(1)],'o','Color',[0 0 255]/255,'linewidth',1.2); hold on;
% errorbar(xx1(4),yy1(4)./[a1(1)],yy11(4)./[a1(1)],'o','Color',[115 0 230]/255,'linewidth',1.2); hold on;
% 
% 
% 
% x2=(0.1:1:80);
% yyy1=polyval(a1,x2);
% plot(x2,yyy1./[a1(1)],'k--','linewidth',1.2,'MarkerSize',6,'MarkerEdgeColor','r','MarkerFaceColor',[1 1 1]); 
% % % hold on
% % % % plot(x2(1:end),yyy1(1:end),'m--','linewidth',1.2,'MarkerSize',7,'MarkerEdgeColor','m','MarkerFaceColor',[1 1 1]); 
% % % %ylabel('\tau_{fit} \rm{(Pa)}','fontsize',24,'Fontname','Times New Roman','linewidth',4);
% % % % ylabel('u (\rm\mum)','fontsize',20,'Fontname','Georgia','linewidth',4);
% % % % xlabel('\tau_a  \rm{(Pa)}','fontsize',20,'Fontname','Georgia','linewidth',4);
% 
% set(gca,'GridLineStyle',':','GridColor','r','GridAlpha',0.5,'linewidth',2)
% set(gca,'fontsize',18,'Fontname','Georgia','TickLabelInterpreter','latex')
% %ylabel('$u_{x}$($\mu$m)','Interpreter','latex','Fontname','Georgia','fontsize',24,'linewidth',4);
% ylabel('$\langle\rm\sigma_x\rangle\,\rm(Pa)$','Interpreter','latex','FontSize',20,'Fontname','Times New Roman','linewidth',2);
% xlabel('$\tau_{a}$(Pa)','Interpreter','latex','Fontname','Georgia','fontsize',20,'linewidth',2);
% 

% text('Interpreter','latex','String','$\rm G = 101\,kPa$','Position',[160 390],'FontSize',18,'color','r');
% %xlabel('$\rm{t}$(s)','Interpreter','latex','Fontname','Georgia','fontsize',22,'linewidth',4);
% set(gca,'YTick',[0 20 40 60 80]);
% set(gca,'XTick',[0 20 40 60 80]);
% %axis([0. 150 0 1])
% %set(gca,'YTick',[0 0.2 0.4 0.6 0.8 1]);
% 
% axis([0. 90 0 90])
% hold on
% fighandle=figure(2);
% set(fighandle,'position',[500,0,540,360]);







% clc,clear;
% dir         = 'E:\BSM\PS\sylgard 75\calibration No.2\';
% figure(3)
% for k = 1:40
% load([dir,'1 Pa\updated\','sx_',num2str(10+k),'.mat']);
% sx(sx==0)=NaN;
% y2(k)=mean(sx(:),'omitnan');
% x2(k)=k*3;
% end
% xx1(1)=0;
% yy1(1)=0;
% yy11(1)=0;
% xx1(2)=1;
% yy1(2)=mean(y2)*1000000;
% yy11(2)=std2(y2)*1000000;
% 
% for k = 1:40
% load([dir,'2 Pa\updated\','sx_',num2str(10+k),'.mat']);
% sx(sx==0)=NaN;
% y3(k)=mean(sx(:),'omitnan');
% x3(k)=k*3;
% end
% xx1(3)=2;
% yy1(3)=mean(y3)*1000000;
% yy11(3)=std2(y3)*1000000;
% 
% for k = 1:40
% load([dir,'5 Pa\updated\','sx_',num2str(10+k),'.mat']);
% sx(sx==0)=NaN;
% y4(k)=mean(sx(:),'omitnan');
% x4(k)=k*3;
% end
% xx1(4)=5;
% yy1(4)=mean(y4)*1000000;
% yy11(4)=std2(y4)*1000000;
% 
% 
% for k = 1:40
% load([dir,'10 Pa\updated\','sx_',num2str(10+k),'.mat']);
% sx(sx==0)=NaN;
% y5(k)=mean(sx(:),'omitnan');
% x5(k)=k*3;
% end
% xx1(5)=10;
% yy1(5)=mean(y5)*1000000;
% yy11(5)=std2(y5)*1000000;
% 
% 
% for k = 1:40
% load([dir,'20 Pa\updated\','sx_',num2str(10+k),'.mat']);
% sx(sx==0)=NaN;
% y6(k)=mean(sx(:),'omitnan');
% x6(k)=k*3;
% end
% xx1(6)=20;
% yy1(6)=mean(y6)*1000000;
% yy11(6)=std2(y6)*1000000;
% 
% 
% 
% for k = 1:40
% load([dir,'50 Pa\updated\','sx_',num2str(10+k),'.mat']);
% sx(sx==0)=NaN;
% y7(k)=mean(sx(:),'omitnan');
% x7(k)=k*3;
% end
% xx1(7)=50;
% yy1(7)=mean(y7)*1.000000;
% yy11(7)=std2(y7)*1.000000;
% 
% 
% % 
% %plot(x1,y1*1000000,'co','linewidth',1.2); hold on;
% plot(x2,y2*1.000000,'o','Color',[235 0 139]/255,'linewidth',1.2); hold on;
% plot(x2,y3*1.000000,'d','Color',[255 170 0]/255,'linewidth',1.2); hold on;
% plot(x2,y4*1.000000,'^','Color',[0 183 206]/255,'linewidth',1.2); hold on;
% plot(x2,y5*1.000000,'s','Color',[0 0 255]/255,'linewidth',1.2); hold on;
% plot(x2,y6*1.000000,'p','Color',[115 0 230]/255,'linewidth',1.2); hold on;
% plot(x2,y7*1.000000,'>','Color','k','linewidth',1.2); hold on;
% 
% set(gca,'GridLineStyle',':','GridColor','r','GridAlpha',0.5,'linewidth',2)
% set(gca,'fontsize',18,'Fontname','Georgia','TickLabelInterpreter','latex')
% ylabel('$\rm u_{x}$($\rm\mu$m)','Interpreter','latex','Fontname','Georgia','fontsize',22,'linewidth',4);
% %ylabel('$\langle\rm\sigma_x\rangle\,\rm(Pa)$','Interpreter','latex','FontSize',22,'Fontname','Times New Roman','linewidth',2);
% %xlabel('$\tau_{a}$(Pa)','Interpreter','latex','Fontname','Georgia','fontsize',22,'linewidth',4);
% xlabel('$\rm{t}$(s)','Interpreter','latex','Fontname','Georgia','fontsize',22,'linewidth',4);
% % set(gca,'YTick',[0 1 2 3 4]);
% % axis([0. 85 -0 0.7])
% %set(gca,'YTick',[0 0.2 0.4 0.6 0.8 1]);
% axis([0. 120 0.0 inf])
% fighandle=figure(3);
% set(fighandle,'position',[500,0,540,360]);