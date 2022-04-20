classdef Kfclass < handle


    properties 
        time                    % 时间
        X_n1                    % 经过卡尔曼滤波矫正后的数据
        X_n                     % 预测的数据值
        P                       % 预测值误差矩阵
        K                       % 卡尔曼增益
        mean_set                % 用于平滑数据采用的均值滑动窗口矩阵
        mean_set_size           % 均值滑动窗口的大小
        var_set                 % 计算观测数据方差的滑动窗口矩阵
        var_set_size            % 观测数据方差的窗口大小
    end
    
    methods 
        function obj = Kfclass(config)
            obj.mean_set_size = config.mean_set_size;
            obj.var_set_size = config.var_set_size;
            obj.mean_set = ones(2, config.mean_set_size);
            obj.var_set = ones(2, config.var_set_size);
        end

        function obj = initKf(obj, pos_x, pos_y, time_stamp)
            obj.X_n1 = [pos_x, 0, 0, pos_y, 0, 0]';
            obj.P = eye(6) * 500;
            obj.K = ones(6, 2);
            obj.time = time_stamp;
            obj.mean_set(1, :) = obj.mean_set(1, :) * pos_x;
            obj.mean_set(2, :) = obj.mean_set(2, :) * pos_y;
            obj.var_set(1, :) = obj.var_set(1, :) * pos_x;
            obj.var_set(2, :) = obj.var_set(2, :) * pos_y;
        end

        function mean_res = mean_Kf(obj)
            for i = 1 : obj.mean_set_size - 1
                obj.mean_set(1, i) = obj.mean_set(1, i + 1);
                obj.mean_set(2, i) = obj.mean_set(2, i + 1);
            end
            obj.mean_set(1, obj.mean_set_size) = obj.X_n1(1);
            obj.mean_set(2, obj.mean_set_size) = obj.X_n1(4);
            mean_res = mean(obj.mean_set, 2);
        end

        
        function XYPositionKalmanFilter(obj, dt, Z)
            F = [
                1,  dt, 0.5*dt^2,  0,  0,    0;
                0,  1,  0.5*dt^2,  0,  0,    0;
                0,  0,     1,      0,  0,    0;
                0,  0,     0,      1,  dt, 0.5*dt^2;
                0,  0,     0,      0,  1,    dt;
                0,  0,     0,      0,  0,    1; 
            ];
            % R is the measurement covariance matrix 

            % update the var_set_matrix by sliding window
            for i = 1 : obj.var_set_size - 1
                obj.var_set(1, i) = obj.var_set(1, i + 1);
                obj.var_set(2, i) = obj.var_set(2, i + 1);
            end
            obj.var_set(1, obj.var_set_size) = Z(1);
            obj.var_set(2, obj.var_set_size) = Z(2);

            z_var = var(obj.var_set, 1, 2);
            % z_var
            % R_n = [z_var(1), 0; 0, z_var(2)];
            R_n = eye(2) * 0.01;
            % Q is the process noise matrix
            Q = [
                (dt ^ 4) / 2, (dt ^ 3) / 2, (dt ^ 2) / 2, 0, 0 ,0;
                (dt ^ 3) / 2, dt ^ 2, dt, 0, 0, 0;
                (dt ^ 2) / 2, dt, 1, 0, 0, 0;
                0, 0, 0, (dt ^ 4) / 2, (dt ^ 3) / 2, (dt ^ 2) / 2;
                0, 0 ,0, (dt ^ 3) / 2, dt ^ 2, dt;
                0, 0 ,0, (dt ^ 2) / 2, dt, 1;
            ] * 100;
            
            % H is the observation matrix Z_n = H * X_n + V_n   the X is the measurement state 
        

            H = [
                1, 0, 0, 0, 0, 0;
                0, 0, 0, 1, 0, 0;
            ];
           
            X_n_n = obj.X_n1;

            P_n_n = obj.P;
            Z_n = Z;

            X_n1_n = F * X_n_n;
            P_n1_n = F * P_n_n * F' + Q;

            % The Kalman Gain 
            K_n = P_n1_n * H' / (H * P_n1_n * H' + R_n);

            % The State Update Equation
            X_n1_n1 = X_n1_n + K_n * (Z_n - H * X_n1_n);

            % The Covariance Update Equation 
            P_n1_n1 = (eye(6) - K_n * H) * P_n1_n * (eye(6) - K_n * H)' + K_n * R_n * K_n';

            obj.X_n = X_n1_n;
            obj.X_n1 = X_n1_n1;
            obj.K = K_n;
            obj.P = P_n1_n1;
        end

        function [pos_x_est, pos_y_est, pos_x_cor, pos_y_cor, k_x, k_y] = Run(obj, t, Z)
            dt = mod(t - obj.time + 86400, 86400);
            if dt ~= 0
                obj.time = t;
                obj.XYPositionKalmanFilter(dt, Z);
                
            end
            pos_x_est = obj.X_n(1);
            pos_y_est = obj.X_n(4);
            pos_x_cor = obj.X_n1(1);
            pos_y_cor = obj.X_n1(4);
            k_x = obj.K(1, 1);
            k_y = obj.K(4, 2);
        end

    end
end