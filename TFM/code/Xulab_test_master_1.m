
clear all
dir         = 'D:\OneDrive - HKUST Connect\Code\TFM\';
dir_pro     = 'D:\OneDrive - HKUST Connect\Code\TFM\';
%dir_final   = '/home/hhuar/TFMM/stress/Project_2/Sylgard/CP50/60%_PVC/BSM 7_BSM for 60% PVC-Dinch 0_3 R 2X_300/stress/';

for j=237
close all
%set(0,'DefaultFigureVisible', 'on')
load ([dir,'test_d2_',num2str(j),'.mat'])
% example_tracks contains a structure array d that contains the tracked
% particle data from (i) a reference image, and (ii) an image where tractions are
% being applied to the surface of the TFM substrates.
% In this example, image1.tif is the reference image of fluorescent beads
% on a bare substrate. image2.tif shows the fluorescent beads with a aplysia bag cell
% growth cone sitting on the substrate.
% d(1).r gives the positions of the fluorescent beads in image1.tif. d(2).r
% gives the positions of the fluorescent beads in image2.tif with drift
% subtracted. d(1).dr is the displacements of the fluorescent beads in
% image1.tif relative to those in image1.tif (i.e. zero for all beads).
% d(2).dr gives the displacements of the fluorescent beads in image2.tif
% relative to those in image1.tif, with drift subtracted.
% In general, this TFM code requires a structure array input d. Each structure
% d(i) in the structure array should contain the tracked particle data for
% a specific time point. d(i).r should be the positions of all the tracked
% particles at time i. d(i).dr should be the displacement of these
% particles from their position at the first time point. Note that only
% data for particles that are tracked through every time point should be
% included.
%
% *Note* This code assumes that the fluorescent beads are at the surface
% of the substrate - not below the surface. We do not recommend that beads
% at a fixed distance below the surface are used to calculate surface
% traction stresses (see manuscript). However, if this is done, the Q
% matrix calculation below needs to be suitably modified by changing the
% inputs to calcQ. If strain energy density is required, it must be
% calculated with values of displacements at the surface - not below the
% surface. These surface displacements can be estimated from sub-surface
% displacements, as described in Mertz et al., PRL (2012) 108, 198101.
%
% The code has various outputs:
% X, Y are the x, y coordinates of the grid that stresses and displacements
% are returned at.
%
% d(i).dx_interp, d(i).dy_interp are the displacements d(i).dr interpolated
% onto the grid given by X,Y. Given at each time i.
%
% d(i).ux, d(i).uy are the interpolated displacements above, with a low-pass
% exponential filter applied. The filter is necessary to reduce noise, and
% is controlled by min_feature_size, described below. Given at each time i.
%
%
% d(i).fov is the field of view. Has the same size as X,Y. This is 1 when
% inside the area where we perform particle tracking, and is 0 outside
% (e.g. in the extra padded region that we add in the code). Given at each
% time i.
%
% d(i).stress_x, d(i).stress_y are the surface traction stresses calculated
% from the displacements d.dr. These are returned at the gridpoints given
% by X,Y. Given at each time i.
%
% d(i).sed is the strain energy density - the work per unit area required
% to deform the substrate by the cell/object of interest. See Mertz et al.,
% PRL 108, 198101 (2012) for details.

% load ('cell_outline.mat')
% cell_outline contains a series of points on the periphery of the cell.
% These are clicked by hand. plot(cell_x,cell_y) will show the cell outline
% in pixel units.

tref=1;  % Time for 'zero stress' reference. e.g. if a cell/object of
% interest is removed from the surface at time point 1, then tref=1. If the
% cell/object of interest is present and removed in the last frame,
% tref=length(d).

%min_feature_size=2;
min_feature_size=5;
% This is the spatial resolution of the stress measurement in units of the grid spacing.
% The smaller min_feature_size the better your spatial resoltuion, but
% the worse signal to noise in the stress.

% System parameters
%pix = 116e-9; % Size of one pixel in meters
pix = 4.4/1392/1000; % Size of one pixel in meters

%EM = 3e+3; % Young's modulus in Pascal
%EM =2200; % Young's modulus in Pascal
EM =15000;
%thick = 37e-6;  % Film thickness in microns
% thick =  80e-6;  % Film thickness in microns 29.3,32.3,21.3,25.2
thick =  2e-3;
nu =.48; % Poisson's ratio. If Poisson's ratio=1/2, set nu=0.499 to avoid some division by (1-2*nu) issues in the code.
% nu =.4;


