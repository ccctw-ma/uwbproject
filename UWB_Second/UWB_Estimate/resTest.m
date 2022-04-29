
%%
% 以散点图的形式绘制定位结果
figure;
axis equal
scatter(posiRes(:, 1), posiRes(:, 2));
hold on;
% scatter(kal_posiRes(:, 1), kal_posiRes(:, 2));
% scatter(mean_posiRes(:, 1), mean_posiRes(:, 2));
scatter(ftm_posiRes(:, 1), ftm_posiRes(:, 2),'r');
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
legend('Measured','estimateRes', 'kalmanRes','meanRes','kalmanGain');

%%
figure;
plot(kalmanDataArr(:, 6:10));
title("Y");
legend('Measured','estimateRes', 'kalmanRes','meanRes','kalmanGain');

%%
% 以三维散点图的形式绘制定位结果


colors = linspace(1, 256, length(posiRes));
% scatter(kalmanPosiRes(:,1),kalmanPosiRes(:,2), [], colors, 'filled');
% scatter3(posiRes(:,1),posiRes(:,2), 1:length(posiRes), [], colors, 'filled');
scatter3(ftm_mean_posiRes(:,1), ftm_mean_posiRes(:,2), 1:length(posiRes), [], colors, 'filled');
