

% 
% 科研楼大厅 南北 15.5
% 
% 东西15.8
% 
% 实验方式（口字形），沿各边两块砖距离走，砖厂80cm
% 
% 实验方式（S型）：从初始边两块砖距离开始，拐弯时隔5块砖
% 
% 实验方式（静止）：固定位置x：8， y：8.8
% 
% 静止第二组：固定位置x：12， y：7.2
% 
% 最后一次：任意

%%
% 以散点图的形式绘制定位结果

load('dataCell_moving1.mat')
Main4
% 基站的位置
anchors = [
    0, 12.9;
    0, 0;
    15.4, 0;
    15.4, 14.3;
    8.7, 14.3;
];

% 路线参考路径
point_hat_set = [];
for y = 0.8 : 0.01 : 13
    point_hat_set = [point_hat_set; 1.4, y];
end

for x = 1.4 : 0.01 : 14.5
    point_hat_set = [point_hat_set; x, 0.8];
end

for y = 0.8 : 0.01 : 13
    point_hat_set = [point_hat_set; 14.5, y];
end

for x = 1.4 : 0.01 : 14.5
    point_hat_set = [point_hat_set; x, 13];
end

figure();
hold on;
axis([-1, 20, -1 , 18]);
axis equal;

for i = 1 : size(anchors, 1)
    x = anchors(i, 1);
    y = anchors(i, 2);
    scatter(x, y, 100, 'k','s', 'filled');
end

scatter(point_hat_set(:, 1), point_hat_set(:, 2));

scatter(posiRes(:, 1), posiRes(:, 2), 'blue');
scatter(kal_posiRes(:, 1), kal_posiRes(:, 2), 'r');
% scatter(KF.abnormal_mea_arr(:, 1), KF.abnormal_mea_arr(:, 2),'black');
% scatter(KF.outrange_mea_arr(:, 1), KF.outrange_mea_arr(: ,2), 'magenta');
% scatter(KF.unValid_mea_arr(:, 1), KF.unValid_mea_arr(: ,2), 'yellow');
% scatter(KF.smooth_posiRes(:, 1), KF.smooth_posiRes(:, 2));
scatter(KF.mean_posiRes(:, 1), KF.mean_posiRes(:, 2));
% scatter(mean_posiRes(:, 1), mean_posiRes(:, 2));
% scatter(ftm_posiRes(:, 1), ftm_posiRes(:, 2));
% scatter(ftm_mean_posiRes(:, 1), ftm_mean_posiRes(:, 2));


%%

load('dataCell_moving2.mat')
Main4

% 基站的位置
anchors = [
    0, 12.9;
    0, 0;
    15.4, 0;
    15.4, 14.3;
    8.7, 14.3;
];

% 路线参考路径
point_hat_set = [];
for y = 0.8 : 0.01 : 12
    point_hat_set = [point_hat_set; 1.4, y];
end

for x = 1.4 : 0.01 : 14.2
    point_hat_set = [point_hat_set; x, 0.8];
end

for y = 0.8 : 0.01 : 12
    point_hat_set = [point_hat_set; 14.2, y];
end

for x = 1.4 : 0.01 : 14.2
    point_hat_set = [point_hat_set; x, 12];
end

figure();
hold on;
axis([-1, 20, -1 , 18]);
axis equal;

for i = 1 : size(anchors, 1)
    x = anchors(i, 1);
    y = anchors(i, 2);
    scatter(x, y, 100, 'k','s', 'filled');
end

scatter(point_hat_set(:, 1), point_hat_set(:, 2));

scatter(posiRes(:, 1), posiRes(:, 2), 'blue');
scatter(kal_posiRes(:, 1), kal_posiRes(:, 2), 'r');
% scatter(KF.outrange_mea_arr(:, 1), KF.outrange_mea_arr(: ,2), 'magenta');
scatter(KF.outrange_mea_arr(:, 1), KF.outrange_mea_arr(: ,2), 'magenta');
scatter(KF.unValid_mea_arr(:, 1), KF.unValid_mea_arr(: ,2), 'yellow');
%% 绘制该组数据六个图
Main4();
% 基站的位置
anchors = [
    0, 12.9;
    0, 0;
    15.4, 0;
    15.4, 14.3;
    8.7, 14.3;
];

% 路线参考路径
point_hat_set = [];


% gcf  = figure();
% SIZE = get(0, 'ScreenSize');
% set(gcf, 'outerposition', SIZE);
h = figure();				% 创建图形窗口
warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');	% 关闭相关的警告提示（因为调用了非公开接口）
jFrame = get(h,'JavaFrame');	% 获取底层 Java 结构相关句柄吧
pause(0.1);					% 在 Win 10，Matlab 2017b 环境下不加停顿会报 Java 底层错误。各人根据需要可以进行实验验证
set(jFrame,'Maximized',1);	%设置其最大化为真（0 为假）
pause(0.1);					% 个人实践中发现如果不停顿，窗口可能来不及变化，所获取的窗口大小还是原来的尺寸。各人根据需要可以进行实验验证
warning('on','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');		% 打开相关警告设置

tile=tiledlayout(2, 3,'TileSpacing','tight','Padding','tight');
nexttile(1)
hold on;
axis([-1, 20, -1 , 18]);
axis equal;

for i = 1 : size(anchors, 1)
    x = anchors(i, 1);
    y = anchors(i, 2);
    scatter(x, y, 100, 'k','s', 'filled');
end

