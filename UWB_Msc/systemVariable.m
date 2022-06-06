systemConstant;


global anchorInteractionTimeMatrix;
global anchorInteractionSeqMatrix;
global anchorFittingParamsMatrix;
global anchorRxTime;
global lastIndexs;
global tempFittingMatrix;
global tempFittingMatrixSize;

% 基站之间交互的时间矩阵
anchorInteractionTimeMatrix = zeros(anchorNum, anchorNum, dataPollingTimes);

% 基站之间交互的序号矩阵
anchorInteractionSeqMatrix = zeros(anchorNum, anchorNum, 1);

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





global tempY23Matrix;
global tempY24Matrix;
global tempX2Matrix;
global tempK23;
global tempB23;
global tempK24;
global tempB24;
tempY23Matrix = zeros(windowSize,1);
tempY24Matrix = zeros(windowSize,1);
tempX2Matrix = zeros(windowSize,1);
% 线性拟合的参数
tempK23 = 1;
tempB23 = 0;
tempK24 = 1;
tempB24 = 0;
global tempY12Matrix;
global tempX2MatrixBase3;
global tempK21;
global tempB21;

tempY12Matrix = zeros(windowSize, 1);
tempX2MatrixBase3 = zeros(windowSize, 1);
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

global posiRes;
global timeAfter;
global timeBefore;

posiRes = [];
% 同步前的数据
timeBefore = [];
% 同步后的数据
timeAfter = [];
% 过滤没能正确同步的数据
timeAfterFilter = [];


% 使用卡尔曼滤波处理时钟差
global R_X_n_n;
global R_P_n_n;
% 求观测噪声使用的观测数据集合
global vars_set_R;
global var_set_size;
% 平滑数据使用的过滤数据集合
global sum_set_R;
global sum_set_size;


% R_X = zeros(3, 1);
% R_P = zeros(3, 1) * 100;
% var_set_size = 3;
% sum_set_size = 10;
% vars_set_R = zeros(3, var_set_size);
% sum_set_R = zeros(3, sum_set_size);


R_X_n_n = zeros(2, 3);
R_P_n_n = ones(2, 2, 3) * 100;
var_set_size = 5;
sum_set_size = 10;
vars_set_R = zeros(3, var_set_size);
sum_set_R = ones(3, sum_set_size);

global testDataArr;
testDataArr = [];
