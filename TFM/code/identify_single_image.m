
function [cnt_out,b] = identify_single_image(file_name,draw,th,time,lnoise,lobject,pksz,ctsz)

im1 = imread(file_name);
a = im2double(im1(:,:,2));% Convert the second channel(green channel) to a dual precision format

b = bpass(a,lnoise,lobject);

if draw == 1
    figure;
    disp(max(max(b)));
    colormap('gray'), imagesc(b);
    axis image;
    title('b');
end


pk = pkfnd(b,th,pksz);
% Pkfnd (b, th, 11): Use peak search function to detect the position of particles in the image, 
% where th is the threshold and 11 may be the neighborhood range for peak search.

if draw == 1
    disp(size(pk));

    figure,imshow(im1);
    hold on;
    for k = 1:length(pk)
        plot(pk(k,1),pk(k,2),'bo','LineWidth',2);
    end
end

cnt = cntrd(b,pk,ctsz); 
% Accurately locate the center of particles
% the centroid coordinates, total brightness, and radius information of each particle.

if draw == 1
    disp(size(cnt));
    hold on;
    for k = 1:length(cnt)
        plot(cnt(k,1),cnt(k,2),'rx','LineWidth',2);
    end
    xlabel('x [pixels]');
    ylabel('y [pixels]');
end

cnt_out = zeros(length(cnt),3);
for k = 1:length(cnt)
    cnt_out(k,1) = cnt(k,1);
    cnt_out(k,2) = cnt(k,2);
    cnt_out(k,3) = time;
end
      
end