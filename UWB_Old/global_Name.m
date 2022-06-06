
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

% 基站之间交互的时间矩阵
anchorInteractionTimeMatrix = zeros(4,4,256);

% 基站之间交互的序号矩阵
anchorInteractionSeqMatrix = zeros(4,4,1) + 1;

% 基站时间拟合的窗口值 这个需要根据实际情况进行动态变化
window = 8;

% 各个基站接受到标签发送信号的时间
global anchorRxTime;
anchorRxTime = zeros(256,4);

global tempY23Matrix;
global tempY24Matrix;
global tempX2Matrix;
global tempK23;
global tempB23;
global tempK24;
global tempB24;

% global anchorRxTime;

tempY23Matrix = zeros(window,1);
tempY24Matrix = zeros(window,1);
tempX2Matrix = zeros(window,1);


% 线性拟合的参数
tempK23 = 1;
tempB23 = 0;
tempK24 = 1;
tempB24 = 0;

global rMinus;
global posiRes;
global timeAfter;
global timeBefore;

rMinus = [];
posiRes = [];
timeAfter = [];
timeBefore = [];
