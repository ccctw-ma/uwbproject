%%

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


abs_distance_mean = [];
for i = 1 : length(mean_posiRes)
    x = mean_posiRes(i, 1);
    y = mean_posiRes(i, 2);
    d = sqrt((x - pos_x_hat) ^ 2 + (y - pos_y_hat) ^ 2);
    abs_distance_mean = [abs_distance_mean; d];
end
cdfplot(abs_distance_mean);



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