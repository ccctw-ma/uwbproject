function [X, Y] = chan_base_3(R)
    systemConstant;
    res = [];
    for i = 2 : BSN - 1
        for j = i + 1 : BSN
            x_i1 = BS(1, i) - BS(1, 1);
            y_i1 = BS(2, i) - BS(2, 1);
            x_j1 = BS(1, j) - BS(1, 1);
            y_j1 = BS(2, j) - BS(2, 1);
            r_i1 = R(i - 1);
            r_j1 = R(j - 1);
            Ki = BS(1, i) ^ 2 + BS(2, i) ^ 2;
            Kj = BS(1, j) ^ 2 + BS(2, j) ^ 2;
            G0 = Inverse([x_i1, y_i1; x_j1, y_j1]);
            tKi = 0.5 * (Ki - K1 - r_i1 ^ 2);
            tKj = 0.5 * (Kj - K1 - r_j1 ^ 2);
            p1 = G0(1, 1) * tKi + G0(1, 2) * tKj;
            q1 = -(G0(1, 1) * r_i1 + G0(1, 2) * r_j1);
            p2 = G0(2, 1) * tKi + G0(2, 2) * tKj;
            q2 = -(G0(2, 1) * r_i1 + G0(2, 2) * r_j1);
            a = power(q1, 2) + power(q2, 2) - 1;
            b = 2 * (p1 * q1 + p2 * q2 - BS(1, 1) * q1 - BS(2, 1) * q2);
            c = K1 - 2 * BS(1, 1) * p1 - 2 * BS(2, 1) * p2 + p1 ^ 2 + p2 ^ 2;
            delta = b ^ 2 - 4 * a * c;
            if delta < 0
                x = 0;
                y = 0;
            else
                res1 = (-b + sqrt(delta)) / (2 * a);
                res2 = (-b - sqrt(delta)) / (2 * a);
                if res1 >= 0 && res1 <=  maxDistance
                    x = (p1 + q1 * res1);
                    y = (p2 + q2 * res1);
                elseif res2 >= 0 && res2 <=  maxDistance
                    x = (p1 + q1 * res2);
                    y = (p2 + q2 * res2);
                else
                    x = 0;
                    y = 0;
                end
            end
            res = [res; x, y];
        end
    end
    w = [0.8, 0.1, 0.1];
    X = 0;
    Y = 0;
    for i = 1 : (BSN - 1) * (BSN - 2) / 2
        X = X + res(i, 1) * w(i);
        Y = Y + res(i, 2) * w(i);
    end
end




