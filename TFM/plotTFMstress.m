clear; clc;

%% 路径设置
Dir = 'F:\Che\T251205_TFM\T251205_Dow_Ratio1_Phi60_Str1_10_Tw100s\Output\';
% out_dir = 'D:\OneDrive - HKUST Connect\experiment\T250521_TFM_HierarchicalRelax\T250519_Relaxation\T250519_Dow_Ratio1_Phi60_Relaxation_Strain2\Output\mappx\';
% mkdir(out_dir);

%% 获取并加载所有.mat文件
startFrame = 6;
endFrame =1105;
factor = 1;
for k = startFrame:endFrame
    % 完整路径加载
    data = load([Dir, 'sx_', num2str(k), '.mat']);
    sx = data.sx;
    stress(k-startFrame+1) = mean(sx(sx~=0));
    t(k-startFrame+1) = factor*(k-startFrame+1);
 
end

%% 5. 绘制应力-时间曲线
figure;
plot(t, stress, 'b-o', 'LineWidth', 1.5, 'MarkerSize', 6);
xlabel('时间 (s)');
ylabel('平均应力 (Pa)');
set(gca,'xscale','log');
set(gca,'yscale','linear')
title('TFM应力弛豫曲线');
grid on;
set(gca, 'FontSize', 12);

% %% 6. 可选：保存计算结果
% save('processed_stress.mat', 'time', 'stress');