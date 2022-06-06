
function [Pos_X,Pos_Y] = XYTDOA(time,seqNum)
    Q = eye(3);
    sGa = [1,0;0,1;1,1];
    Pos_X = 0;
    Pos_Y = 0;
    
    anchorPosition;

    BS_X_MIN = Anchor1PosX;
    BS_X_MAX = Anchor1PosX;
    BS_Y_MIN = Anchor1PosY;
    BS_Y_MAX = Anchor1PosY;

    BS = [Anchor1PosX,Anchor1PosY;Anchor2PosX,Anchor2PosY;Anchor3PosX,Anchor3PosY;Anchor4PosX,Anchor4PosY];

    for i = 1:3
        if BS_X_MAX < BS(i+1,1)
            BS_X_MAX = BS(i+1,1);
        end
        if BS_Y_MAX < BS(i+1,2)
            BS_Y_MAX = BS(i+1,2);
        end
        if BS_X_MIN > BS(i+1,1)
            BS_X_MIN = BS(i+1,1);
        end
        if BS_Y_MIN > BS(i+1,2)
            BS_Y_MIN = BS(i+1,2);
        end
    end

    R21 = abs((time(2)-time(1))*C);
    R31 = abs((time(3)-time(1))*C);
    R41 = abs((time(4)-time(1))*C);

    fprintf("%d: R2-R1=%d m,R3-R1=%d m,R4-R1=%d m\n",seqNum, R21,R31,R41);
    global rMinus;
    rMinus = [rMinus;seqNum,R21,R31,R41];
    h = [0.5*(power(R21,2)-K2+K1);0.5*(power(R31,2)-K3+K1);0.5*(power(R41,2)-K4+K1)];

    x21 = Anchor2PosX - Anchor1PosX;
    x31 = Anchor3PosX - Anchor1PosX;
    x41 = Anchor4PosX - Anchor1PosX;

    y21 = Anchor2PosY - Anchor1PosY;
    y31 = Anchor3PosY - Anchor1PosY;
    y41 = Anchor4PosY - Anchor1PosY;

    Ga = [-x21,-y21,-R21;-x31,-y31,-R31;-x41,-y41,-R41];

%     Calculate_Za0
    temp0 = Inverse(Ga' * Ga);
    Za0 = temp0 * Ga' * h;
    
%     Calculate_FI
    B = [sqrt(power(BS(2,1)-Za0(1),2) + power(BS(2,2)-Za0(2),2)),0,0;0,sqrt(power(BS(3,1)-Za0(1),2) + power(BS(3,2)-Za0(2),2)),0;0,0,sqrt(power(BS(4,1)-Za0(1),2) + power(BS(4,2)-Za0(2),2))];
    FI = B * Q * B;
    FI = FI * power(C,2);

%     Calculate_Za1
    temp1 = Inverse(FI);
    temp2 = Inverse(Ga' * temp1 * Ga);
    Za1 = temp2 * Ga' * temp1;
    Za1 = Za1 * h;

    if Za1(3)<0
        Za1(3) = -Za1(3);
    end

    Ba2 = [Za1(1) - BS(1,1),0,0;0,Za1(2) - BS(1,2),0;0,0,Za1(3)];

%     Calculate_sFI   
%     CovZa = Inverse(Ga' * inv(FI) * Ga);
    sFI = Ba2 * temp2 * Ba2;
    sFI = 4 * sFI;

    sh = [power(Za1(1) - BS(1,1),2);power(Za1(2) - BS(1,2),2);power(Za1(3),2)];

%     Calculate_Za2 = inv(sGa' * Inverse(sFI) * sGa) * sGa' * inv(sFI)
    temp3 = Inverse(sFI);
    temp4 = sGa' * temp3 * sGa;
    temp5 = Inverse(temp4);
    Za2 = temp5 * sGa' * temp3;
    Za2 = Za2 * sh;

%     Calculate_POS
    POS = [sqrt(Za2(1)) + Anchor1PosX,sqrt(Za2(2)) + Anchor1PosY;-sqrt(Za2(1)) + Anchor1PosX,-sqrt(Za2(2)) + Anchor1PosY;sqrt(Za2(1)) - Anchor1PosX,sqrt(Za2(2)) - Anchor1PosY;-sqrt(Za2(1)) - Anchor1PosX,-sqrt(Za2(2)) - Anchor1PosY];
    for i = 1:4
        if (POS(i,1) < BS_X_MAX) && (POS(i,1) > BS_X_MIN)
            Pos_X = POS(i,1);
        end
    end

    for i = 1:4
        if (POS(i,2) < BS_Y_MAX) && (POS(i,2) > BS_Y_MIN)
            Pos_Y = POS(i,2);
        end
    end

end

