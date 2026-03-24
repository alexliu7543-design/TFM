obj = VideoReader('/home/hhuar/TFMM/stress/Project_2/Sylgard/CP50/60%_PVC/2X_300.wmv');%输入视频位置
numFrames = obj.NumberOfFrames;% 帧的总数
numzeros= 4;%图片name长度
nz = strcat('%0',num2str(numzeros),'d');
for k = 1:numFrames% 读取前15帧
    frame=read(obj,k);%读取第几帧
    id=sprintf(nz,k);
    imwrite(frame,strcat('/home/hhuar/TFMM/stress/Project_2/Sylgard/CP50/60%_PVC/',num2str(id),'.tiff'),'tiff');
end
