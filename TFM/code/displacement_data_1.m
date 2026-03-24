%function test_xulab_tracking()
parpool ('local',11)
th = 0.005;
draw = 1;

%dirr         = '/home/hhuar/TFMM/stress/TFM to study the confined suspensions/gelest 11_4 800 rpm preswell/oil calibration/10 Pa/list/';


dir         = '/home/hhuar/BSM/stress/Project_2/Sylgard/PP43/20221210/PVC/0.64 R/80 Pa/list/';
dir_pro     = '/home/hhuar/BSM/stress/Project_2/Sylgard/PP43/20221210/PVC/0.64 R/80 Pa/disp/';


%file_name = [dir,'00008.bmp'];
file_name = [dir,'00140.bmp'];
time = 1;
[cnt1,im1] = identify_single_image(file_name,draw,th,time);

parfor k=141:2450
close all;
set(0,'DefaultFigureVisible', 'off')

time = 2;
a=num2str(k,'%05d');
file_name = [dir,a,'.bmp'];
[cnt2,im2] = identify_single_image(file_name,draw,th,time);

disp(size(cnt1));
disp(size(cnt2));
Pos_list = [cnt1 
    cnt2];

%% Plot the two images to identify the rough displacement
 figure,imagesc(im1-im2);
axis image;
%colormap(jet);

track_result1 = track(Pos_list,50);

track_result = remove_outliers_RAFT (track_result1)

num_tracked = max(track_result(:,4));



%dis=zeros(num_tracked,2);
%p1 = zeros(num_tracked,2);
%p2 = zeros(num_tracked,2);
dis=zeros(1,2);
p1 = zeros(1,2);
p2 = zeros(1,2);
count = 0;

for i = 2:num_tracked
    hold on;
    temp = find(track_result(:,4) == i);
    if numel(temp) == 2
        
        x1 = track_result(temp(1),1);
        y1 = track_result(temp(1),2);
        x2 = track_result(temp(2),1);
        y2 = track_result(temp(2),2);
        
        if x1~=0 && y1~=0 && x2~=0 && y2~=0
            
        count = count+1;
        dis(count,1) =x2-x1;
        dis(count,2) = y2-y1;
        
        p1(count,1) = x1;
        p1(count,2) = y1;
        
        p2(count,1) = x2;
        p2(count,2) = y2;
        
%        arrow1(y1,x1,y2,x2,30/180*pi,0.8,'k',3);
quiver(p1(:,1),p1(:,2),dis(:,1),dis(:,2),0,'r');
        
        end
    end
end
d = struct();
d(1).r = p1;
d(2).r = p2;
d(1).dr = zeros(length(p1),2);
d(2).dr = dis;

disp(numel(find(d(1).r(:,1)==0)));

parsave([dir_pro,'test_d_',num2str(k),'.mat'],d);
%data1= dlmread(['E:\020190821\0819前飞实验1\pro\pro\QF1mic_A10H10_deltalvbo',num2str(rpmR(i)),'.txt'],',',0,0);
end

%% Track particle
delete(gcp('nocreate'))
exit;
