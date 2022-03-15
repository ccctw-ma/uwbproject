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

x = [1,2,3,4,5]
y = [4,5,6,7,9]
p = polyfit(x,y,1)
length(find(x(2:4)~=0))


% 删除定位结果里的全0行
posiRes(all(posiRes == 0, 2), : ) = [];
% 列的均值
res_mean = mean(posiRes, 1);
fprintf("定位结果均值 X: %f, Y: %f\n", res_mean(1), res_mean(2));
% 列元素的标准差
res_std = std(posiRes, 0 , 1);
fprintf("定位结果标准差 X: %f, Y: %f\n", res_std(1), res_std(2));