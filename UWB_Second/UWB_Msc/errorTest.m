figure();
hold on;
axis equal;
scatter(timeBefore(:, 1), timeBefore(:, 2), 'r', 'o');
scatter(abnormalRes(:,1 ), abnormalRes(:, 2), 'blue', '*');

%%
% 计算异常数据时的到达距离差

tds = [];
for i = 1 : size(abnormalRes)
    t1 = abnormalRes(i, 2);
    t2 = abnormalRes(i, 3);
    t3 = abnormalRes(i, 4);
    t4 = abnormalRes(i, 5);
    td_21 = (t2 - t1);
    td_31 = (t3 - t1);
    td_41 = (t4 - t1);
    tds = [tds; td_21, td_31, td_41];
end
%%


figure;
plot(Xs);
legend('Measured', 'Estimate', 'KalmanRes','meanRes', 'KalmanGain');


%%
% 基于卡尔曼滤波对达到距离差进行处理
% 通过点随时间变化绘制运动轨迹的散点图
% figure();
% hold on;
% axis equal;
% sz = linspace(5, 100, length(posiRes));
% colors = linspace(1, 256, length(posiRes));
% scatter3(posiRes(:,1),posiRes(:,2), 1 : length(posiRes),[], colors, 'filled');
colors = linspace(1, 256, length(kalmanPosiRes));
% scatter(kalmanPosiRes(:,1),kalmanPosiRes(:,2), [], colors, 'filled');
scatter3(kalmanPosiRes(:,1),kalmanPosiRes(:,2), 1:length(kalmanPosiRes), [], colors, 'filled');

%%
% 附带xy轴加速度的轨迹预测对比
figure();
hold on;
scatter(kalmanPosiRes(:, 1), kalmanPosiRes(:, 2), 'r');
scatter(Xs(:, 1), Xs(:, 4), 'blue');

%%
figure();
plot(testDataArr(:, 1: 5));
legend('Measured', 'Estimate', 'KalmanRes','meanRes', 'KalmanGain');
%% 
figure();
plot(testDataArr(:, 6: 10));
legend('Measured', 'Estimate', 'KalmanRes','meanRes', 'KalmanGain');
%%
figure();
plot(testDataArr(:, 10: 15));
legend('Measured', 'Estimate', 'KalmanRes','meanRes', 'KalmanGain');

%%
figure();


%%
% 检验基站之间交互时间矫正的效果
plot(anchorInteractionInfos{1, 2}(:, 1:2));
hold on;
plot(anchorInteractionInfosAfterCorrect{1, 2});
hold off;
