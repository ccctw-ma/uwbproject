function [X, Y] = chanNumOfAnchor3(R)
    anchorPosition;
    global distance_label_anchor1;
    x1 = Anchor1PosX;
    y1 = Anchor1PosY;
    y21 = Anchor2PosY - Anchor1PosY;
    y31 = Anchor3PosY - Anchor1PosY;
    x21 = Anchor2PosX - Anchor1PosX;
    x31 = Anchor3PosX - Anchor1PosX;

    r21 = R(1);
    r31 = R(2);

    global rMinus;
    rMinus = [rMinus;r21, r31];


    G0 = [x21, y21; x31, y31];
    G0 = Inverse(G0);

    tempK1 = (K2 - K1 - r21^2) / 2;
    tempK2 = (K3 - K1 - r31^2) / 2;

    p1 = (G0(1, 1) * tempK1 + G0(1, 2) * tempK2) / 2;
    q1 = -(G0(1, 1) * r21 + G0(1, 2) * r31);
    p2 = (G0(2, 1) * tempK1 + G0(2, 2) *tempK2) / 2;
    q2 = -(G0(2, 1) * r21 + G0(2, 2) * r31);
    a = power(q1, 2) + power(q2, 2) - 1;
    b = 2 * (p1 * q1 + p2 * q2 - x1 * q1 - y1 * q2);
    c = K1 - 2 * x1 * p1 - 2 * y1 * p2 + p1 ^ 2 + p2 ^ 2;
    t = b ^ 2 - 4 * a * c;
    X = 0;
    Y = 0;
    res1 = (-b + sqrt(t)) / (2 * a);
    res2 = (-b - sqrt(t)) / (2 * a);
    % distance_label_anchor1 = [distance_label_anchor1; res1, res2];
    if res1 >= 0 
        X = (p1 + q1 * res1) * 2;
        Y = (p2 + q2 * res1) * 2;
    else
        X = (p1 + q1 * res2) * 2;
        Y = (p2 + q2 * res2) * 2;
    end 



end