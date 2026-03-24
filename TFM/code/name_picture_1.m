file_path1='/home/hhuar/BSM/stress/Project_2/Sylgard/PP43/Calibration/glycerol/30 Pa/picture/';
file_path2='/home/hhuar/BSM/stress/Project_2/Sylgard/PP43/Calibration/glycerol/30 Pa/list/';
img_path_list = dir(strcat(file_path1,'*.bmp'));%获取该文件夹中所有jpg格式的图像  
img_num = length(img_path_list);%获取图像总数量 

if img_num > 0 %有满足条件的图像  
    for j = 1:img_num %逐一读取图像  
        image_name_old = img_path_list(j).name;% 图像名
        if j<10                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
            image_name_new = strcat('0000',num2str(j),'.bmp');
            image = imread(strcat(file_path1,image_name_old));
            imwrite(image,strcat(file_path2,image_name_new))
        elseif j>=10 && j<100
            image_name_new = strcat('000',num2str(j),'.bmp');
            image = imread(strcat(file_path1,image_name_old));
            imwrite(image,strcat(file_path2,image_name_new))
        elseif j>=100 && j<1000
            image_name_new = strcat('00',num2str(j),'.bmp');
            image = imread(strcat(file_path1,image_name_old));
            imwrite(image,strcat(file_path2,image_name_new))
        elseif j>=1000 && j<10000
            image_name_new = strcat('0',num2str(j),'.bmp');
            image = imread(strcat(file_path1,image_name_old));
            imwrite(image,strcat(file_path2,image_name_new))
        elseif j>=10000 
            image_name_new = strcat('',num2str(j),'.bmp');
            image = imread(strcat(file_path1,image_name_old));
            imwrite(image,strcat(file_path2,image_name_new))    
        end
    end 
end 

clc, clear
file_path1='/home/hhuar/BSM/stress/Project_2/Sylgard/PP43/Calibration/glycerol/100 Pa/picture/';
file_path2='/home/hhuar/BSM/stress/Project_2/Sylgard/PP43/Calibration/glycerol/100 Pa/list/';
img_path_list = dir(strcat(file_path1,'*.bmp'));%获取该文件夹中所有jpg格式的图像  
img_num = length(img_path_list);%获取图像总数量 
if img_num > 0 %有满足条件的图像  
    for j = 1:img_num %逐一读取图像  
        image_name_old = img_path_list(j).name;% 图像名
        if j<10
            image_name_new = strcat('0000',num2str(j),'.bmp');
            image = imread(strcat(file_path1,image_name_old));
            imwrite(image,strcat(file_path2,image_name_new))
        elseif j>=10 && j<100
            image_name_new = strcat('000',num2str(j),'.bmp');
            image = imread(strcat(file_path1,image_name_old));
            imwrite(image,strcat(file_path2,image_name_new))
        elseif j>=100 && j<1000
            image_name_new = strcat('00',num2str(j),'.bmp');
            image = imread(strcat(file_path1,image_name_old));
            imwrite(image,strcat(file_path2,image_name_new))
        elseif j>=1000 && j<10000
            image_name_new = strcat('0',num2str(j),'.bmp');
            image = imread(strcat(file_path1,image_name_old));
            imwrite(image,strcat(file_path2,image_name_new))
        elseif j>=10000 
            image_name_new = strcat('',num2str(j),'.bmp');
            image = imread(strcat(file_path1,image_name_old));
            imwrite(image,strcat(file_path2,image_name_new))    
        end
    end 
