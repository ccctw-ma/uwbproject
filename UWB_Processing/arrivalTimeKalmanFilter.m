% 对标签到达基站的时间进行卡尔曼滤波处理
function res_R = arrivalTimeKalmanFilter(R)
    
    global R_X;
    global R_P;
    global vars_set_R;
    global sum_set_R;
    global testDataArr;
    global var_set_size;
    global sum_set_size;
  

    F = 1;
    % 预测噪声
    Q = 0.05;
    H = 1;
   
    R_X_n1_n = F * R_X;
    for i = 1 : 3
        % 跳动非常大的数据采用之前的值进行替代
        % if abs(R(i)) > 8 || abs(R(i) - R_X_n1_n(i)) > 4
        if abs(R(i)) > 8 
            R(i) = R_X_n1_n(i);
        end

        % 初始化处理
        if sum(vars_set_R(i, :)) == 0
            vars_set_R(i, :) = R(i);
        else
            for j = 1 : var_set_size - 1
                vars_set_R(i, j) = vars_set_R(i, j + 1);
            end
        end 
        vars_set_R(i, var_set_size) = R(i);
        % 这一时间段的观测噪声
        mR = var(vars_set_R(i, :));
        
        R_P_n1_n(i) = R_P(i)  + Q;
        K(i) = R_P_n1_n(i) * H' * inv(H * R_P_n1_n(i) * H' + mR);
        R_X_n1_n1(i) = R_X_n1_n(i) + K(i) * (R(i) - H * R_X_n1_n(i));


        % 对数据求平均进行平滑
        if sum(sum_set_R(i, :)) == 0
            sum_set_R(i, :) =  R_X_n1_n1(i);
        else
            for j = 1 : sum_set_size - 1
                sum_set_R(i, j) = sum_set_R(i, j + 1);
            end
        end 
        sum_set_R(i, sum_set_size) = R_X_n1_n1(i);

        res_R(i) = mean(sum_set_R(i, :));
        R_P_n1_n1(i) = R_P_n1_n(i) - K(i) * H * R_P_n1_n(i);
       
    end
    R_X = R_X_n1_n1;
    R_P = R_P_n1_n1;
    testDataArr = [testDataArr;R(1), R_X_n1_n1(1), res_R(1), K(1), R(2), R_X_n1_n1(2), res_R(2), K(2), R(3), R_X_n1_n1(3), res_R(3), K(3)];
    % res_R = R_X;
end
    