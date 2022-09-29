function [X, Y] = chanNumOfAnchorLarge(R, i, j)
    anchorPosition;
    x1 = Anchor1PosX;
    y1 = Anchor1PosY;
    y21 = Anchor2PosY - Anchor1PosY;
    y31 = Anchor3PosY - Anchor1PosY;
    x21 = Anchor2PosX - Anchor1PosX;
    x31 = Anchor3PosX - Anchor1PosX;
    r21 = R(1);
    r31 = R(2);

   
    syms x y;
    f1 = sqrt((x - 6.3) ^ 2 + y ^ 2) - sqrt(x ^ 2 + y ^ 2) -  r21 == 0;
    f2 = sqrt((x - 6.3) ^ 2 + (y - 4.7) ^ 2) - sqrt(x ^ 2 + y ^ 2) - r31 == 0;      
    [x ,y]=solve(f1, f2, x, y);
    if length(x) == 0
        X = 0;
    else
        X = double(x);
    end
    if length(y) == 0
        Y = 0;
    else
        Y = double(y);
    end
end