end 
% 
clc, clear
file_path1='/home/hhuar/BSM/stress/Project_2/Sylgard/PP43/Calibration/glycerol/200 Pa/picture/';
file_path2='/home/hhuar/BSM/stress/Project_2/Sylgard/PP43/Calibration/glycerol/200 Pa/list/';
img_path_list = dir(strcat(file_path1,'*.bmp'));%获取该文件夹中所有jpg格式的图像  
img_num = length(img_path_list);%获取图像总数量 
if img_num > 0 %有满足条件的图像  
    for j = 1:img_num %逐一读取图像  
        image_name_old = img_path_list(j).name;% 图像名
        if j<10
            image_name_new = strcat('0000',num2str(j),'.bmp');
            image = imread(strcat(file_path1,image_name_old));
            imwrite(image,strcat(file_path2,image_name_new))
        elseif j>=10 && j<100
            image_name_new = strcat('000',num2str(j),'.bmp');
            image = imread(strcat(file_path1,image_name_old));
            imwrite(image,strcat(file_path2,image_name_new))
        elseif j>=100 && j<1000
            image_name_new = strcat('00',num2str(j),'.bmp');
            image = imread(strcat(file_path1,image_name_old));
            imwrite(image,strcat(file_path2,image_name_new))
        elseif j>=1000 && j<10000
            image_name_new = strcat('0',num2str(j),'.bmp');
            image = imread(strcat(file_path1,image_name_old));
            imwrite(image,strcat(file_path2,image_name_new))
        elseif j>=10000 
            image_name_new = strcat('',num2str(j),'.bmp');
            image = imread(strcat(file_path1,image_name_old));
            imwrite(image,strcat(file_path2,image_name_new))    
        end
    end 
end 


clc, clear
file_path1='/home/hhuar/BSM/stress/Project_2/Sylgard/PP43/Calibration/glycerol/400 Pa/picture/';
file_path2='/home/hhuar/BSM/stress/Project_2/Sylgard/PP43/Calibration/glycerol/400 Pa/list/';
img_path_list = dir(strcat(file_path1,'*.bmp'));%获取该文件夹中所有jpg格式的图像  
img_num = length(img_path_list);%获取图像总数量 
if img_num > 0 %有满足条件的图像  
    for j = 1:img_num %逐一读取图像  
        image_name_old = img_path_list(j).name;% 图像名
        if j<10
            image_name_new = strcat('0000',num2str(j),'.bmp');
            image = imread(strcat(file_path1,image_name_old));
            imwrite(image,strcat(file_path2,image_name_new))
        elseif j>=10 && j<100
            image_name_new = strcat('000',num2str(j),'.bmp');
            image = imread(strcat(file_path1,image_name_old));
            imwrite(image,strcat(file_path2,image_name_new))
        elseif j>=100 && j<1000
            image_name_new = strcat('00',num2str(j),'.bmp');
            image = imread(strcat(file_path1,image_name_old));
            imwrite(image,strcat(file_path2,image_name_new))
        elseif j>=1000 && j<10000
            image_name_new = strcat('0',num2str(j),'.bmp');
            image = imread(strcat(file_path1,image_name_old));
            imwrite(image,strcat(file_path2,image_name_new))
        elseif j>=10000 
            image_name_new = strcat('',num2str(j),'.bmp');
            image = imread(strcat(file_path1,image_name_old));
            imwrite(image,strcat(file_path2,image_name_new))    
        end
    end 
end 


clc, clear
file_path1='/home/hhuar/BSM/stress/Project_2/Sylgard/PP43/Calibration/glycerol/600 Pa/picture/';
file_path2='/home/hhuar/BSM/stress/Project_2/Sylgard/PP43/Calibration/glycerol/600 Pa/list/';
img_path_list = dir(strcat(file_path1,'*.bmp'));%获取该文件夹中所有jpg格式的图像  
img_num = length(img_path_list);%获取图像总数量 
if img_num > 0 %有满足条件的图像  
    for j = 1:img_num %逐一读取图像  
        image_name_old = img_path_list(j).name;% 图像名
        if j<10
            image_name_new = strcat('0000',num2str(j),'.bmp');
            image = imread(strcat(file_path1,image_name_old));
            imwrite(image,strcat(file_path2,image_name_new))
        elseif j>=10 && j<100
            image_name_new = strcat('000',num2str(j),'.bmp');
            image = imread(strcat(file_path1,image_name_old));
            imwrite(image,strcat(file_path2,image_name_new))
        elseif j>=100 && j<1000
            image_name_new = strcat('00',num2str(j),'.bmp');
            image = imread(strcat(file_path1,image_name_old));
            imwrite(image,strcat(file_path2,image_name_new))
        elseif j>=1000 && j<10000
            image_name_new = strcat('0',num2str(j),'.bmp');
            image = imread(strcat(file_path1,image_name_old));
            imwrite(image,strcat(file_path2,image_name_new))
        elseif j>=10000 
            image_name_new = strcat('',num2str(j),'.bmp');
            image = imread(strcat(file_path1,image_name_old));
            imwrite(image,strcat(file_path2,image_name_new))    
        end
    end 
end 
