%52
Anchor1PosX = 0.35;
Anchor1PosY = 0.15;

%51
Anchor2PosX = 6.65;
Anchor2PosY = 0.15;

%49
Anchor3PosX = 6.65;
Anchor3PosY = 4.85;

%54
Anchor4PosX = 0.35;
Anchor4PosY = 4.85;

%Ki是chan方法里的 常量 xi^2 + yi^2 （xi,yi）是基站位置
K1 = power(Anchor1PosX,2) + power(Anchor1PosY,2);
K2 = power(Anchor2PosX,2) + power(Anchor2PosY,2);
K3 = power(Anchor3PosX,2) + power(Anchor3PosY,2);
K4 = power(Anchor4PosX,2) + power(Anchor4PosY,2);

%基站间的距离
distance21 = sqrt(power(Anchor2PosX - Anchor1PosX,2) + power(Anchor2PosY - Anchor1PosY,2)); 
distance31 = sqrt(power(Anchor3PosX - Anchor1PosX,2) + power(Anchor3PosY - Anchor1PosY,2));
distance41 = sqrt(power(Anchor4PosX - Anchor1PosX,2) + power(Anchor4PosY - Anchor1PosY,2));
distance23 = sqrt(power(Anchor3PosX - Anchor2PosX,2) + power(Anchor3PosY - Anchor2PosY,2));
distance24 = sqrt(power(Anchor4PosX - Anchor2PosX,2) + power(Anchor4PosY - Anchor2PosY,2));
distance34 = sqrt(power(Anchor4PosX - Anchor3PosX,2) + power(Anchor4PosY - Anchor3PosY,2));

%信号传输速度
C = 3 * 10^8;