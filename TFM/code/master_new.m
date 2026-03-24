%% Experimental Data
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

d(1).r(:,1) = dd(1).r(:,2);
d(2).r(:,1) = dd(2).r(:,2);
d(1).r(:,2) = dd(1).r(:,1);
d(2).r(:,2) = dd(2).r(:,1);

d(1).dr(:,1) = d(1).r(:,1) - d(1).r(:,1);
d(1).dr(:,2) = d(1).r(:,2) - d(1).r(:,2);
d(2).dr(:,1) = d(2).r(:,1) - d(1).r(:,1);
d(2).dr(:,2) = d(2).r(:,2) - d(1).r(:,2);
%% Create the grid to interpolate the particle tracking data onto
% System parameters
pix = 116e-9; % Size of one pixel in meters
EM = 2.7e+3; % Young's modulus in Pascal
thick = 40e-6;  % Film thickness in microns
nu =.499; % Poisson's ratio.
min_feature_size=2;
tref = 1;

for i=1:length(d)
    d(i).dr=d(i).dr-d(tref).dr;
end

% Select number of points for interpolated grid
ovr = 1; % Spatial oversampling (ovr=1 gives grid spacing= avg interparticle distance). ovr should be <=1.
nb_beads=length(d(1).r); % Total number of beads
nx=round(ovr*sqrt(nb_beads)); % Number of points on each side of the interpolation grid
if mod(nx,2)==0
    nx = nx+1; % Make sure odd number points in grid
end

% height of the original field of view
fracpad=0.5;
npad = round(fracpad*nx);
% Calculate the boundaries of the data set
xmn = min(d(tref).r(:,1));
xmx = max(d(tref).r(:,1));
ymn = min(d(tref).r(:,2));
ymx = max(d(tref).r(:,2));

dx = max( (xmx-xmn)/nx, (ymx-ymn)/nx); % Distance between the grid points
c=.5*[xmn+xmx,ymn+ymx]; % Centre of data set

% Construct the grid
xi = linspace(-(nx-1)/2-npad,(nx-1)/2+npad,nx+2*npad)*dx+c(1);
yi = linspace(-(nx-1)/2-npad,(nx-1)/2+npad,nx+2*npad)*dx+c(2);
[X,Y]=meshgrid(xi,yi); % Matrix of gridpoints

%% Interpolate the particle track data onto the grid

% figure
% im = double(imread('3_inversed.tif'))./max(max(double(imread('3_inversed.tif'))));
% colormap gray
% hold on
% size_cell_image=size(im); % Size of control image in pixels
% 
% imagesc(im);

for i = 1:length(d)
    d(i).dx_interp=surface_interpolate(d(i).r(:,1),d(i).r(:,2),d(i).dr(:,1),X,Y,8);
    d(i).dy_interp=surface_interpolate(d(i).r(:,1),d(i).r(:,2),d(i).dr(:,2),X,Y,8);
 
    %find indices of all NaNs
    ind2=find(isnan(d(i).dx_interp));
    
    % Calculate field of view array at each timepoint (points within the
    % original data set). fov has zeros outside of field of view, and ones
    % inside.
    d(i).fov=ones(size(X));
    d(i).fov(ind2)=0;

    if i>1
        figure
        quiver(X/pix,Y/pix,d(i).dx_interp/pix,d(i).dy_interp/pix);
        axis image
        xlabel('x [pixels]');
        ylabel('y [pixels]');
        title('Map of interpolated displacements')
        % axis([0 size_cell_image(2) 0 size_cell_image(1)]);
        pause(0.1)
    end 
end

%% Calculate Q matrix. This is the matrix that relates tractions and displacements
[nr,nc]=size(X);

fracpad=2;  %fraction of field of view to pad displacements on either side of current fov+extrapolated to get high k contributions to Q
nr2 = round((1+2*fracpad)*nr);
if mod(nr2,2)==0
    nr2=nr2+1;
