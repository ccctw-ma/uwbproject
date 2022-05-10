%%
%静止状态下的定位精度分析
pos_x_hat = 4.75;
pos_y_hat = 2.35;


abs_distance = [];
for i = 1 : length(posiRes)
    x = posiRes(i, 1);
    y = posiRes(i, 2);
    d = sqrt((x - pos_x_hat) ^ 2 + (y - pos_y_hat) ^ 2);
    abs_distance = [abs_distance; d];
end
cdfplot(abs_distance);

hold on;


% abs_distance_kal = [];
% for i = 1 : length(kal_posiRes)
%     x = kal_posiRes(i, 1);
%     y = kal_posiRes(i, 2);
%     d = sqrt((x - pos_x_hat) ^ 2 + (y - pos_y_hat) ^ 2);
%     abs_distance_kal = [abs_distance_kal; d];
% end
% cdfplot(abs_distance_kal);


% abs_distance_mean = [];
% for i = 1 : length(mean_posiRes)
%     x = mean_posiRes(i, 1);
%     y = mean_posiRes(i, 2);
%     d = sqrt((x - pos_x_hat) ^ 2 + (y - pos_y_hat) ^ 2);
%     abs_distance_mean = [abs_distance_mean; d];
% end
% cdfplot(abs_distance_mean);



abs_distance_ftm = [];
for i = 1 : length(ftm_posiRes)
    x = ftm_posiRes(i, 1);
    y = ftm_posiRes(i, 2);
    d = sqrt((x - pos_x_hat) ^ 2 + (y - pos_y_hat) ^ 2);
    abs_distance_ftm = [abs_distance_ftm; d];
end
cdfplot(abs_distance_ftm);

abs_distance_mean_ftm = [];
for i = 1 : length(ftm_mean_posiRes)
    x = ftm_mean_posiRes(i, 1);
    y = ftm_mean_posiRes(i, 2);
    d = sqrt((x - pos_x_hat) ^ 2 + (y - pos_y_hat) ^ 2);
    abs_distance_mean_ftm = [abs_distance_mean_ftm; d];
end
cdfplot(abs_distance_mean_ftm);



%%
% moving precision test
% file：dataCell_0429_moving_2.mat
posi_hat_dataCell_range = [
    1,   2.5,   104,   114;
    1,   2,     165,   175;
    1,   1.5,   223,   233;
    1,   1,     325,   335;
    1.5, 0.5,   526,   536;
    2,   0.5,   630,   640;
    2.5, 0.5,   700,   710;
    3,   0.5,   755,   765;
    3.5, 0.5,   807,   817;
    4,   0.5,   868,   878;
    4.5, 0.5,   926,   936;
    5,   0.5,   995,  1005;
    5.5, 0.5,   1060, 1070;
    6,   0.5,   1160, 1170;
];

distance_measure_set = [];
distance_intel_set = [];

disable_moving_set = [];
for i = 1 : length(posi_hat_dataCell_range)
    x_hat = posi_hat_dataCell_range(i, 1);
    y_hat = posi_hat_dataCell_range(i, 2);
    data_start = posi_hat_dataCell_range(i, 3);
    data_end = posi_hat_dataCell_range(i, 4);
    for j = data_start : data_end
        measure_x = posiRes(j, 1);
        measure_y = posiRes(j, 2);
        intel_x = ftm_posiRes(j, 1);
        intel_y = ftm_posiRes(j, 2);
        moving_x = kal_posiRes(j, 1);
        moving_y = kal_posiRes(j, 2);
        distance_measure = sqrt((x_hat - measure_x) ^ 2 + (y_hat - measure_y) ^ 2);
        distance_intel = sqrt((x_hat - intel_x) ^ 2 + (y_hat - intel_y) ^ 2);
        distance_moving = sqrt((x_hat - moving_x) ^ 2 + (y_hat - moving_y) ^ 2);
        distance_measure_set = [distance_measure_set; distance_measure];
        distance_intel_set = [distance_intel_set; distance_intel];
        disable_moving_set = [disable_moving_set; distance_moving];
    end
end

figure(1);
hold on;
title('运动状态下的定位误差cdf图')
cdfplot(distance_measure_set);
cdfplot(distance_intel_set);
cdfplot(disable_moving_set);
legend('原始观测', 'intel修正', 'moving修正');

%%
% 绘制测试环境下的参考运动轨迹
figure();
hold on;
axis([-1, 7, -1 , 5]);
axis equal;
pos_hat = [
    6, 3.5;
    1, 3.5;
    1, 0.5;
    6, 0.5;
];

point_hat_set = [];
for i = 1 : 0.01 : 6
    point_hat_set = [point_hat_set; i, 3.5];
end

for j = 0.5 : 0.01 : 3.5
    point_hat_set = [point_hat_set; 1, j];
end

for i = 1 : 0.01 : 6
    point_hat_set = [point_hat_set; i, 0.5];
end

scatter(point_hat_set(:, 1), point_hat_set(:, 2));
scatter(posiRes(:, 1), posiRes(:, 2));
scatter(ftm_posiRes(:, 1), ftm_posiRes(:, 2));
% scatter(ftm_mean_posiRes(:, 1), ftm_mean_posiRes(:, 2));

%%
% 运动状态下的误差分析 x值不变
abs_distance_ori_moving = [];
abs_distance_ftm_moving = [];
abs_distance_ftm_mean_moving = [];
for i = 1 : length(posiRes)
    ox = posiRes(i, 1);
    oy = posiRes(i, 2);
    fx = ftm_posiRes(i, 1);
    fy = ftm_posiRes(i, 2);
    od =  abs(ox - 1);
    fd =  abs(fx - 1);
    fmd = abs(ftm_mean_posiRes(i, 1) - 1);
    abs_distance_ori_moving = [abs_distance_ori_moving; od];
    abs_distance_ftm_moving = [abs_distance_ftm_moving; fd];
    abs_distance_ftm_mean_moving = [abs_distance_ftm_mean_moving; fmd];
end
cdfplot(abs_distance_ori_moving);
hold on;
cdfplot(abs_distance_ftm_moving);
cdfplot(abs_distance_ftm_mean_moving)
% legend('观测数据','Intel算法修正后的数据');

%%
% 运动状态下的误差分析 y值不变

abs_distance_ori_moving = [];
abs_distance_ftm_moving = [];
abs_distance_ftm_mean_moving = [];
for i = 1 : length(posiRes)
    ox = posiRes(i, 1);
    oy = posiRes(i, 2);
    fx = ftm_mean_posiRes(i, 1);
    fy = ftm_posiRes(i, 2);
    fmy = ftm_mean_posiRes(i, 2);
    od =  abs(oy - 3.5);
    fd =  abs(fy - 3.5);
    fmd = abs(fmy - 3.5);
    abs_distance_ori_moving = [abs_distance_ori_moving; od];
    abs_distance_ftm_moving = [abs_distance_ftm_moving; fd];
    abs_distance_ftm_mean_moving = [abs_distance_ftm_mean_moving; fmd];
end
cdfplot(abs_distance_ori_moving);
hold on;
cdfplot(abs_distance_ftm_moving);
cdfplot(abs_distance_ftm_mean_moving);


%%
% 绘制静止和运动状态下的精度cdf图

cdfplot(abs_distance);
hold on;
cdfplot(abs_distance_ftm);
cdfplot(abs_distance_ori_moving);
cdfplot(abs_distance_ftm_moving);
legend('原始静止','intel静止','原始运动','Intel运动');

%%
for i = 20 : -1 : 10
    i
end