%% Create the grid to interpolate the particle tracking data onto
% This section should remain unchanged if adapting to 3d TFM.

% Subtract off displacements from reference time
for i=1:length(d)
    d(i).dr=d(i).dr-d(tref).dr;
end

% Select number of points for interpolated grid
ovr = 1; % Spatial oversampling (ovr=1 gives grid spacing= avg interparticle distance). ovr should be <=1.
nb_beads=length(d(1).r); % Total number of beads

disp([' number of beads = ' num2str(nb_beads)]);

nx=round(ovr*sqrt(nb_beads)); % Number of points on each side of the interpolation grid

% So that each point contains one bead or so.

if mod(nx,2)==0
    nx = nx+1; % Make sure odd number points in grid
end

% We pad the displacement data on each side of the grid. This reduces
% artifacts in the stress calculation. fracpad is the fraction of extra padding on
% each side of the original data. Thus fracpad=0.5 doubles the width and
% height of the original field of view


fracpad=0.5;
npad = round(fracpad*nx);
% Calculate the boundaries of the data set

%figure,hist(d(tref).r(:,1),100);

xmn = min(d(tref).r(:,1));
xmx = max(d(tref).r(:,1));
ymn = min(d(tref).r(:,2));
ymx = max(d(tref).r(:,2));

disp(['xmn = ' num2str(xmn)]);
disp(['xmx = ' num2str(xmx)]);
disp(['ymn = ' num2str(ymn)]);
disp(['ymx = ' num2str(ymx)]);

dx = max( (xmx-xmn)/nx, (ymx-ymn)/nx); % Distance between the grid points

disp(['dx = ' num2str(dx)]);
disp(['nx = ' num2str(nx)]);




c=.5*[xmn+xmx,ymn+ymx]; % Centre of data set

% Construct the grid
% The grid contains the information for both the real data and the
% extrapolated data.
xi = linspace(-(nx-1)/2-npad,(nx-1)/2+npad,nx+2*npad)*dx+c(1);
disp(['numel(xi) = ' num2str(numel(xi))]);
disp(['max(xi) = ' num2str(max(xi))]);
disp(['min(xi) = ' num2str(min(xi))]);
yi = linspace(-(nx-1)/2-npad,(nx-1)/2+npad,nx+2*npad)*dx+c(2);


% Why the range should include regions where there is no data?

[X,Y]=meshgrid(xi,yi); % Matrix of gridpoints

%% Interpolate the particle track data onto the grid
% If adapting to 3d TFM, the out-of-plane displacements should be
% interpolated onto the X,Y grid to give d(i).dz_interp.

%figure
%im = double(imread('control_dic.tif'))/max(max(double(imread('control_dic.tif'))));
%colormap gray
%hold on
%size_cell_image=size(im); % Size of control image in pixels

%imagesc(im);

%figure;
hold on;
for i = 1:length(d)
    d(i).dx_interp=surface_interpolate(d(i).r(:,1),d(i).r(:,2),d(i).dr(:,1),X,Y,10);
    disp(['max d(i).dx_interp = ' num2str(max(d(i).dx_interp))]);
    d(i).dy_interp=surface_interpolate(d(i).r(:,1),d(i).r(:,2),d(i).dr(:,2),X,Y,10);
    disp(['max d(i).dy_interp = ' num2str(max(d(i).dy_interp))]);
    
    %find indices of all NaNs
    ind2=find(isnan(d(i).dx_interp));
    
    % Calculate field of view array at each timepoint (points within the
    % original data set). fov has zeros outside of field of view, and ones
    % inside.
    d(i).fov=ones(size(X));
    d(i).fov(ind2)=0;
    
    if i>1
        hold on;
        %quiver(X/pix,Y/pix,d(i).dx_interp/pix,d(i).dy_interp/pix);
        quiver(X,Y,d(i).dx_interp,d(i).dy_interp);
        axis image
        xlabel('x [pixels]');
        ylabel('y [pixels]');
        set(gca,'xlim',[min(X(:)) max(X(:))]);
        set(gca,'ylim',[min(Y(:)) max(Y(:))]);
        title('Map of interpolated displacements')
        
        hold on;
        plot([xmn xmn],[ymn ymx],'r-');
        plot([xmx xmx],[ymn ymx],'r-');
        plot([xmn xmx],[ymn ymn],'r-');
        plot([xmn xmx],[ymx ymx],'r-');
        
        % axis([0 size_cell_image(2) 0 size_cell_image(1)]);
        pause(0.1)
    end
    
