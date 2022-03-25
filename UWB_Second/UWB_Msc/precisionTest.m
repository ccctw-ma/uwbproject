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

% normplot(dR(:, 3));
 histogram(dR(:, 3));
% [H,P,LSTAT,CV] = lillietest(dR(:, 3),0.05)

%%

resPlot([R21, R31, R41], labelX, labelY);