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