end

%% Calculate Q matrix. This is the matrix that relates tractions and displacements
% in Fourier space. The original derivation and expression for Q is in Xu
% et al. PNAS 107, 14964-14967 (2010). Note that this example code is for
% 2d traction force microscopy (where out-of-plane tractions are assumed to
% be negligible). If performing 3d TFM, ensure that the arguments to calcQ
% are modified appropriately. (see documentation for calcQ)

[nr,nc]=size(X);

fracpad=2;  %fraction of field of view to pad displacements on either side of current fov+extrapolated to get high k contributions to Q
% It seems that this extrapolation is necessary to calculate Q.
nr2 = round((1+2*fracpad)*nr);
if mod(nr2,2)==0
    nr2=nr2+1;
end


% now the input has units: thick (meter), EM (pa), dx (in meter)
% !!! 
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
% Why there need a Hann window?


% Pad the window
padwidth=(nr2-nr)/2;
padheight=(nr2-nr)/2;
[sz1,sz2]=size(wn);
wn=[zeros(sz1+2*padheight,padwidth) [zeros(padheight,sz2);wn;zeros(padheight,sz2)] zeros(sz1+2*padheight,padwidth)];
%figure,imagesc(wn);
axis image;
colormap(jet);
title('wn');


% If you have the Image Processing Toolbox, this is equivalent to
% wn=padarray(wn,[(nr2-nr)/2,(nr2-nr)/2]);

for i = 1:length(d)
    
    % Record the edge of the data before extrapolation to replace the nan
    % values.
    
    % Get rid of NaN's in the interpolated displacement data
    d(i).dx_interp = extrapdisp(d(i).dx_interp);
    d(i).dy_interp = extrapdisp(d(i).dy_interp);
    
    %%%%%%%%%%%%%%%%%%%%%%
  %  figure; 
    hold on; quiver(X,Y,d(i).dx_interp,d(i).dy_interp);
    axis image
    xlabel('x [pixels]');
    ylabel('y [pixels]');
    
    hold on;
    plot([xmn xmn],[ymn ymx],'r-');
    plot([xmx xmx],[ymn ymx],'r-');
    plot([xmn xmx],[ymn ymn],'r-');
    plot([xmn xmx],[ymx ymx],'r-');
    title('Map of interpolated displacements after extrapdisp')
 
  %  figure; 
    imhist(d(i).dx_interp,100);
    title('hist d(i).dx interp');
    %figure; imhist(d(i).dy_interp,100);
    title('hist d(i).dy interp');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    % Pad and filter x displacements then multiply by the Hann window function
    [sz1,sz2]=size(d(i).dx_interp);
    utmp(1).u=[zeros(sz1+2*padheight,padwidth) [zeros(padheight,sz2);d(i).dx_interp;zeros(padheight,sz2)] zeros(sz1+2*padheight,padwidth)];
    % [(355,142) [(142,71);(71,71);(142,71)] (355,142))]
    % This is just dx interpolate, but with zero values outside in the
    % extrapolation regime.
    % Unit should be the same as the d(i).dx_interp .
    disp('--------------------------------------');
    disp(['size(utmp(1).u) = ' num2str(size(utmp(1).u,1)) 'x' num2str(size(utmp(1).u,2))]);
    % d(i).dx_interp has unit of pixel up to now.
    disp(['sz1 = ' num2str(sz1)]);
    disp(['sz2 = ' num2str(sz2)]);
    disp(['padheight = ' num2str(padheight)]);
    disp(['padwidth = ' num2str(padwidth)]);
    disp(['size(d(i).dx_interp) = ' num2str(size(d(i).dx_interp,1)) 'x' num2str(size(d(i).dx_interp,2))]);
    
    disp('--------------------------------------');
    
    %If you have the Image Processing Toolbox, this line is equivalent to
    %utmp(1).u=padarray(d(i).dx_interp,[(nr2-nr)/2,(nr2-nr)/2]);
    
    %figure,imagesc(utmp(1).u);
    axis image;
    colormap(jet);
    title('utmp(1).u by definition');
    
    utmp(1).u=real(ifft2(qmsk.*fft2(utmp(1).u)));
    
   % figure,imagesc(utmp(1).u);
    axis image;
    colormap(jet);
    title('utmp(1).u after Fourier process');
    
    %utmp(1).u=utmp(1).u.*wn;
    utmp(1).u = utmp(1).u*pix;
    
   % figure,imagesc(utmp(1).u);
    axis image;
    colormap(jet);
    title('utmp(1).u to  convert stress');
    
    % Pad and filter y displacements then multiply by the Hann window function
    utmp(2).u=[zeros(sz1+2*padheight,padwidth) [zeros(padheight,sz2);d(i).dy_interp;zeros(padheight,sz2)] zeros(sz1+2*padheight,padwidth)];
    %If you have the Image Processing Toolbox, this line is equivalent to
    %utmp(2).u=padarray(d(i).dy_interp,[(nr2-nr)/2,(nr2-nr)/2]);
   
    utmp(2).u=real(ifft2(qmsk.*fft2(utmp(2).u)));
    %utmp(2).u=utmp(2).u.*wn;
    utmp(2).u = utmp(2).u*pix;

   % Pad and filter normal stress then multiply by the Hann window function
