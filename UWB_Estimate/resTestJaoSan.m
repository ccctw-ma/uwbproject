figure
hold on
plot(posiRes(:, 1))
plot(kal_posiRes(:, 1))
hold off
%%
% 基站的位置
anchors = [
    0, 7.2;
    0, 0;
    20.8, 0;
    20.8, 7.2;
    10.4, 7.2;
];

figure();
hold on;
axis([-1, 22, -1 , 15]);
axis image;

for i = 1 : size(anchors, 1)
    x = anchors(i, 1);
    y = anchors(i, 2);
    scatter(x, y, 100, 'k','s', 'filled');
end

% scatter(point_hat_set(:, 1), point_hat_set(:, 2));


scatter(posiRes(:, 1), posiRes(:, 2), 'blue');

scatter(kal_posiRes(:, 1), kal_posiRes(:, 2), 'r');
xlabel('x轴坐标（米）')
ylabel('y轴坐标（米）')
% title('原始定位结果（蓝）与卡尔曼滤波结果（红）对比图')
% scatter(KF.outrange_mea_arr(:, 1), KF.outrange_mea_arr(: ,2), 'magenta');
% scatter(KF.unValid_mea_arr(:, 1), KF.unValid_mea_arr(: ,2), 'yellow');

%% 绘制一组数据的2个点图， x和y的线图， 结果点带有时序信息的三维图
clc;
close all;
% Main4();
% Main()
% 基站的位置
anchors = [
    0, 7.2;
    0, 0;
    20.8, 0;
    20.8, 7.2;
    10.4, 7.2;
];

h = figure();				    % 创建图形窗口
warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');	    % 关闭相关的警告提示（因为调用了非公开接口）
jFrame = get(h,'JavaFrame');	% 获取底层 Java 结构相关句柄吧
pause(0.1);					    % 在 Win 10，Matlab 2017b 环境下不加停顿会报 Java 底层错误。各人根据需要可以进行实验验证
set(jFrame,'Maximized',1);	    %设置其最大化为真（0 为假）
pause(0.1);					    % 个人实践中发现如果不停顿，窗口可能来不及变化，所获取的窗口大小还是原来的尺寸。各人根据需要可以进行实验验证
warning('on','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');		% 打开相关警告设置

tile=tiledlayout(2, 3,'TileSpacing','tight','Padding','tight');
nexttile(1)
hold on;
axis([-1, 20, -1 , 15]);
axis equal;
for i = 1 : size(anchors, 1)
    x = anchors(i, 1);
    y = anchors(i, 2);
    scatter(x, y, 100, 'k','s', 'filled');
end

scatter(posiRes(:, 1), posiRes(:, 2), 'blue');
% scatter(KF.outrange_mea_arr(:, 1), KF.outrange_mea_arr(: ,2), 'magenta');
scatter(kal_posiRes(:, 1), kal_posiRes(:, 2), 'r');
% scatter(KF.unValid_mea_arr(:, 1), KF.unValid_mea_arr(: ,2), 'yellow');
hold off;

nexttile(4);
hold on;
axis([-1, 20, -1 , 15]);
axis image;
for i = 1 : size(anchors, 1)
    x = anchors(i, 1);
    y = anchors(i, 2);
    scatter(x, y, 100, 'k','s', 'filled');
end

scatter(posiRes(:, 1), posiRes(:, 2), 'blue');
scatter(kal_posiRes(:, 1), kal_posiRes(:, 2), 'r');
hold off;


nexttile(2);
hold on;
plot(kalmanDataArr(:, 1:4));
plot(KF.real_time_data_resSet(:, 1));
plot(KF.real_time_data_resSet(:, 2));
plot(KF.real_time_data_resSet(:, 3));
title("X");
legend('Measured', 'estimateRes', 'kalmanRes', 'kalmanGain', 'posiVar', 'velocity', 'velVar');
hold off;

