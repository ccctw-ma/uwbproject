
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

% 基站之间进行拟合的参数矩阵
anchorFittingParamsMatrix = zeros(4, 4, 2);

% 基站时间拟合的窗口值 这个需要根据实际情况进行动态变化
window = 8;

% 各个基站接受到标签发送信号的时间
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


global tempY12Matrix;
global tempX2MatrixBase3;
global tempK21;
global tempB21;

tempY12Matrix = zeros(window, 1);
tempX2MatrixBase3 = zeros(window, 1);
tempK21 = 1;
tempB21 = 0;

global seqCount2;
global seqCount3;
global lastIndex2;
global lastIndex3;
seqCount2 = 1;
seqCount3 = 1;
lastIndex2 = 0;
lastIndex3 = 0;

% 拟合基站接受标签信号使用
global labelToAnchorTimeFittingMatrix;
global fittingParamsMatrix;
global hasFitted;

labelToAnchorTimeFittingMatrix = zeros(4, window, 2);
fittingParamsMatrix = [1, 0; 1, 0; 1, 0; 1, 0];
hasFitted = 0;

global rMinus;
global posiRes;
global timeAfter;
global timeBefore;

rMinus = [];
posiRes = [];
timeAfter = [];
timeBefore = [];

global distance_label_anchor1;
distance_label_anchor1 = [];
