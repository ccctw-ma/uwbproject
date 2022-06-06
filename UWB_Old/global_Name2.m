
% 基站之间交互的时间矩阵
global anchorInteractionTimeMatrix;
anchorInteractionTimeMatrix = zeros(4,4,256);

% 基站之间交互的序号矩阵
global anchorInteractionSeqMatrix;
anchorInteractionSeqMatrix = zeros(4,4,1) + 1;

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

global haveNullOrDataCount;
global rMinus;
global posiRes;
global timeAfter;
global timeBefore;

haveNullOrDataCount = 0;
rMinus = [];
posiRes = [];
timeAfter = [];
timeBefore = [];