clear all
clc
src1=imread('1.jpg');
src2=imread('2.jpg');
a1 = src1 - src2;
a2 = src2 - src1;
J1 = im2bw(a1,0.2);
J2 = im2bw(a2,0.2);

J3 = J1+J2;

figure;
imshow(J1)
figure;
imshow(J2)
figure;
imshow(J3)
hold on

dist =@(x1,y1,x2,y2) sqrt((x2-x1).^2+(y2-y1).^2);
neighbour_cutoff = 20;
interact_cutoff = 42;

[i1 ,j1] = ind2sub(size(J1) ,find(J1 == 1));
for m = 1:length(i1)-1
    for n = m+1:length(i1)
        if i1(m)~= 0 && j1(m)~=0 && i1(n)~=0 && j1(n)~=0 && dist(i1(m),j1(m) , i1(n),j1(n)) < neighbour_cutoff
            i1(n) = 0;
            j1(n) = 0;
        end
    end
end
x = find(i1 == 0);
i1(x) = [];
j1(x) = [];
    
[i2 ,j2] = ind2sub(size(J2) ,find(J2 == 1));
for m = 1:length(i2)-1
    for n = m+1:length(i2)
        if i2(m)~= 0 && j2(m)~=0 && i2(n)~=0 && j2(n)~=0 && dist(i2(m),j2(m) , i2(n),j2(n)) < neighbour_cutoff
            i2(n) = 0;
            j2(n) = 0;
        end
    end
end
x = find(i2 == 0);
i2(x) = [];
j2(x) = [];

num = min(length(i1),length(i2));
for m = 1:num
    for n = 1:num
        i1dis((m-1)*num + n) = i1(m);
        j1dis((m-1)*num + n) = j1(m);        
        i2dis((m-1)*num + n) = i2(n);
        j2dis((m-1)*num + n) = j2(n);
    end
end

distij  = dist(i1dis', j1dis' ,i2dis', j2dis');
distij2d = reshape(distij , [num,num]);
for m = 1:num
    pos = find(distij2d(:,m) ==  min(distij2d(:,m)));
    if length(pos) > 1
        pos = pos(1);
    end
    dd(1).r(m,1) = i1(m);
    dd(1).r(m,2) = j1(m);
    if  min(distij2d(:,m)) < interact_cutoff
        dd(2).r(m,1) = i2(pos);
        dd(2).r(m,2) = j2(pos);
    else
        dd(2).r(m,1) = 0;
        dd(2).r(m,2) = 0;
    end
end



scatter(dd(1).r(:,2),dd(1).r(:,1))
hold on
scatter(dd(2).r(:,2),dd(2).r(:,1))

% I1=rgb2gray(J1);
% I2=rgb2gray(J2);
% figure;
% imshow(I1)
% imshow(I2)

% figure;
% C1 = imcontour(J1);
% figure;
% C2 = imcontour(J2);
% 
% [dd(1).r(:,1), dd(1).r(:,2)] = find(J1 == 1);
% [dd(2).r(:,1), dd(2).r(:,2)] = find(J2 == 1);