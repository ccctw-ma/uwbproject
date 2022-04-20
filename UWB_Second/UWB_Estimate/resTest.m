
%%
figure;
scatter(posiRes(:, 1), posiRes(:, 2));
hold on;
scatter(kal_posiRes(:, 1), kal_posiRes(:, 2));
scatter(mean_posiRes(:, 1), mean_posiRes(:, 2));


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
colors = linspace(1, 256, length(mean_posiRes));
% scatter(kalmanPosiRes(:,1),kalmanPosiRes(:,2), [], colors, 'filled');
scatter3(mean_posiRes(:,1),mean_posiRes(:,2), 1:length(mean_posiRes), [], colors, 'filled');