nexttile(5);
hold on;
plot(kalmanDataArr(:, 6:9));
plot(KF.real_time_data_resSet(:, 4));
plot(KF.real_time_data_resSet(:, 5));
plot(KF.real_time_data_resSet(:, 6));
title("Y");
legend('Measured', 'estimateRes', 'kalmanRes', 'kalmanGain', 'posiVar', 'velocity', 'velVar');
hold off;

nexttile(3);
scatter3(posiRes(:,1),posiRes(:,2), 1:length(posiRes), [], linspace(1, 256, length(posiRes)), 'filled');

nexttile(6);
scatter3(kal_posiRes(:,1), kal_posiRes(:,2), 1:length(kal_posiRes), [], linspace(1, 256, length(kal_posiRes)), 'filled');
hold off;

%% 实时绘制运动状态的结果 并展示视频
clc;
close all;
dataSet = [
    "dataCell_0517_moving1.mat", "..\UWB_Video\uwb_0517_moving1.mp4", 40, 0;    % 1
    "dataCell_0517_moving2.mat", "..\UWB_Video\uwb_0517_moving2.mp4", 0, 20;    % 2
    "dataCell_0517_moving3.mat", "..\UWB_Video\uwb_0517_moving3.mp4", 30, 0;    % 3
    "dataCell_0517_movingX1.mat", "..\UWB_Video\uwb_0517_moving_X1.mp4", 0, 0;  % 4
    "dataCell_0517_movingX2.mat", "..\UWB_Video\uwb_0517_moving_X2.mp4", 0, 45; % 5
    "dataCell_0517_random.mat", "..\UWB_Video\uwb_0517_random.mp4", 0, 55;      % 6

    "dataCell_0524_moving1.mat", "..\UWB_Video\uwb_0524_moving1.mp4", 0, 70;     % 7
    "dataCell_0524_moving2.mat", "..\UWB_Video\uwb_0524_moving3.mp4", 0, 60;     % 8
    "dataCell_0524_moving3.mat", "..\UWB_Video\uwb_0524_moving2.mp4", 0, 15;     % 9
    "dataCell_0524_random.mat", "..\UWB_Video\uwb_0524_random.mp4", 0, 0;        % 10
];

selectedIndex = 8;
dataCellFile = dataSet(selectedIndex, 1);
dataVideoFile = dataSet(selectedIndex, 2);
dataDelay = str2double(dataSet(selectedIndex, 3));
videoDelay = str2double(dataSet(selectedIndex, 4));
load(dataCellFile);
Main4();
RP = resPlot(dataVideoFile, posiRes, kal_posiRes, times, dataDelay, videoDelay);
RP.draw();

%%
% 测算沿着直线运动时的定位结果精度并绘制cdf图
clc;
close all;
load('dataCell_0517_moving3.mat');
Main4();
points = [
  40, 1360;
  1401, 2776;
  2963, 4216;
  4556, 5813;
  6011, 7283;
  7631, 8796;
  9075, 10306;
  10611, 11665;
];
dis_ori = [];
dis_kal = [];
vs = [];
for i = 1 : length(points)
    start_index = points(i, 1);
    end_index = points(i, 2);
    x1 = posiRes(start_index, 1);
    t1 = times(start_index);
    x2 = posiRes(end_index, 1);
    t2 = times(end_index);
    v = (x2 - x1) / (t2 - t1);
    vs = [vs; abs(v)];
    for j = start_index : end_index
        t = times(j);
        mx = posiRes(j, 1);
        my = posiRes(j, 2);
        kx = kal_posiRes(j, 1);
        ky = kal_posiRes(j, 2);
        rx = (t - t1) * v + x1;
        ry = 4;
        dis_ori = [dis_ori; sqrt((mx - rx) ^ 2 + (my - ry) ^ 2)];
        dis_kal = [dis_kal; sqrt((kx - rx) ^ 2 + (ky - ry) ^ 2)];
    end
end
fprintf("移动的平均速度为%fm/s \n", mean(vs));
figure();
hold on;
cdfplot(dis_ori);
cdfplot(dis_kal);
legend('mearsurement', 'kalman');
hold off;

%% 绘制在人流较为密集的情况下不同速度运动的定位精度cdf图