%     if i == 1
%         Szz = 0;
%     elseif i == 2
%         Szz = 0;
%     end
%     L1 = 160;%size(d(i).dy_interp)+1
%     XX = linspace(-10,10,L1);
%     for iii = 1:length(XX)/2
%         XY(iii,iii:L1-iii) = XX(iii).*ones(L1-2*iii+1,1);
%         XY(L1-iii,iii:L1-iii) = XX(iii).*ones(L1-2*iii+1,1);
%         XY(iii:L1-iii,iii) = XX(iii).*ones(L1-2*iii+1,1);
%         XY(iii:L1-iii,L1-iii) = XX(iii).*ones(L1-2*iii+1,1);
%     end
%     NormalStress = exp(-XY.^2/(3^2)).*Szz;
%     %NormalStress = ones(size(d(i).dy_interp)).*Szz;
%     utmp(3).u=[zeros(sz1+2*padheight,padwidth) [zeros(padheight,sz2);NormalStress;zeros(padheight,sz2)] zeros(sz1+2*padheight,padwidth)];
%     %If you have the Image Processing Toolbox, this line is equivalent to
%     %utmp(3).u=padarray(d(i).dy_interp,[(nr2-nr)/2,(nr2-nr)/2]);
%    
%     utmp(3).u=real(ifft2(qmsk.*fft2(utmp(3).u)));
%     utmp(3).u=utmp(3).u.*wn;
%     utmp(3).u = utmp(3).u*pix;
    %% !!! Key step to convert displacements to stresses.
    stmp = disp2stress(utmp,Q);
    
    % Remove the padding
    d(i).stress_x=stmp(1).s((nr2-nr)/2+1:((nr2-nr)/2+nr),(nr2-nr)/2+1:((nr2-nr)/2+nr));
    d(i).stress_y=stmp(2).s((nr2-nr)/2+1:((nr2-nr)/2+nr),(nr2-nr)/2+1:((nr2-nr)/2+nr));
    
    if length(stmp)== 3
       d(i).stress_z=stmp(3).s((nr2-nr)/2+1:((nr2-nr)/2+nr),(nr2-nr)/2+1:((nr2-nr)/2+nr));
    end

    d(i).ux=utmp(1).u((nr2-nr)/2+1:((nr2-nr)/2+nr),(nr2-nr)/2+1:((nr2-nr)/2+nr));
    d(i).uy=utmp(2).u((nr2-nr)/2+1:((nr2-nr)/2+nr),(nr2-nr)/2+1:((nr2-nr)/2+nr));
    
    % Calculate the strain energy density = u.sigma/2 - see Mertz et al. PRL
    % 108, 198101 (2012).
    d(i).sed = 1/2*d(i).stress_x.*d(i).ux + 1/2*d(i).stress_y.*d(i).uy;
    
    
    % At each timestep, plot the x/y displacements and the x/y traction
    % stresses in one figure. This will be empty at the reference time
    % step.
    %figure
    subplot(2,1,1);
    imagesc([d(i).ux,d(i).uy]);axis image;
    title(['time = ',num2str(i),', displacements']);
    colorbar;
    subplot(2,1,2);
    imagesc([d(i).stress_x,d(i).stress_y]);axis image;
    xlabel(['size stress x = ' num2str(size(d(i).stress_x,1)) ' x ' num2str(size(d(i).stress_x,2))]);
    % Does these data contain extrapolating data?
    title('stresses x component (left) and y component (right)');
    colorbar;
    pause(1)
