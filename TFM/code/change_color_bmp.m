function res = change_color_bmp(image, hue_shift)
    % 读取 BMP 图像
    original_image = image;
    
    % 将图像转换为 double 类型
    original_image = im2double(original_image);
    
    % 转换 RGB 到 HSL
    [H, S, L] = rgb2hsl(original_image);

    % 修改色相，确保在 [0, 1] 范围内
    H = mod(H + hue_shift, 1);  % hue_shift 在 [0, 1] 之间的值

    % 将 HSL 转换回 RGB
    modified_image = hsl2rgb(H, S, L);
    
    % % 显示原图和修改后的图像
    % figure;
    % subplot(1, 2, 1);
    % imshow(original_image);
    % title('Original Image');
    % 
    % subplot(1, 2, 2);
    % imshow(modified_image);
    % title('Modified Image');
    res = modified_image
end

function [H, S, L] = rgb2hsl(RGB)
    % RGB 转换为 HSL
    R = RGB(:,:,1);
    G = RGB(:,:,2);
    B = RGB(:,:,3);
    
    max_val = max(R, max(G, B));
    min_val = min(R, min(G, B));
    
    L = (max_val + min_val) / 2;

    delta = max_val - min_val;
    S = zeros(size(L));
    H = zeros(size(L));
    
    % 计算饱和度
    S(L > 0 & L < 1) = delta(L > 0 & L < 1) ./ (1 - abs(2 * L(L > 0 & L < 1) - 1));
    
    % 计算色相
    H(max_val == R) = (G(max_val == R) - B(max_val == R)) ./ delta(max_val == R);
    H(max_val == G) = 2 + (B(max_val == G) - R(max_val == G)) ./ delta(max_val == G);
    H(max_val == B) = 4 + (R(max_val == B) - G(max_val == B)) ./ delta(max_val == B);
    
    H = H / 6;  % 归一化到 [0, 1]
    H(H < 0) = H(H < 0) + 1;  % 确保色相在 [0, 1] 范围内
end

function RGB = hsl2rgb(H, S, L)
    % HSL 转换为 RGB
    C = (1 - abs(2 * L - 1)) .* S;
    X = C .* (1 - abs(mod(H * 6, 2) - 1));
    m = L - C / 2;

    R = zeros(size(H));
    G = zeros(size(H));
    B = zeros(size(H));

    % 计算 RGB
    idx1 = (H < 1/6);
    idx2 = (H >= 1/6) & (H < 1/3);
    idx3 = (H >= 1/3) & (H < 1/2);
    idx4 = (H >= 1/2) & (H < 2/3);
    idx5 = (H >= 2/3) & (H < 5/6);
    idx6 = (H >= 5/6);

    R(idx1) = C(idx1) + m(idx1);
    G(idx1) = X(idx1) + m(idx1);
    B(idx1) = m(idx1);
    
    R(idx2) = X(idx2) + m(idx2);
    G(idx2) = C(idx2) + m(idx2);
    B(idx2) = m(idx2);
    
    R(idx3) = m(idx3);
    G(idx3) = C(idx3) + m(idx3);
    B(idx3) = X(idx3) + m(idx3);
    
    R(idx4) = m(idx4);
    G(idx4) = X(idx4) + m(idx4);
    B(idx4) = C(idx4) + m(idx4);
    
    R(idx5) = X(idx5) + m(idx5);
    G(idx5) = m(idx5);
    B(idx5) = C(idx5) + m(idx5);
    
    R(idx6) = C(idx6) + m(idx6);
    G(idx6) = m(idx6);
    B(idx6) = X(idx6) + m(idx6);

    RGB = cat(3, R, G, B);
end