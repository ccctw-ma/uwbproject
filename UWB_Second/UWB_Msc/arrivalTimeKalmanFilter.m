% 对标签到达基站的时间进行卡尔曼滤波处理
% function [ftime, variance, preTime] = arrivalTimeKalmanFilter(preTime, variance, time_set,time)
%     a0 = variance;
%     a1 = var(time_set, 1);
%     k = a0 / (a0 + a1);
%     ftime = preTime + k * (time - preTime);
%     preTime = ftime;
%     variance = k * a1;
% end



% 通过取均值的方式对数据进行平滑
% function R = arrivalTimeKalmanFilter(R)
    
%     global pre_R;
%     global set_R;
%     global pre_Rs;
%     global vars_R;
%     global vars_set_R;
%     global testDataArr;
%     set_size = 5;
%     num_R = 3;

%     for i = 1 : num_R
%         for j = 1 : set_size - 1
%             vars_set_R(j, i) = vars_set_R(j + 1, i);
%         end
%     end
%     for i = 1 : num_R
%         vars_set_R(set_size, i) = R(i);
%     end
%     v = var(vars_set_R);
%     vars_R = [vars_R; v];


    

%     for i = 1 : num_R
%         if abs(R(i)) > 8 
%             R(i) = pre_R(i);
%         end
%     end
%     temp = [R(1)];
%     pre_R = R;
%     pre_Rs = [pre_Rs; pre_R];
%     for i = 1 : num_R
%         for j = 1 : set_size - 1
%             set_R(i, j) = set_R(i, j + 1);
%         end
%     end
%     for i = 1 : num_R
%         set_R(i, set_size) = R(i);
%         R(i) = sum(set_R(i, :)) / set_size;
%     end
%     temp(end + 1) = R(1);
%     testDataArr = [testDataArr; temp];
% end
    
% 对数据进行预测
% function R = arrivalTimeKalmanFilter(R, time)
    
%     global R_X_n_n;
%     global R_P_n_n;
%     global preTime;


%     global testDataArr;


%     if sum(preTime) == -4
%         dt = 0.5;
%     else
%         dt = mean(time - preTime);
%     end
%     preTime = time;

%     F = [
%         1, dt;
%         0, 1
%     ];
%     % 预测噪声
%     Q = eye(2);
%     H = [1, 0];
%     % 观测噪声
%     mR = 1;

%     R_X_n1_n = F * R_X_n_n;
%     for i = 1 : 3
%         R_P_n1_n(:, :, i) = F * R_P_n_n(:, :, i) * F' + Q;
%         K(:, i) = R_P_n1_n(:, :, i) * H' * inv(H * R_P_n1_n(:, :, i) * H' + mR);
%         if abs(R(i)) > 8
%             R(i) = R_X_n1_n(1, i);
%         end
%         R_X_n1_n1(:, i) = R_X_n1_n(:, i) + K(:, i) * (R(i) - H * R_X_n1_n(:, i));
%         R_P_n1_n1(:, :, i) = R_P_n1_n(:, :, i) - K(:, i) * H * R_P_n1_n(:, :, i);
       
%     end
%     testDataArr = [testDataArr;R(1), R_X_n1_n(1, 1), R_X_n1_n1(1, 1), K(1, 1), K(2, 1)];

%     R_X_n_n = R_X_n1_n1;
%     K_n = K;
%     R_P_n_n = R_P_n1_n1;
%     R = R_X_n_n(1, :);
% end
    



function R = arrivalTimeKalmanFilter(R)
    
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
        if abs(R(i)) > 8 || abs(R(i) - R_X_n1_n(i)) > 5
            R(i) = R_X_n1_n(i);
        end
        for j = 1 : var_set_size - 1
            vars_set_R(i, j) = vars_set_R(i, j + 1);
        end 
        vars_set_R(i, var_set_size) = R(i);
        % 这一时间段的观测噪声
        mR = var(vars_set_R(i, :));
        
        R_P_n1_n(i) = R_P(i)  + Q;
        K(i) = R_P_n1_n(i) * H' * inv(H * R_P_n1_n(i) * H' + mR);
        R_X_n1_n1(i) = R_X_n1_n(i) + K(i) * (R(i) - H * R_X_n1_n(i));


        % 对数据求平均进行平滑
        for j = 1 : sum_set_size - 1
            sum_set_R(i, j) = sum_set_R(i, j + 1);
        end 
        sum_set_R(i, sum_set_size) = R_X_n1_n1(i);
        R(i) = mean(sum_set_R(i, :));
        R_P_n1_n1(i) = R_P_n1_n(i) - K(i) * H * R_P_n1_n(i);
       
    end
    R_X = R_X_n1_n1;
    R_P = R_P_n1_n1;
   
    testDataArr = [testDataArr;R(1), R_X_n1_n1(1), R_P_n1_n1(1), K(1)];
end
    