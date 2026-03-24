route='D:\OneDrive - HKUST Connect\experiment\T250606_WallSlipTest\T250606_Relaxation_Strain2\Output\mappx\';%基本路径
name='Bolt';%
%d=dir(['D:\TFM\TFMM\2.5*.jpg']);%.jpg格式

WriterObj=VideoWriter('D:\OneDrive - HKUST Connect\experiment\T250606_WallSlipTest\T250606_Relaxation_Strain2\Output\mappx.avi');%待合成的视频(不仅限于avi格式)的文件路径  
fps=17;
WriterObj.FrameRate=fps;
open(WriterObj);
% n_frames=numel(d);% n_frames表示图像帧的总数
for ii=5:105
  frame=imread([route, num2str(ii),'.bmp']);%读取图像，放在变量frame中
% filename = ['C001H001S00010',a,'.JPG'];
% % frame=imread(['C:\D disk\matlab\images\shear rate 1 third\Default\','img_channel000_position000_time000000',num2str(a),'_z000.tif']); 
% % im = imread(['C1S000100000',num2str(i),'.jpg'],',',0,0);
% writeVideo(WriterObj,frame);%将frame放到变量WriterObj中
% im = imread(['C1S000100000',num2str(i),'.jpg'],',',0,0);
% a=num2str(i,'%04d');
% frame=imread(['C:\D disk\matlab\Rheometer projects - Copy\TFM2\imgs 5\2.5\',a,'.bmp']);
writeVideo(WriterObj,frame);%将frame放到变量WriterObj中
%%为每一帧图像编号
% imshow(frame);
% text(5,18,num2str(i),'color','y','Fontweight','bold','FontSize',18);
% writeVideo(WriterObj,frame2im(getframe(gcf)));
end
close(WriterObj);
%         clear
%         clc
%         writerObj = VideoWriter('peaks.avi');
%         writerObj.FrameRate = 30;
%         open(writerObj);
%         Z = peaks;
%         surf(Z);
%         axis tight                              
%         set(gca,'nextplot','replacechildren');  
%         set(gcf,'Renderer','zbuffer');        
%         for k = 1:20
%            surf(sin(2*pi*k/20)*Z)
%            pause(1)
%            frame = getframe;
%            writeVideo(writerObj,frame.cdata);
%         end
%         close(writerObj);