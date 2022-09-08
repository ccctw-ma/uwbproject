
%%
% 以散点图的形式绘制定位结果

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
for i = 1 : 0.01 : 7
    point_hat_set = [point_hat_set; i, 3.5];
end

for j = 0.5 : 0.01 : 3.5
    point_hat_set = [point_hat_set; 1, j];
end

for i = 1 : 0.01 : 7
    point_hat_set = [point_hat_set; i, 0.5];
end

scatter(point_hat_set(:, 1), point_hat_set(:, 2));
scatter(posiRes(:, 1), posiRes(:, 2), 'blue');
scatter(kal_posiRes(:, 1), kal_posiRes(:, 2), 'r');
% scatter(KF.smooth_posiRes(:, 1), KF.smooth_posiRes(:, 2));
% scatter(kal_mean_posiRes(:, 1), kal_mean_posiRes(:, 2));
% scatter(mean_posiRes(:, 1), mean_posiRes(:, 2));
% scatter(ftm_posiRes(:, 1), ftm_posiRes(:, 2));
% scatter(ftm_mean_posiRes(:, 1), ftm_mean_posiRes(:, 2));


%%
% 折线图绘制定位中的X结果
figure;
hold on;
plot(posiRes(:, 1));
plot(ftm_posiRes(:, 1));
% plot(ftm_mean_posiRes(:, 1));
legend('原始','intel','mean ');

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
figure;
plot(kalmanDataArr(:, 1:5));
title("X");
% legend('Measured','estimateRes', 'kalmanRes','meanRes','kalmanGain');
legend('Measured','estimateRes', 'kalmanRes','kalmanGain', 'vx');
%%
figure;
plot(kalmanDataArr(:, 6:10));
title("Y");

% legend('Measured','estimateRes', 'kalmanRes','meanRes','kalmanGain');
legend('Measured','estimateRes', 'kalmanRes','kalmanGain', 'vy');
%%
% 以三维散点图的形式绘制定位结果


colors = linspace(1, 256, length(posiRes));
% scatter(kalmanPosiRes(:,1),kalmanPosiRes(:,2), [], colors, 'filled');
scatter3(posiRes(:,1),posiRes(:,2), 1:length(posiRes), [], colors, 'filled');
% scatter3(ftm_mean_posiRes(:,1), ftm_mean_posiRes(:,2), 1:length(posiRes), [], colors, 'filled');
