% %52
% Anchor1PosX = 0.35;
% Anchor1PosY = 0.15;

% %51
% Anchor2PosX = 6.65;
% Anchor2PosY = 0.15;

% %49
% Anchor3PosX = 6.65;
% Anchor3PosY = 4.85;

% %54
% Anchor4PosX = 0.35;
% Anchor4PosY = 4.85;

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
% labelY = 2.0;
labelX = 4.4;
labelY = 1.85;
% labelX = 3.15;
% labelY = 2.35;
% labelX = 4.75;
% labelY = 2;
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
     ];