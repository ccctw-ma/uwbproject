R1 = 4.279;
R2 = 3.077;
R3 = 4.184;
R4 = 5.18;
R = [abs(R2 - R1), abs(R3 - R1), abs(R4 - R1)];
res = abs(rMinus(:,2:4)-R(:,1:3));
res(res > 10) = 0;
mean(res , 1)
cdfplot(res(:,1));
hold on;
cdfplot(res(:,2));
cdfplot(res(:,3));
legend('R2-R1','R3-R1','R4-R1');