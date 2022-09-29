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

        pre_mean_set
        pre_var_set

        R %观测误差
        b  %遗忘因子
        dk % 观测误差更新调节参数
        i  % 迭代步数
        Z  % 观测数据

        dts %相邻信号之间的距离差
        abnormal_mea 
    end
    
    methods 
        function obj = Kfclass(config)
            obj.mean_set_size = config.mean_set_size;
            obj.var_set_size = config.init_window_size;
            
            obj.mean_set = ones(2, config.mean_set_size);
            obj.var_set = zeros(2, config.var_set_size);

            obj.P = eye(6) * 500;

            obj.b = 0.95;
            obj.i = 1;
            obj.R = eye(2) ;

            obj.dts = [];
            obj.abnormal_mea = [];
        end

        function obj = initKf(obj, pos_x, pos_y, time_stamp, index)
            obj.var_set(1, index) = pos_x;
            obj.var_set(2, index) = pos_y;
            obj.time = time_stamp;
        end

        function obj = finishInit(obj, pos_x, pos_y, time_stamp, index)
            obj.var_set(1, index) = pos_x;
            obj.var_set(2, index) = pos_y;
            init_mean = mean(obj.var_set, 2);
            obj.mean_set(1, :) = obj.mean_set(1, :) * init_mean(1);
            obj.mean_set(2, :) = obj.mean_set(2, :) * init_mean(2);
            obj.time = time_stamp;
            obj.X_n1 = [init_mean(1), 0, 0, init_mean(2), 0, 0]';
            obj.Z = [pos_x; pos_y];
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

        function update_var_set(obj, Z)
            % update the var_set_matrix by sliding window
            for i = 1 : obj.var_set_size - 1
                obj.var_set(1, i) = obj.var_set(1, i + 1);
                obj.var_set(2, i) = obj.var_set(2, i + 1);
            end
            obj.var_set(1, obj.var_set_size) = Z(1);
            obj.var_set(2, obj.var_set_size) = Z(2);
        end

        function dk = getdk(obj)
            dk = (1 - obj.b) / (1 - obj.b ^ obj.k); 
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

            R_n = eye(2);

            % Q is the process noise matrix
            Q = [
                (dt ^ 4) / 2, (dt ^ 3) / 2, (dt ^ 2) / 2, 0, 0 ,0;
                (dt ^ 3) / 2, dt ^ 2, dt, 0, 0, 0;
                (dt ^ 2) / 2, dt, 1, 0, 0, 0;
                0, 0, 0, (dt ^ 4) / 2, (dt ^ 3) / 2, (dt ^ 2) / 2;
                0, 0 ,0, (dt ^ 3) / 2, dt ^ 2, dt;
                0, 0 ,0, (dt ^ 2) / 2, dt, 1;
            ] * 1000;
            % Q = eye(6);
            
            % H is the observation matrix Z_n = H * X_n + V_n   the X is the measurement state 
        

            H = [
                1, 0, 0, 0, 0, 0;
                0, 0, 0, 1, 0, 0;
            ];
           
            X_n_n = obj.X_n1;

            P_n_n = obj.P;
            

            X_n1_n = F * X_n_n;
            P_n1_n = F * P_n_n * F' + Q;


%             measurement_innovation =  mean(diff(obj.var_set, 1, 2), 2);
%             cur_innovation = Z - obj.Z;
            % obj.abnormal_mea = [obj.abnormal_mea; measurement_innovation(1),  cur_innovation(1)];
%             obj.update_var_set(Z);
            % if sum(cur_innovation > 3 * measurement_innovation)
%             if abs(X_n1_n(1) - Z(1)) > 0.1 || abs(X_n1_n(4) - Z(2)) > 0.1
%                 obj.abnormal_mea = [obj.abnormal_mea; Z'];
%                 R_n = eye(2) * 50;
%             end


            Z_n = Z;

            dk = 0.1;
            V_n = Z_n - H * X_n1_n;
            % R_n = (1 - dk) * obj.R + dk * ((eye(2) - H * obj.K) * V_n * V_n' * (eye(2) - H*obj.K)' + H * P_n1_n * H');
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
            obj.R = R_n;
            obj.Z = Z;
        end

        function kal_res = Run(obj, t, Z)
            dt = mod(t - obj.time + 86400, 86400);
            if dt == 0
                dt = 0.01;
            end
            obj.dts = [obj.dts; dt];
            obj.time = obj.time + dt;

            obj.XYPositionKalmanFilter(dt, Z);
            kal_res.pos_x_est = obj.X_n(1);
            kal_res.pos_y_est = obj.X_n(4);
            kal_res.pos_x_cor = obj.X_n1(1);
            kal_res.pos_y_cor = obj.X_n1(4);
            kal_res.k_x = obj.K(1, 1);
            kal_res.k_y = obj.K(4, 2);

            obj.i = obj.i + 1;
        end

    end
end