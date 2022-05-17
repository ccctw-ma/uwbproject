% a = 10;
% b = 100;
% fprintf(" test %d  ", a*b);

% mapObj = containers.Map({'1','2'},{1,2});


% AnchorMap = containers.Map({'F5024552','F5226439','F5024549','F5226354'},{1,2,3,4});

% ismember('F5024552',keys(AnchorMap))

% fprintf("map test %d", AnchorMap('F5226439'));




% fprintf("test   %d", distance21);


% function [s] = test01()
%     % global window;
%     global_Name;
%     anchorPosition;
%     distance21 = 10;
%     fprintf("test %d", distance21);
%     s = 1;
% end    

x = [1,2,3,4,5];
y = [4,5,6,7,9];
p = polyfit(x,y,1);
length(find(x(2:4)~=0));
for i = 0 : 4
    i;
end



% A = [6.3, 0; 6.3, 4.7];
% a = 6.3;
% b = 0;
% c = 6.3;
% d = 4.7;
% D = a * d - b * c;
% RA = [d/D, (-b)/D;(-c)/D, a/D];
% RA
% Inverse(A)
% inv(A)
% pinv(A)
% RA * A
% A * Inverse(A)


% x = 0:0.0025:7;
% y = 0:0.0025:6;
% fy1 = @(x) 0.2*exp(-0.5)*cos(4*pi*x);
% fy2 = @(x) 2*exp(-0.5)*cos(pi*x);
% plot(x,fy1(x),'g',x,fy2(x),'b'); 
% % 观察可知交点在x=0.5，x=1.5附近，用fsolve求解 
% fun = @(x) fy1(x)-fy2(x); 
% x0 = fsolve(fun,[0.5,1.5]) 
% hold on
% plot(x0,fy1(x0),'ro')

% x1 = 0;
% x2 = 6.3;
% y1 = 0;
% y2 = 0;
% x3 = 6.3;
% y3 = 4.7;

% syms x, y;
% [s1, s2] = solve(sqrt((x - 6.3) ^ 2 + (y - 0) ^ 2) - sqrt((x - 0) ^ 2 + (y - 0)^2) - (-2.1212) == 0,sqrt((x - 6.3) ^ 2 + (y - 4.7) ^ 2) - sqrt((x - 0) ^ 2 + (y - 0)^2) - (-1.3478) == 0);
% s1 = double(s1)
% s2 = double(s2)


% syms x y real 
% [S, params, conditions] = solve(x^(1/2) = y, x, 'ReturnConditions', true)

syms x y;
f1 = sqrt((x - 6.3) ^ 2 + y ^ 2) - sqrt(x ^ 2 + y ^ 2) + 2.1212 == 0;
f2 = sqrt((x - 6.3) ^ 2 + (y - 4.7) ^ 2) - sqrt(x ^ 2 + y ^ 2) + 1.3478 == 0;      
[x ,y]=solve(f1,f2,x,y);
double(x)
double(y)