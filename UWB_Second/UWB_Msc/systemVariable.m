systemConstant;


% global anchorInteractionTimeMatrix;
% global anchorInteractionSeqMatrix;
% global anchorFittingParamsMatrix;
% global anchorRxTime;
% global lastIndexs;
% global tempFittingMatrix;
% global tempFittingMatrixSize;

% 基站之间交互的时间矩阵
anchorInteractionTimeMatrix = zeros(anchorNum, anchorNum, dataPollingTimes);

% 基站之间交互的序号矩阵
anchorInteractionSeqMatrix = zeros(anchorNum, anchorNum, 1) + 1;

% 基站之间进行拟合的参数矩阵 y = ax + b, 这里保存 a 和 b;
anchorFittingParamsMatrix = zeros(anchorNum, anchorNum, 2) + 1;

% 各个基站接受到标签发送信号的时间
anchorRxTime = zeros(dataPollingTimes, anchorNum);

% 时间拟合中上一次存储的序号
lastIndexs = zeros(1, anchorNum);

% 时间拟合用到的矩阵 用来存储需要拟合的数据  
tempFittingMatrix = zeros(anchorNum, anchorNum, windowSize);

% 时间拟合矩阵当前的的大小
tempFittingMatrixSize = zeros(1, anchorNum) + 1;



global rMinus;
global posiRes;
global timeAfter;
global timeBefore;
global distance_label_anchor1;

rMinus = [];
posiRes = [];
timeAfter = [];
timeBefore = [];
distance_label_anchor1 = [];