% scatter(point_hat_set(:, 1), point_hat_set(:, 2));

scatter(posiRes(:, 1), posiRes(:, 2), 'blue');
scatter(KF.outrange_mea_arr(:, 1), KF.outrange_mea_arr(: ,2), 'magenta');
scatter(kal_posiRes(:, 1), kal_posiRes(:, 2), 'r');
scatter(KF.unValid_mea_arr(:, 1), KF.unValid_mea_arr(: ,2), 'yellow');
hold off;

nexttile(4);
hold on;
axis([-1, 16, -1 , 15]);
axis equal;
for i = 1 : size(anchors, 1)
    x = anchors(i, 1);
    y = anchors(i, 2);
    scatter(x, y, 100, 'k','s', 'filled');
end

scatter(posiRes(:, 1), posiRes(:, 2), 'blue');
scatter(kal_posiRes(:, 1), kal_posiRes(:, 2), 'r');
hold off;


nexttile(2);
plot(kalmanDataArr(:, 1:4));
title("X");
legend('Measured','estimateRes', 'kalmanRes','kalmanGain');

nexttile(5);
plot(kalmanDataArr(:, 5:8));
title("Y");
legend('Measured','estimateRes', 'kalmanRes','kalmanGain');

nexttile(3);
scatter3(posiRes(:,1),posiRes(:,2), 1:length(posiRes), [], linspace(1, 256, length(posiRes)), 'filled');

nexttile(6);
scatter3(kal_posiRes(:,1), kal_posiRes(:,2), 1:length(kal_posiRes), [], linspace(1, 256, length(kal_posiRes)), 'filled');

%%
% 测算静止状态的定位结果精度
clc;
clear;
load('dataCell_static_8_8-8.mat');
Main4();
point_hat = [8.2, 9];

% load('dataCell_static_12_7-2.mat');
% Main4();
% point_hat = [13.5, 7.5];

% load('dataCell_0429_static_6_0.5.mat');
% Main4();
% point_hat = [6, 0.5];

dis_ori = [];
dis_kal = [];
for i = 1 : length(posiRes)
    x_h = point_hat(1);
    y_h = point_hat(2);
    x = posiRes(i, 1);
    y = posiRes(i, 2);
    dis_ori = [dis_ori; (x_h - x) ^ 2 + (y_h - y) ^ 2];
end
for i = 1 : length(kal_posiRes)
    x_h = point_hat(1);
    y_h = point_hat(2);
    x = kal_posiRes(i, 1);
    y = kal_posiRes(i, 2);
    dis_kal = [dis_kal; (x_h - x) ^ 2 + (y_h - y) ^ 2];
end
figure();
hold on;
cdfplot(dis_ori);
cdfplot(dis_kal);
legend('ori', 'kal');
hold off;


%%
% 测算运动状态的定位结果精度
clc;
clear;
load('dataCell_moving1.mat');
Main4();
start_point = [1.2, 12.4, 1];
end_point = [1.8, 0.8, 1070];
dis_ori = [];
dis_kal = [];

for i = 1 : length(kal_posiRes) - 50
%     x_hat = KF.mean_posiRes(i, 1);
%     y_hat = KF.mean_posiRes(i, 2);
    x_ori = posiRes(i + 50, 1);
    y_ori = posiRes(i + 50, 2);
    x_kal = kal_posiRes(i + 50, 1);
    y_kal = kal_posiRes(i + 50, 2);
    if ~isnan(x_ori)
        dis_ori = [dis_ori; (x_ori - x_kal) ^ 2 + (y_ori - y_kal) ^ 2];
    end
%     dis_kal = [dis_kal; (x_kal - x_hat) ^ 2 + (y_kal - y_hat) ^ 2];
end
figure();
hold on;
cdfplot(dis_ori);
% cdfplot(dis_kal);
legend('ori', 'kal');
hold off;
%%
figure();
plot(kalmanDataArr(:, 1:4));
title("X");
% legend('Measured','estimateRes', 'kalmanRes','meanRes','kalmanGain');
legend('Measured','estimateRes', 'kalmanRes','kalmanGain');
%%
figure();
plot(kalmanDataArr(:, 5:8));
title("Y");

% legend('Measured','estimateRes', 'kalmanRes','meanRes','kalmanGain');
legend('Measured','estimateRes', 'kalmanRes','kalmanGain');
%%
% 以三维散点图的形式绘制定位结果

figure();
colors = linspace(1, 256, length(posiRes));
% scatter(kalmanPosiRes(:,1),kalmanPosiRes(:,2), [], colors, 'filled');
scatter3(posiRes(:,1),posiRes(:,2), 1:length(posiRes), [], colors, 'filled');
% scatter3(ftm_mean_posiRes(:,1), ftm_mean_posiRes(:,2), 1:length(posiRes), [], colors, 'filled');
figure();
scatter3(kal_posiRes(:,1), kal_posiRes(:,2), 1:length(kal_posiRes), [], linspace(1, 256, length(kal_posiRes)), 'filled');
%%
figure();
hold on;

% test_posi = [];
% for i = 1 : 1070
%     x = kal_posiRes(i, 1);
%     y = x * -7.1112 + 16.3645;
%     test_posi = [test_posi; x, y];
% end
scatter(posiRes(1:1070,1), posiRes(1:1070,2));
scatter(kal_posiRes(1:1070,1), kal_posiRes(1:1070,2));
scatter(KF.mean_posiRes(1:1070,1), KF.mean_posiRes(1:1070,2));
hold off;