end

%% Plot up various useful quantities

% Convert cell outline data from pixels to metres
%cell_x_metres=cell_x*pix;
%cell_y_metres=cell_y*pix;

% Plot up traction stress magnitude at the surface of the substrate
% (sigma.sigma).

%figure (1)
for i = 2
    % fov = 0 in the exrapolation regime.
    figure (10)
    %imagesc(X(1,:),Y(:,1),sqrt(((d(i).stress_x.*d(i).fov).^2)+((d(i).stress_y.*d(i).fov).^2)));
    imagesc(X(1,:),Y(:,1),sqrt(((d(i).stress_y.*d(i).fov).^2)));
    dd= sqrt(((d(i).stress_x.*d(i).fov).^2)+((d(i).stress_y.*d(i).fov).^2));
    uu= sqrt(((d(i).ux.*d(i).fov).^2)+((d(i).uy.*d(i).fov).^2));
    sx=d(i).stress_x;
    sy=d(i).stress_y;
    ux=d(i).ux;
    uy=d(i).uy;
    %save([dir_pro,'ux_',num2str(j),'.mat'],'ux');
    %save([dir_pro,'uy_',num2str(j),'.mat'],'uy');
    %save([dir_pro,'u_',num2str(j),'.mat'],'uu');
    %save([dir_pro,'stress_',num2str(j),'.mat'],'dd');
    %save([dir_pro,'X_',num2str(j),'.mat'],'X');
    %save([dir_pro,'Y_',num2str(j),'.mat'],'Y');
    %save([dir_pro,'sx_',num2str(j),'.mat'],'sx');
    %save([dir_pro,'sy_',num2str(j),'.mat'],'sy');
    hold on
for ii = 1:length(X(1,:))
    if X(1,ii)<0 || X(1,ii)>1392
        uu(:,ii)=0;
        ux(:,ii)=0;
        uy(:,ii)=0;
        sx(:,ii)=0;
        sy(:,ii)=0;
    end 
end
for jj = 1:length(Y(:,1))
    if Y(jj,1)<0 || Y(jj,1)>1040
        uu(jj,:)=0;
        ux(jj,:)=0;
        uy(jj,:)=0;
        sx(jj,:)=0;
        sy(jj,:)=0;
    end 
end

%save([dir_final,'u_',num2str(j),'.mat'],'uu');
save([dir_pro,'ux_',num2str(j),'.mat'],'ux');
save([dir_pro,'uy_',num2str(j),'.mat'],'uy');
save([dir_pro,'sx_',num2str(j),'.mat'],'sx');
save([dir_pro,'sy_',num2str(j),'.mat'],'sy');
save([dir_pro,'X_',num2str(j),'.mat'],'X');
save([dir_pro,'Y_',num2str(j),'.mat'],'Y');
%save([dir_final,'stress_',num2str(j),'.mat'],'dd');
end
 
% s1 = load('sx_237.mat');
% s2 = load('Original_sx_237.mat');
% S3 = s1.sx - s2.sx;
% 

%    plot(cell_x_metres,cell_y_metres,'w','LineWidth',2)
    %   axis([0 size_cell_image(2)*pix 0 size_cell_image(1)*pix]);
    %axis([min(X(1,:))*pix max(X(1,:))*pix min(Y(1,:))*pix max(Y(1,:))*pix]);
%     imagesc(dd)
%    colorbar;
%    caxis([0 1000])
%    colormap(jet)
%     axis([0 1392 0 1040]);
%   colorbar('location','EastOutside')
%   colorbar('position',[0.75 0.1 0.04 0.8]);
%   fighandle=figure(10);
%    set(fighandle,'position',[500,0,600,449]);
%   hold off
%    pause(.1)
%   xlabel('x [pixel]')
%    ylabel('y [pixel]')
%    title('Traction stress magnitude [Pa]')
%    axis([0 1392 0 1040]);
%    saveas(gcf,[dir_final,'stress_',num2str(j),'.bmp']);
end

