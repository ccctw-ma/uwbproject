
%%
% 以散点图的形式绘制定位结果

load('dataCell_moving1.mat')
Main3

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
scatter(KF.outrange_mea_arr(:, 1), KF.outrange_mea_arr(: ,2), 'magenta');
% scatter(KF.unValid_mea_arr(:, 1), KF.unValid_mea_arr(: ,2), 'yellow');
% scatter(KF.smooth_posiRes(:, 1), KF.smooth_posiRes(:, 2));
% scatter(kal_mean_posiRes(:, 1), kal_mean_posiRes(:, 2));
% scatter(mean_posiRes(:, 1), mean_posiRes(:, 2));
% scatter(ftm_posiRes(:, 1), ftm_posiRes(:, 2));
% scatter(ftm_mean_posiRes(:, 1), ftm_mean_posiRes(:, 2));

%%

load('dataCell_moving2.mat')
Main3

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

%%
% 折线图绘制定位中的Y结果
figure;
hold on;
plot(posiRes(:, 2));
plot(ftm_posiRes(:, 2));
plot(ftm_mean_posiRes(:, 2));
legend('原始','intel','mean ');

%%
% 折线图绘制原始 预测 修正后的定位结果
figure;
hold on;
title('X')
plot(KF.X_set(:, 1));
plot(KF.X_set(:, 2));
plot(KF.X_set(:, 3));
legend('观测','预测','修正');

%%
% 折线图绘制原始 预测 修正后的定位结果
figure;
hold on;
title('Y')
plot(KF.X_set(:, 6));
plot(KF.X_set(:, 7));
plot(KF.X_set(:, 8));
legend('观测','预测','修正');

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
