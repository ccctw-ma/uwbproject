
%global_Name

% anchor name
Anchor1 = 'F5024552';
Anchor2 = 'F5226439';     
Anchor3 = 'F5024549';
Anchor4 = 'F5226354';
Anchors = [Anchor1,Anchor2,Anchor3,Anchor4];
% AnchorName Index map
AnchorMap = containers.Map({'F5024552','F5226439','F5024549','F5226354'} , {1,2,3,4});

Label = '05C78E1B';

dataPollingTimes = 256;

% 基站时间拟合的窗口值 这个需要根据实际情况进行动态变化
window = 8;
