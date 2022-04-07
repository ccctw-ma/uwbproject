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
windowSize = 4;

% 基站数量
anchorNum = 4;

% 接受标签后信号存活的窗口期
labelReceiveWindow = 32;

%52
Anchor1PosX = 0;
Anchor1PosY = 0;

%51
Anchor2PosX = 6.3;
Anchor2PosY = 0;

%49
Anchor3PosX = 6.3;
Anchor3PosY = 4.7;

%54
Anchor4PosX = 0;
Anchor4PosY = 4.7;

%Ki是chan方法里的 常量 xi^2 + yi^2 （xi,yi）是基站位置
K1 = power(Anchor1PosX, 2) + power(Anchor1PosY, 2);
K2 = power(Anchor2PosX, 2) + power(Anchor2PosY, 2);
K3 = power(Anchor3PosX, 2) + power(Anchor3PosY, 2);
K4 = power(Anchor4PosX, 2) + power(Anchor4PosY, 2);

%基站间的距离
distance21 = sqrt(power(Anchor2PosX - Anchor1PosX,2) + power(Anchor2PosY - Anchor1PosY,2)); 
distance31 = sqrt(power(Anchor3PosX - Anchor1PosX,2) + power(Anchor3PosY - Anchor1PosY,2));
distance41 = sqrt(power(Anchor4PosX - Anchor1PosX,2) + power(Anchor4PosY - Anchor1PosY,2));
distance23 = sqrt(power(Anchor3PosX - Anchor2PosX,2) + power(Anchor3PosY - Anchor2PosY,2));
distance24 = sqrt(power(Anchor4PosX - Anchor2PosX,2) + power(Anchor4PosY - Anchor2PosY,2));
distance34 = sqrt(power(Anchor4PosX - Anchor3PosX,2) + power(Anchor4PosY - Anchor3PosY,2));

%信号传输速度
C = 299792458;

% labelX = 4.75;
labelX = 4.3;
% labelY = 2.0;
labelY = 1.85;
labelZ = 1.20;
anchorZ = 2.7;

% 标签到各个基站的距离
R1 = sqrt(power(Anchor1PosX - labelX, 2) + power(Anchor1PosY - labelY, 2));
R2 = sqrt(power(Anchor2PosX - labelX, 2) + power(Anchor2PosY - labelY, 2));
R3 = sqrt(power(Anchor3PosX - labelX, 2) + power(Anchor3PosY - labelY, 2));
R4 = sqrt(power(Anchor4PosX - labelX, 2) + power(Anchor4PosY - labelY, 2));
R21 = R2 - R1;
R31 = R3 - R1;
R41 = R4 - R1;

BSN = 4;
BS = [
       Anchor1PosX, Anchor2PosX, Anchor3PosX, Anchor4PosX; 
       Anchor1PosY, Anchor2PosY, Anchor3PosY, Anchor4PosY;
       2.7, 2.7, 2.7, 2.7
      % 0, 0, 0, 0
     ];
