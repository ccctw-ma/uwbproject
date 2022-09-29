% 绘制滤波后结果的速度
% clc;
close all;
h = figure();				    % 创建图形窗口
warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');	    % 关闭相关的警告提示（因为调用了非公开接口）
jFrame = get(h,'JavaFrame');	% 获取底层 Java 结构相关句柄吧
pause(0.1);					    % 在 Win 10，Matlab 2017b 环境下不加停顿会报 Java 底层错误。各人根据需要可以进行实验验证
set(jFrame,'Maximized',1);	    %设置其最大化为真（0 为假）
pause(0.1);					    % 个人实践中发现如果不停顿，窗口可能来不及变化，所获取的窗口大小还是原来的尺寸。各人根据需要可以进行实验验证
warning('on','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');		% 打开相关警告设置
tile=tiledlayout(2, 4,'TileSpacing','tight','Padding','tight');

nexttile(1);
hold on;
plot(KF.smooth_analysis_set(:, 1));
plot(KF.smooth_analysis_set(:, 2));
plot(KF.smooth_analysis_set(:, 3));
plot(zeros(length(KF.smooth_analysis_set), 1));
legend('VX', 'VY', 'V');
title('速度');
hold off;

nexttile(2);
scatter3(kal_posiRes(:,1), kal_posiRes(:,2), 1:length(kal_posiRes), [], linspace(1, 256, length(kal_posiRes)), 'filled');

nexttile(3);
%绘制量测、滤波和平滑后的散点图
hold on
% scatter(posiRes(:, 1), posiRes(:, 2), 'blue');
scatter(kal_posiRes(:, 1), kal_posiRes(: ,2), 'blue');
scatter(kal_mean_posiRes(:, 1), kal_mean_posiRes(:, 2), 'red');
hold off;

nexttile(4);
% plot(KF.smooth_set(:));
% title("滑动窗口的大小");
% scatter(posiRes(:, 1), posiRes(:, 2), 'blue');
hold on;
plot(KF.smooth_analysis_set(:, 4));
title('distance');
hold off;


nexttile(5);
hold on
plot(posiRes(:, 1));
plot(kal_posiRes(:, 1));
plot(kal_mean_posiRes(:, 1));
title('X');
hold off;

nexttile(6);
hold on
plot(posiRes(:, 2));
plot(kal_posiRes(:, 2));
plot(kal_mean_posiRes(:, 2));
title('Y');
hold off;

nexttile(7);
plot(KF.smooth_deg_set);

nexttile(8);
% scatter(posiRes(:,1),posiRes(:,2))
degs = [];

hold on;
plot(KF.smooth_analysis_set(:, 5));
title('angle');
hold off;

return
%%
% mean(KF.smooth_analysis_set(300:500, 3))
mean(KF.smooth_analysis_set(1:320, 3))
mean(KF.smooth_analysis_set(321:444, 3))
mean(KF.smooth_analysis_set(450:1117, 3))
mean(KF.smooth_analysis_set(1118:end, 3))
mean(KF.smooth_analysis_set(1:end, 3))
%%
% load('../UWB_Data/dataCell_0420_static.mat')
load('../UWB_Data/dataCell_0421_static.mat');

%%
a = [1, 1];
b = [2, 3];
x = b(1) - a(1);
y = b(2) - a(2);

if x == 0 && y == 0
    deg = 0;
elseif x == 0
    if y > 0
        deg = 90;
    else
        deg = -90;
    end
elseif y == 0
    if x > 0
        deg = 0;
    else
        deg = 180;
    end
else
    dis = x ^ 2 + y ^ 2;
    sinab =  y / sqrt(dis);
    rad = asin(sinab);
    deg = rad2deg(rad);
    if y > 0 && x < 0
        deg = deg + 90;
    elseif y < 0 && x < 0
        deg = deg - 90;
    end
end
disp([num2str(deg)]);


cc = acos(dot(a, b)/ (norm(a) * norm(b)))
rad2deg(cc)
%%

degs = [];

for i = 3 : length(posiRes)
    a = posiRes(i - 2, :);
    b = posiRes(i - 1, :);
    c = posiRes(i, :);
    p = b - a;
    q = c - b;
    if norm(p - q) < 1e-6
        deg = 0;
    elseif norm(p) > 1e-6 && norm(q) > 1e-6 
        
        cc = acos(dot(p, q)/ (norm(p) * norm(q)));
        if isreal(cc)
            deg = rad2deg(cc);
            degs = [degs; deg];
        end
    end
end

plot(degs);