clc;
close all;

h = figure();				    % 创建图形窗口
warning('off', 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');	    % 关闭相关的警告提示（因为调用了非公开接口）
jFrame = get(h, 'JavaFrame');	% 获取底层 Java 结构相关句柄吧
pause(0.1);					    % 在 Win 10，Matlab 2017b 环境下不加停顿会报 Java 底层错误。各人根据需要可以进行实验验证
set(jFrame, 'Maximized', 1);	    %设置其最大化为真（0 为假）
pause(0.1);					    % 个人实践中发现如果不停顿，窗口可能来不及变化，所获取的窗口大小还是原来的尺寸。各人根据需要可以进行实验验证
warning('on', 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');		% 打开相关警告设置

tile=tiledlayout(1, 3, 'TileSpacing', 'tight', 'Padding', 'tight');

nexttile(1);
load('dataCell_0524_moving2.mat');
% load('dataCell_0524_moving3.mat');
Main4();

points = [700, 1401, 3.3;];
% points = [4050, 4350, 3.4;];
% points = [300, 1300, 0.98;];
dis_ori = [];
dis_adapte_kal = [];
start_index = points(1);
end_index = points(2);
x1 = posiRes(start_index, 1);
t1 = times(start_index);
x2 = posiRes(end_index, 1);
t2 = times(end_index);
v = (x2 - x1) / (t2 - t1);
ry = points(3);
for j = start_index : end_index
    t = times(j);
    rx = (t - t1) * v + x1;

    mx = posiRes(j, 1);
    my = posiRes(j, 2);
    if ~isnan(mx) && ~isnan(my)
        dis_ori = [dis_ori; sqrt((mx - rx) ^ 2 + (my - ry) ^ 2)];
    end
    kx = kal_posiRes(j, 1);
    ky = kal_posiRes(j, 2);
    dis_adapte_kal = [dis_adapte_kal; sqrt((kx - rx) ^ 2 + (ky - ry) ^ 2)];
end

hold on;
cdfplot(dis_ori);
cdfplot(dis_adapte_kal);



% cdfplot(dis_kal);
legend('mearsurement', 'adaptiveKalman', 'kalman');
title(["速度为",num2str(round(abs(v), 2))],'m/s')
% title("量测，卡尔曼滤波和自适应卡尔曼滤波定位误差cdf图")
xlabel("定位误差单位（m）")
hold off;


% nexttile(2);
% points = [2800, 3400, 3.8;];
% dis_ori = [];
% dis_kal = [];
% start_index = points(1);
% end_index = points(2);
% x1 = posiRes(start_index, 1);
% t1 = times(start_index);
% x2 = posiRes(end_index, 1);
% t2 = times(end_index);
% v = (x2 - x1) / (t2 - t1);
% ry = points(3);
% for j = start_index : end_index
%     t = times(j);
%     rx = (t - t1) * v + x1;
% 
%     mx = posiRes(j, 1);
%     my = posiRes(j, 2);
%     if ~isnan(mx) && ~isnan(my)
%         dis_ori = [dis_ori; sqrt((mx - rx) ^ 2 + (my - ry) ^ 2)];
%     end
%     kx = kal_posiRes(j, 1);
%     ky = kal_posiRes(j, 2);
%     dis_kal = [dis_kal; sqrt((kx - rx) ^ 2 + (ky - ry) ^ 2)];
% end
% hold on;
% cdfplot(dis_ori);
% cdfplot(dis_kal);
% legend('mearsurement', 'kalman');
% title(["速度为",num2str(round(abs(v), 2))],'m/s')
% hold off;

nexttile(2);
points = [4050, 4350, 3.4;];
dis_ori = [];
dis_kal = [];
start_index = points(1);
end_index = points(2);
x1 = posiRes(start_index, 1);
t1 = times(start_index);
x2 = posiRes(end_index, 1);
t2 = times(end_index);
v = (x2 - x1) / (t2 - t1);
ry = points(3);
for j = start_index : end_index
    t = times(j);
    rx = (t - t1) * v + x1;

    mx = posiRes(j, 1);
    my = posiRes(j, 2);
    if ~isnan(mx) && ~isnan(my)
        dis_ori = [dis_ori; sqrt((mx - rx) ^ 2 + (my - ry) ^ 2)];
    end
    kx = kal_posiRes(j, 1);
    ky = kal_posiRes(j, 2);
    dis_kal = [dis_kal; sqrt((kx - rx) ^ 2 + (ky - ry) ^ 2)];
end
hold on;
cdfplot(dis_ori);
cdfplot(dis_kal);
legend('mearsurement', 'kalman');
title(["速度为",num2str(round(abs(v), 2))],'m/s')
hold off;


load('dataCell_0524_moving3.mat');
Main4();
nexttile(3);
points = [300, 1300, 0.98;];
dis_ori = [];
dis_kal = [];
start_index = points(1);
end_index = points(2);
x1 = posiRes(start_index, 1);
t1 = times(start_index);
x2 = posiRes(end_index, 1);
t2 = times(end_index);
v = (x2 - x1) / (t2 - t1);
ry = points(3);
for j = start_index : end_index
    t = times(j);
    rx = (t - t1) * v + x1;

    mx = posiRes(j, 1);
    my = posiRes(j, 2);
    if ~isnan(mx) && ~isnan(my)
        dis_ori = [dis_ori; sqrt((mx - rx) ^ 2 + (my - ry) ^ 2)];
    end
    kx = kal_posiRes(j, 1);
    ky = kal_posiRes(j, 2);
    dis_kal = [dis_kal; sqrt((kx - rx) ^ 2 + (ky - ry) ^ 2)];
end
hold on;
cdfplot(dis_ori);
cdfplot(dis_kal);
legend('mearsurement', 'kalman');
title(["速度为",num2str(round(abs(v), 2))],'m/s')
hold off;
%%
load('dataCell_0524_moving2.mat');



Main4();
% points = [700, 1401, 3.3;];
points = [700, 1401, 3.3;];
dis_ori = [];
dis_adapt_kal = [];
start_index = points(1);
end_index = points(2);
x1 = posiRes(start_index, 1);
t1 = times(start_index);
x2 = posiRes(end_index, 1);
t2 = times(end_index);
v = (x2 - x1) / (t2 - t1);
ry = points(3);
for j = start_index : end_index
    t = times(j);
    rx = (t - t1) * v + x1;

    mx = posiRes(j, 1);
    my = posiRes(j, 2);
    if ~isnan(mx) && ~isnan(my)
        dis_ori = [dis_ori; sqrt((mx - rx) ^ 2 + (my - ry) ^ 2)];
    end
    kx = kal_posiRes(j, 1);
    ky = kal_posiRes(j, 2);
    dis_adapt_kal = [dis_adapt_kal; sqrt((kx - rx) ^ 2 + (ky - ry) ^ 2)];
end


Main();

dis_ori = [];
dis_kal = [];
start_index = points(1);
end_index = points(2);
x1 = posiRes(start_index, 1);
t1 = times(start_index);
x2 = posiRes(end_index, 1);
t2 = times(end_index);
v = (x2 - x1) / (t2 - t1);
ry = points(3);
for j = start_index : end_index
    t = times(j);
    rx = (t - t1) * v + x1;

    mx = posiRes(j, 1);
    my = posiRes(j, 2);
    if ~isnan(mx) && ~isnan(my)
        dis_ori = [dis_ori; sqrt((mx - rx) ^ 2 + (my - ry) ^ 2)];
    end
    kx = kal_posiRes(j, 1);
    ky = kal_posiRes(j, 2);
    dis_kal = [dis_kal; sqrt((kx - rx) ^ 2 + (ky - ry) ^ 2)];
end


figure();
hold on;
cdfplot(dis_ori);
cdfplot(dis_kal);
cdfplot(dis_adapt_kal);
legend('mearsurement', 'KF','AKF');
xlabel('定位误差（m）');
t = strcat(["速度为",num2str(round(abs(v), 2)),'m/s']);
% title(t)
hold off;

    





