R1 = 4.9;
R2 = 3.1;
R3 = 3.6;
R4 = 5.2;
R = [R2 - R1,R3 - R1, R4 - R1];
res = abs(dR(:,1 : 3)-R(:,1:3));
res(res > 10) = 10;
mean(res , 1)
cdfplot(res(:,1));
hold on;
cdfplot(res(:,2));
cdfplot(res(:,3));
legend('R2-R1','R3-R1','R4-R1');
%% 
figure();
hold on;
axis equal;
scatter(posiRes(:,1),posiRes(:,2));
scatter(labelX, labelY);
%%
dR(abs(dR) > 5) = 0;
dR_mean = mean(dR, 1);
dR(abs(dR) == 0) = dR_mean(1);
cov(dR);
%%
clc;
resPlot([R21, R31, R41], labelX, labelY);

%%

% normplot(dR(:, 3));
%  histogram(dR(:, 3));
% [H,P,LSTAT,CV] = lillietest(dR(:, 3),0.05)

clc;
% dR(abs(dR) > 5) = 0;
time_1 = 0;
timeArr = [];
% time_set = [time_1];
preTime = time_1;
variance = 1;
n = 10;
time_set = ones(n, 1);
for i = 1 : length(dR)
    time = dR(i, 1);
    if abs(time - preTime) > 3
        time = preTime;
  
    end
    preTime = time;


    for j = 1 : n - 1
        time_set(j) = time_set(j + 1);
    end
    time_set(n) = time;
    ftime = sum(time_set) / n;
    ftime
    % time_set(end + 1) = time_1;
    % [ftime, variance, preTime]  = arrivalTimeKalmanFilter(preTime, variance, time_set, time_1);
    timeArr = [timeArr; time, ftime];


end

%%
figure();
hold on;
axis equal;
sz = linspace(1, 100, length(posiRes));
scatter(posiRes(:,1),posiRes(:,2), sz, 'green','+');
scatter(Xs(:, 1), Xs(:, 4), sz, 'red','o');