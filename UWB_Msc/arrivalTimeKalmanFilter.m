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
function [kalmanR, meanR] = arrivalTimeKalmanFilter(R, dt)
    
    global R_X_n_n;
    global R_P_n_n;
    global vars_set_R;
    global sum_set_R;
    global var_set_size;
    global sum_set_size;
    global testDataArr;

    F = [1, dt; 0, 1];
    % 预测噪声
    Q = eye(2) * 0.02;
    % 观测数据转移方程
    H = [1, 0];
    

    R_X_n1_n = F * R_X_n_n;
    for i = 1 : 3
        R_P_n1_n(:, :, i) = F * R_P_n_n(:, :, i) * F' + Q;

        % || abs(R(i) - R_X_n1_n(1, i)) > 3
        if abs(R(i)) > 6
            R(i)
            R(i) = R_X_n1_n(1, i);
        end
        for j = 1 : var_set_size - 1
            vars_set_R(i, j) = vars_set_R(i, j + 1);
        end
        vars_set_R(i, var_set_size) = R(i);

        % 观测噪声
        mR = var(vars_set_R(i, :)); 
        K(:, i) = R_P_n1_n(:, :, i) * H' * inv(H * R_P_n1_n(:, :, i) * H' + mR);

        R_X_n1_n1(:, i) = R_X_n1_n(:, i) + K(:, i) * (R(i) - H * R_X_n1_n(:, i));
        R_P_n1_n1(:, :, i) = R_P_n1_n(:, :, i) - K(:, i) * H * R_P_n1_n(:, :, i);

        
        if sum(sum_set_R(i, :)) == sum_set_size
            sum_set_R(i, :) = sum_set_R(i, :) * R_X_n1_n1(1, i);
        end
        for j = 1 : sum_set_size - 1
            sum_set_R(i, j) = sum_set_R(i, j + 1);
        end
        sum_set_R(i, sum_set_size) = R_X_n1_n1(1, i);
        mean_res(i) = mean(sum_set_R(i, :));
    end
    testDataArr = [testDataArr;R(1), R_X_n1_n(1, 1), R_X_n1_n1(1, 1), mean_res(1), K(1, 1), R(2), R_X_n1_n(1, 2), R_X_n1_n1(1, 2), mean_res(2), K(1, 2), R(3), R_X_n1_n(1, 3), R_X_n1_n1(1, 3), mean_res(3), K(1, 3)];

    R_X_n_n = R_X_n1_n1;
    R_P_n_n = R_P_n1_n1;
    kalmanR = R_X_n1_n1(1, :);
    meanR = mean_res;
end
    



% function [R_X, res_R] = arrivalTimeKalmanFilter(R)
    
%     global R_X;
%     global R_P;
%     global vars_set_R;
%     global sum_set_R;
%     global testDataArr;
%     global var_set_size;
%     global sum_set_size;
  

%     F = 1;
%     % 预测噪声
%     Q = 0.05;
%     H = 1;
   
%     R_X_n1_n = F * R_X;
%     for i = 1 : 3
%         % 跳动非常大的数据采用之前的值进行替代
%         % || abs(R(i) - R_X_n1_n(i)) > 4
%         if abs(R(i)) > 8 
%             R(i) = R_X_n1_n(i);
%         end
%         % 初始化处理
%         if sum(vars_set_R(i, :)) == 0
%             vars_set_R(i, :) = R(i);
%         else
%             for j = 1 : var_set_size - 1
%                 vars_set_R(i, j) = vars_set_R(i, j + 1);
%             end
%         end 
%         vars_set_R(i, var_set_size) = R(i);
%         % 这一时间段的观测噪声
%         mR = var(vars_set_R(i, :));
        
%         R_P_n1_n(i) = R_P(i)  + Q;
%         K(i) = R_P_n1_n(i) * H' * inv(H * R_P_n1_n(i) * H' + mR);
%         R_X_n1_n1(i) = R_X_n1_n(i) + K(i) * (R(i) - H * R_X_n1_n(i));


%         % 对数据求平均进行平滑
%         if sum(sum_set_R(i, :)) == 0
%             sum_set_R(i, :) =  R_X_n1_n1(i);
%         else
%             for j = 1 : sum_set_size - 1
%                 sum_set_R(i, j) = sum_set_R(i, j + 1);
%             end
%         end 
%         sum_set_R(i, sum_set_size) = R_X_n1_n1(i);

%         res_R(i) = mean(sum_set_R(i, :));
%         R_P_n1_n1(i) = R_P_n1_n(i) - K(i) * H * R_P_n1_n(i);
       
%     end
%     R_X = R_X_n1_n1;
%     R_P = R_P_n1_n1;
%     testDataArr = [testDataArr;R(1), R_X_n1_n1(1), res_R(1), K(1), R(2), R_X_n1_n1(2), res_R(2), K(2), R(3), R_X_n1_n1(3), res_R(3), K(3)];
%     % res_R = R_X;
% end
    