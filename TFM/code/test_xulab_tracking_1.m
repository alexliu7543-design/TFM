%function test_xulab_tracking()

th = 0.2;
draw = 1;
file_name = '101.bmp';
time = 1;
[cnt1,im1] = identify_single_image(file_name,draw,th,time);

time = 2;
file_name = '102.bmp';
[cnt2,im2] = identify_single_image(file_name,draw,th,time);

disp(size(cnt1));
disp(size(cnt2));
Pos_list = [cnt1 
    cnt2];



%% Plot the two images to identify the rough displacement
figure,imagesc(im1-im2);
axis image;
%colormap(jet);

track_result = track(Pos_list,10); %why is it 10

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
        
%          arrow1(y1,x1,y2,x2,30/180*pi,0.8,'k',3);
quiver(p1(:,1),p1(:,2),dis(:,1),dis(:,2),0,'r');
        
        end
    end
end

d(1).r = p1;
d(2).r = p2;
d(1).dr = zeros(length(p1),2);
d(2).dr = dis;

disp(numel(find(d(1).r(:,1)==0)));

save('test_d.mat','d');



%% Track particle


function [cnt_out,a] = identify_single_image(file_name,draw,th,time)

im1 = imread(file_name);
a = im2double(im1(:,:,2));

b = bpass(a,1,10);

if draw == 1
    figure;
    disp(max(max(b)));
    colormap('gray'), imagesc(b);
    axis image;
    title('b');
end


pk = pkfnd(b,th,11);


if draw == 1
    disp(size(pk));
    
    figure,imshow(im1);
    hold on;
    for k = 1:length(pk)
        plot(pk(k,1),pk(k,2),'bo','LineWidth',2);
    end
end

cnt = cntrd(b,pk,15);


if draw == 1
    disp(size(cnt));
    hold on;
    for k = 1:length(cnt)
        plot(cnt(k,1),cnt(k,2),'rx','LineWidth',2);
    end
end

cnt_out = zeros(length(cnt),3);
for k = 1:length(cnt)
    cnt_out(k,1) = cnt(k,1);
    cnt_out(k,2) = cnt(k,2);
    cnt_out(k,3) = time;
end

end