end
Q = calcQ(thick,thick,EM,nu,nr2,dx,2); % Q matrix that interpolates between displacements and stresses at the substrate surface in Fourier space.

%% calculate filter for the displacement data (in Fourier space).
% This is effectively a low-pass exponential filter.
% No changes should be necessary if modifying code for 3d TFM.

qmax=nr2/(pi*min_feature_size);

% Get distance from of a grid point from the centre of the array
y=repmat((1:nr2)'-nr2/2,1,nr2);
x=y';
q=sqrt(x.^2+y.^2);

% Make the filter
qmsk=exp(-(q./qmax).^2);
qmsk=ifftshift(qmsk);

%% Calculate stresses from displacements
% If modifying code to perform 3d TFM, a corresponding z calculation needs
% to be added at each step.

% Make 1d Hann windows
[szr,szc]=size(d(1).dx_interp);
w_c=0.5*(1-cos(2*pi*(0:szc-1)/(szc-1)));
w_r=0.5*(1-cos(2*pi*(0:szr-1)/(szr-1)));

% Mesh Hann windows together to form 2d Hann window
[wnx,wny]=meshgrid(w_c,w_r);
wn=wnx.*wny;

% Pad the window
padwidth=(nr2-nr)/2;
padheight=(nr2-nr)/2;
[sz1,sz2]=size(wn);
wn=[zeros(sz1+2*padheight,padwidth) [zeros(padheight,sz2);wn;zeros(padheight,sz2)] zeros(sz1+2*padheight,padwidth)];
% If you have the Image Processing Toolbox, this is equivalent to
% wn=padarray(wn,[(nr2-nr)/2,(nr2-nr)/2]);

for i = 1:length(d)
    % Get rid of NaN's in the interpolated displacement data
	d(i).dx_interp=extrapdisp(d(i).dx_interp);
	d(i).dy_interp=extrapdisp(d(i).dy_interp);
        
	% Pad and filter x displacements then multiply by the Hann window function
    [sz1,sz2]=size(d(i).dx_interp);
    utmp(1).u=[zeros(sz1+2*padheight,padwidth) [zeros(padheight,sz2);d(i).dx_interp;zeros(padheight,sz2)] zeros(sz1+2*padheight,padwidth)];
    %If you have the Image Processing Toolbox, this line is equivalent to
	%utmp(1).u=padarray(d(i).dx_interp,[(nr2-nr)/2,(nr2-nr)/2]);
    utmp(1).u=real(ifft2(qmsk.*fft2(utmp(1).u)));    
    utmp(1).u=utmp(1).u.*wn; 
   
    % Pad and filter y displacements then multiply by the Hann window function
    utmp(2).u=[zeros(sz1+2*padheight,padwidth) [zeros(padheight,sz2);d(i).dy_interp;zeros(padheight,sz2)] zeros(sz1+2*padheight,padwidth)];
    %If you have the Image Processing Toolbox, this line is equivalent to
    %utmp(2).u=padarray(d(i).dy_interp,[(nr2-nr)/2,(nr2-nr)/2]);
    utmp(2).u=real(ifft2(qmsk.*fft2(utmp(2).u)));    
    utmp(2).u=utmp(2).u.*wn; 
    
	stmp = disp2stress(utmp,Q);
    
    % Remove the padding
    d(i).stress_x=stmp(1).s((nr2-nr)/2+1:((nr2-nr)/2+nr),(nr2-nr)/2+1:((nr2-nr)/2+nr));
    d(i).stress_y=stmp(2).s((nr2-nr)/2+1:((nr2-nr)/2+nr),(nr2-nr)/2+1:((nr2-nr)/2+nr));
    d(i).ux=utmp(1).u((nr2-nr)/2+1:((nr2-nr)/2+nr),(nr2-nr)/2+1:((nr2-nr)/2+nr));
    d(i).uy=utmp(2).u((nr2-nr)/2+1:((nr2-nr)/2+nr),(nr2-nr)/2+1:((nr2-nr)/2+nr));
         
	% Calculate the strain energy density = u.sigma/2 - see Mertz et al. PRL
	% 108, 198101 (2012).
	d(i).sed = 1/2*d(i).stress_x.*d(i).ux + 1/2*d(i).stress_y.*d(i).uy;

         
    % At each timestep, plot the x/y displacements and the x/y traction
    % stresses in one figure. This will be empty at the reference time
    % step.
%     figure
%     subplot(2,1,1);
%     imagesc([d(i).ux,d(i).uy]);axis image;
%     title(['time = ',num2str(i),', displacements']);
%     colorbar;
%     subplot(2,1,2);
% 	imagesc([d(i).stress_x,d(i).stress_y]);axis image;
% 	title('stresses');
%     colorbar;
%     pause(1)
    
    figure
    subplot(2,2,1);
    imagesc([d(i).ux]);axis image;
    title(['time = ',num2str(i),', displacements x']);
    colorbar;
    subplot(2,2,2);
    imagesc([d(i).uy]);axis image;
    title(['time = ',num2str(i),', displacements y']);
    colorbar;
    subplot(2,2,3);
	imagesc([d(i).stress_x]);axis image;
	title('stresses x');
    colorbar;
    subplot(2,2,4);
	imagesc([d(i).stress_y]);axis image;
	title('stresses y');
    colorbar;
    pause(1)
end

%% Plot up various useful quantities

% % Convert cell outline data from pixels to metres
% cell_x_metres=cell_x*pix;
% cell_y_metres=cell_y*pix;
% 
% % Plot up traction stress magnitude at the surface of the substrate
% % (sigma.sigma).
% 
figure
for i = 2
   imagesc(X(1,:),Y(:,1),sqrt(((d(i).stress_x.*d(i).fov).^2)+((d(i).stress_y.*d(i).fov).^2))); colorbar;
   hold on
%    plot(cell_x_metres,cell_y_metres,'w','LineWidth',2)
%    axis([0 size_cell_image(2)*pix 0 size_cell_image(1)*pix]);
   hold off
    pause(.1)
    xlabel('x [m]')
    ylabel('y [m]')
    title('Traction stress magnitude [Pa]')
    
end
% 
% Plot up strain energy density
% 
figure
for i = 2
    imagesc(X(1,:),Y(:,1),d(i).sed), colorbar
    hold on
    %    plot(cell_x_metres,cell_y_metres,'w','LineWidth',2)
    %    axis([0 size_cell_image(2)*pix 0 size_cell_image(1)*pix]);
    hold off
    xlabel('x [m]')
    ylabel('y [m]')
    title('Strain energy density [J/m^2]')
    pause(0.1)
end

% Plot the displacement contour
figure
[aaa,h] = contourf(X/pix,Y/pix,real(sqrt((d(2).ux/pix)^2+(d(2).uy/pix)^2)),100);
set(h,'LineColor','none')
colorbar
xlabel('x [m]')
ylabel('y [m]')
title('displacement contour plot')

% Make quiver plots to show stresses on top of original image.
i=2;
%positions
str(i).r(:,1) = X(d(i).fov==1);
str(i).r(:,2) = Y(d(i).fov==1);
%stresses
str(i).dr(:,1) = d(i).stress_x(d(i).fov==1);
str(i).dr(:,2) = d(i).stress_y(d(i).fov==1);

sc = 2; %sc is scale for arrows

% im = double(imread('3_inversed.jpg'))./max(max(double(imread('3_inversed.jpg'))));
% %  im = imcrop(im, rect./pix);
% figure, 
% imagesc(im); hold on
% colormap gray
figure,
quiver(str(i).r(:,1)/pix,str(i).r(:,2)/pix,sc*str(i).dr(:,1),sc*str(i).dr(:,2),0,'b');
xlabel('x [m]')
ylabel('y [m]')
title('stress field')
axis image, hold off
