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

nexttile(1)
hold on;
scatter(posiRes(:, 1), posiRes(:, 2), 'blue');
scatter(kal_posiRes(:, 1), kal_posiRes(:, 2), 'r');
% filePath = "C:\Users\Lenovo\IdeaProjects\uwb_Java\src\data\output.txt";
% fid = fopen(filePath);
% ff = fread(fid);
% ends = find(ff == 10);
% index = 1;
% data = [];
% for i = 1 : length(ends)
%     e = ends(i);
%     ss = ff(index: e - 1);
%     ss = char(ss);
%     data_row = strsplit(ss', ',');
%     data = [data; data_row];
%     index = e + 1;
% end
% 
% arr = zeros(size(data));
% for i = 1 : length(data)
%     for j = 1 : 2
%         temp = data(i, j);
%         arr(i, j) = str2double(temp{1, 1});
%     end
% end
% scatter(arr(:,1),arr(:,2));
% 
% diff = [];
% for i = 1 : length(data)
%     diff = [diff; norm(kal_posiRes(i, :) - arr(i, :))];
% end
% max(diff)
% mean(diff)
title('滤波后结果');
legend('raw', 'kf', 'java')
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


nexttile(3);
scatter3(posiRes(:,1),posiRes(:,2), 1:length(posiRes), [], linspace(1, 256, length(posiRes)), 'filled');

nexttile(4);
hold on;
plot(KF.real_time_data_resSet(:, 7));
plot(KF.real_time_data_resSet(:, 8));
plot(ones(length(KF.real_time_data_resSet), 1) * 0.5);
title('速度');
hold off;

nexttile(5);
hold on;
scatter(KF.static_mea_arr(:, 1), KF.static_mea_arr(:, 2), 'yellow');
scatter(KF.outrange_mea_arr(:, 1), KF.outrange_mea_arr(:, 2), 'magenta');
scatter(KF.unValid_mea_arr(:, 1), KF.unValid_mea_arr(:, 2), 'green');
legend('static', 'outrange', 'unvalid');
title('不同情况的数据');

hold off;



nexttile(6);
hold on;
plot(kalmanDataArr(:, 6:9));
plot(KF.real_time_data_resSet(:, 4));
plot(KF.real_time_data_resSet(:, 5));
plot(KF.real_time_data_resSet(:, 6));
title("Y");
legend('Measured', 'estimateRes', 'kalmanRes', 'kalmanGain', 'posiVar', 'velocity', 'velVar');
hold off;

nexttile(7);
scatter3(kal_posiRes(:,1), kal_posiRes(:,2), 1:length(kal_posiRes), [], linspace(1, 256, length(kal_posiRes)), 'filled');

nexttile(8);
plot(KF.static_step_set);
title('static step');

return
%%

% t = [1, 2, 3, 4; 
%      1, 1, 4, 5;
%      3, 5, 6, 7;
%      1, 3, 1, 44];
% inv(t)
t = [1, 2, 3, 4, 5;
     2, 2, 2, 2, 2]
var(t, 0, 2)


