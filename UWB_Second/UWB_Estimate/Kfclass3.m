classdef Kfclass3 < handle


    properties 
        time                    % 时间
        X_n1                    % 经过卡尔曼滤波矫正后的数据
        X_n                     % 预测的数据值
        P                       % 预测值误差矩阵
        K                       % 卡尔曼增益
        H                       % 观测数据的转移方程 Z_n = H * X_n + V_n
        mean_set                % 用于平滑数据采用的均值滑动窗口矩阵
        mean_set_size           % 均值滑动窗口的大小
        var_set                 % 计算观测数据方差的滑动窗口矩阵
        var_set_size            % 观测数据方差的窗口大小

        pre_mean_set
        pre_var_set

        R                       % 观测误差
        R_max                   % 观测误差的上限
        R_min                   % 观测误差的下限
        b                       % 遗忘因子
        bet                     % 观测误差更新调节参数
        i                       % 迭代步数
        Z                       % 观测数据
        t
        dts %相邻信号之间的距离差
        R_diff_arr
        
    end
    
    methods 
        function obj = Kfclass3(config)
            obj.mean_set_size = 21;
            obj.var_set_size = config.init_window_size;
            
            obj.mean_set = ones(2, obj.mean_set_size);
            obj.var_set = zeros(2, config.var_set_size);
            
            obj.P = eye(4) * 0.01;
            obj.H = [
                1, 0, 0, 0;
                0, 0, 1, 0;
            ];
            obj.bet = 1;
            obj.b = 0.5;
            obj.i = 1;
            obj.R = eye(2) * 0.05;
            obj.R_max = 0.01;
            obj.R_min = 0.0001;
            obj.K = zeros(4, 2);

            obj.dts = [];
            obj.R_diff_arr = [];
        end

        function obj = initKf(obj, pos_x, pos_y, time_stamp, index)
            obj.X_n1 = [pos_x; 0; pos_y; 0;];
            for i = 1 : obj.mean_set_size
                obj.mean_set(1, i) = pos_x;
                obj.mean_set(2, i) = pos_y;
            end
            obj.t = time_stamp;
        end



        function mean_res = mean_Kf(obj)
            for i = 1 : obj.mean_set_size - 1
                obj.mean_set(1, i) = obj.mean_set(1, i + 1);
                obj.mean_set(2, i) = obj.mean_set(2, i + 1);
            end
            obj.mean_set(1, obj.mean_set_size) = obj.X_n1(1);
            obj.mean_set(2, obj.mean_set_size) = obj.X_n1(3);
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

        % 更新陈旧观测噪声的置信比例 不断减小陈旧量测噪声的影响
        function updateBet(obj)
            obj.bet = obj.bet / (obj.bet + obj.b);
        end
        
        function XYPositionKalmanFilter(obj, dt, Z)

            % F 是需要实时更新的
            F = [
                1,  dt,  0,    0;
                0,  1,   0,    0;
                0,  0,   1,    dt;
                0,  0,   0,    1;
            ];
            
            % Q is the process noise matrix
            % Q = [
            %     (dt ^ 4) / 2, (dt ^ 3) / 2, (dt ^ 2) / 2, 0, 0 ,0;
            %     (dt ^ 3) / 2, dt ^ 2, dt, 0, 0, 0;
            %     (dt ^ 2) / 2, dt, 1, 0, 0, 0;
            %     0, 0, 0, (dt ^ 4) / 2, (dt ^ 3) / 2, (dt ^ 2) / 2;
            %     0, 0 ,0, (dt ^ 3) / 2, dt ^ 2, dt;
            %     0, 0 ,0, (dt ^ 2) / 2, dt, 1;
            % ] * 1;
            Q = [
                dt, 0,  0,  0;
                0, dt,  0,  0;
                0,  0, dt,  0;
                0,  0,  0, dt;
            ] * 0.1;
            

        
            X_n_n = obj.X_n1;

            P_n_n = obj.P;

            X_n1_n = F * X_n_n;                 % 4 * 1 卡尔曼滤波预测值

            P_n1_n = F * P_n_n * F' + Q;        % 4 * 4 预测值的协方差矩阵 

            Z_n = Z;                            % 2 * 1 观测值

            X_i_0 = X_n1_n;                     % 为序贯滤波迭代使用
            P_i_0 = P_n1_n;
            % 因为R的维度(2 * 2)所以序贯滤波的迭代次数为2
            for i = 1 : 2
                % 第i维度观测-预测误差(即新息innovation) 
                Z_n_diff_i = Z_n(i) - obj.H(i, :) * X_i_0;
                % 第i维度的量测误差
                R_diff_i = Z_n_diff_i ^ 2 - obj.H(i, :) * P_i_0 * obj.H(i, :)';
                %对R对角线上的元素进行校验 排除异常值确保R的正定性
                obj.R_diff_arr = [obj.R_diff_arr; R_diff_i];
                if R_diff_i < obj.R_min
                    obj.R(i, i) = (1 - obj.bet) * obj.R(i, i) + obj.bet * obj.R_min;
                elseif R_diff_i > obj.R_max
                    % obj.R(i, i) = obj.R_max ; % 待调整
                    obj.R(i, i) = 1;
                else
                    obj.R(i, i) = (1 - obj.bet) * obj.R(i, i) + obj.bet * R_diff_i;
                end
                K_i_1 = P_i_0 * obj.H(i, :)' / (obj.H(i, :) * P_i_0 * obj.H(i, :)' + obj.R(i, i));

                obj.K(:, i) = K_i_1;

                X_i_1 = X_i_0 + K_i_1 * (Z_n(i) - obj.H(i, :) * X_i_0);
                P_i_1 = (eye(4) - K_i_1 * obj.H(i, :)) * P_i_0;
                X_i_0 = X_i_1;
                P_i_0 = P_i_1;
            end

            X_n1_n1 = X_i_1;
            P_n1_n1 = P_i_1;

            % 更新观测误差影响因子
            obj.updateBet();

            obj.X_n = X_n1_n;
            obj.X_n1 = X_n1_n1;
            obj.P = P_n1_n1;
            obj.Z = Z;
        end

        function kal_res = Run(obj, t, Z)

            dt = mod(max(t - obj.t, 0) + 86400, 86400);        % time difference from last update
            if dt == 0
                dt = 0.005;
            end
            obj.t = (obj.t + dt);                      % update current KF time
            KFtime = obj.t;

            obj.time = obj.time + dt;
            % 存储所有的时间间隔
            obj.dts = [obj.dts; dt];

            obj.XYPositionKalmanFilter(dt, Z);
            mean_res = obj.mean_Kf();

            kal_res.pos_x_est = obj.X_n(1);
            kal_res.pos_y_est = obj.X_n(3);
            kal_res.pos_x_cor = obj.X_n1(1);
            kal_res.pos_y_cor = obj.X_n1(3);
            kal_res.k_x = obj.K(1, 1);
            kal_res.k_y = obj.K(3, 2);
            kal_res.mean_x = mean_res(1);
            kal_res.mean_y = mean_res(2);
            obj.i = obj.i + 1;
        end

    end
end