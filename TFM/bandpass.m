%% This code is for tracking beads to get the displacement field

clear all;
tic;
%% Load files
BaseDir = 'D:\OneDrive - HKUST Connect\experiment\T240930_BSM\code\code\';
addpath(BaseDir);

RefDir = 'D:\OneDrive - HKUST Connect\experiment\T241104\T241102TFM\T241102_Calibration_500Pa\';
addpath(RefDir);
imageNamesRef = dir(fullfile(RefDir,'*.bmp'));
imageNamesRef = {imageNamesRef.name}';

workingDir = RefDir;

%workingDir = 'E:\CompositeTFM\Sept29\Calibration\100Pa\';

Out_Dir = 'D:\OneDrive - HKUST Connect\experiment\T241104\T241102TFM\T241102_Calibration_500Pa\Output\Posi_beads';
mkdir(Out_Dir);
addpath(workingDir);

imageNames = dir(fullfile(workingDir,'*.bmp'));
imageNames = {imageNames.name}';

% Set reference
th = 0.03;
draw = 3;
ref = 10;
file_name = [RefDir imageNamesRef{ref}];
im1 = imread(file_name);
a = im2double(im1(:,:,2));
lnoise = 1;
lobject =11;
image_array = a;
% set filter
% guass kernel
normalize = @(x) x/sum(x); % Defined an anonymous function 'normalize'
image_array = double(image_array);

gaussian_kernel = normalize(...
    exp(-((-ceil(5*lnoise):ceil(5*lnoise))/(2*lnoise)).^2));

% boxcar kernel

boxcar_kernel = normalize(...
    ones(1,length(-round(lobject):round(lobject))));


gconv = conv2(image_array',gaussian_kernel','same');
gconv = conv2(gconv',gaussian_kernel','same');


bconv = conv2(image_array',boxcar_kernel','same');
bconv = conv2(bconv',boxcar_kernel','same');

filtered = gconv - bconv;


% Zero out the values on the edges to signal that they're not useful.     
lzero = max(lobject,ceil(5*lnoise));
filtered(1:(round(lzero)),:) = 0;
filtered((end - lzero + 1):end,:) = 0;
filtered(:,1:(round(lzero))) = 0;
filtered(:,(end - lzero + 1):end) = 0;

% res = filtered;
% filtered(filtered < threshold) = 0;

% plot figure
figure
subplot(2,2,1)
colormap('gray'), imagesc(a);
xlabel('x [pixels]');
ylabel('y [pixels]');
axis equal
xlim([40 80]);
ylim([40 60]);
axis on; % 显示坐标轴
title( 'Row image' ,'Interpreter','Latex','FontSize',20);

subplot(2,2,2)
colormap('gray'), imagesc(gconv);
xlabel('x [pixels]');
ylabel('y [pixels]');
axis equal
xlim([40 80]);
ylim([40 60]);
axis on; % 显示坐标轴
title( 'Guass Filter' ,'Interpreter','Latex','FontSize',20);


subplot(2,2,3)
colormap('gray'), imagesc(bconv);
xlabel('x [pixels]');
ylabel('y [pixels]');
axis equal
xlim([40 80]);
ylim([40 60]);
axis on; % 显示坐标轴
title( 'Boxcar Filter' ,'Interpreter','Latex','FontSize',20);


subplot(2,2,4)
colormap('gray'), imagesc(filtered);
xlabel('x [pixels]');
ylabel('y [pixels]');
axis equal
xlim([40 80]);
ylim([40 60]);
axis on; % 显示坐标轴
title( 'Band Filter' ,'Interpreter','Latex','FontSize',20);




