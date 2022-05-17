classdef Kfclass4 < handle


    properties 
        time                    % 时间
        X_n1                    % 经过卡尔曼滤波矫正后的数据
        X_n                     % 预测的数据值
        P                       % 预测值误差矩阵
        K                       % 卡尔曼增益
        Q                       % 过程噪声
        H                       % 观测数据的转移方程 Z_n = H * X_n + V_n
        mean_set                % 用于平滑数据采用的均值滑动窗口矩阵
        mean_set_size           % 均值滑动窗口的大小
    
        R                       % 观测误差
        R_upper                 % 观测误差超过上限后的替代值
        R_upper_bound           % 观测误差的上限
        R_lower                 % 观测误差超过下限后的替代值
        R_lower_bound           % 观测误差的下限
        R_valid_bound           % 观测误差是否有效的上限
        R_max                   % 判断观测信息是否正常的阈值
        b                       % 观测误差遗忘因子
        p                       % 预测误差遗忘因子
        bet                     % 观测误差更新调节参数
        step                    % 迭代步数
        Z                       % 观测数据
        t
        q
        r


        dts                     %相邻信号之间的距离差
        R_diff_arr
        innovation_arr
        abnormal_mea_arr
        outrange_mea_arr
        unValid_mea_arr
        mean_posiRes


        F_set
        X_n1_n_set
        X_n1_n1_set
        P_n1_n_set
        P_n1_n1_set
        smooth_window_size
        smooth_posiRes
    end
    
    methods 
        function obj = Kfclass4(~)
            obj.mean_set_size = 100;
            obj.mean_set = ones(2, obj.mean_set_size);
            
            obj.step = 1;

            obj.H = [
                1, 0, 0, 0;
                0, 0, 1, 0;
            ];
            obj.P = eye(4) * 0.01;
            obj.p = 1.01;
            obj.Q = eye(4) * 0.01;
            obj.q = zeros(4, 1);
            obj.r = zeros(2, 1);

            obj.b = 0.9;
            obj.bet = 1;
            obj.R = eye(2) * 0.01;
         
            obj.R_max = 1.5;
            obj.K = zeros(4, 2);

            obj.R_lower_bound = 0;
            obj.R_lower = 0.0001;
            obj.R_upper_bound = 0.01;
            obj.R_upper = 1;
            obj.R_valid_bound = 0.1;
            
            obj.dts = [];
            obj.R_diff_arr = [];
            obj.innovation_arr = [];
            obj.abnormal_mea_arr = [];
            obj.outrange_mea_arr = [];
            obj.unValid_mea_arr = [];
            obj.mean_posiRes = [];

            obj.F_set = [];
            obj.X_n1_n_set = [];
            obj.X_n1_n1_set = [];
            obj.P_n1_n_set = [];
            obj.P_n1_n1_set = [];
            obj.smooth_window_size = 20;
            obj.smooth_posiRes = [];
        end

        function obj = initKf(obj, pos_x, pos_y, time_stamp)
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
            obj.mean_posiRes = [obj.mean_posiRes; mean_res'];
        end

        % RTS区间平滑算法
        function RTS_range_smooth(obj, F, X_n1_n, X_n1_n1, P_n1_n, P_n1_n1)

            obj.F_set = [obj.F_set; F];
            obj.X_n1_n_set = [obj.X_n1_n_set; X_n1_n'];
            obj.P_n1_n_set = [obj.P_n1_n_set; P_n1_n];
            obj.X_n1_n1_set = [obj.X_n1_n1_set; X_n1_n1'];
            obj.P_n1_n1_set = [obj.P_n1_n1_set; P_n1_n1];

            X_s_n1 = X_n1_n1;
            P_s_n1 = P_n1_n1;
            if length(obj.X_n1_n_set) == obj.smooth_window_size

                for i = obj.smooth_window_size - 1 : -1 : obj.smooth_window_size / 2
                    K_s_n = obj.P_n1_n1_set(4 * i - 3 : 4 * i, : ) * obj.F_set(4 * i + 1 : 4 * i + 4, : )' / obj.P_n1_n_set(4 * i + 1 : 4 * i + 4, : );
                    X_s_n = obj.X_n1_n1_set(i, : )' + K_s_n * (X_s_n1 - obj.X_n1_n1_set(i + 1, : )');
                    P_s_n = obj.P_n1_n1_set(4 * i - 3 : 4 * i, : ) + K_s_n * (P_s_n1 - obj.P_n1_n_set(4 * i + 1 : 4 * i + 4, : )) * K_s_n';
                    X_s_n1 = X_s_n;
                    P_s_n1 = P_s_n;                  
                end

                j = obj.smooth_window_size / 2;
                X_f_j = obj.X_n1_n1_set(j, : )';
                P_f_j = obj.P_n1_n1_set(4 * j - 3 : 4 * j, : );
                X_b_j = X_s_n1;
                P_b_j = P_s_n1;
                X_j = (P_f_j + P_b_j) \ (P_b_j * X_f_j + P_f_j * X_b_j); 

                obj.smooth_posiRes = [obj.smooth_posiRes; X_j(1), X_j(3)];

                % 清空队列首的数据
                obj.F_set(1 : 4, :) = [];
                obj.X_n1_n_set(1, :) = [];
                obj.P_n1_n_set(1 : 4, :) = [];
                obj.X_n1_n1_set(1, :) = [];
                obj.P_n1_n1_set(1 : 4, :) = [];
            end
        end
     

        % 更新陈旧观测噪声的置信比例 不断减小陈旧量测噪声的影响
        function updateBet(obj)
            obj.bet = (1 - obj.b) / (1 - obj.b ^ (obj.step + 1));
        end
        
        function XYPositionKalmanFilter(obj, dt, Z)

            % F 是需要实时更新的
            F = [
                1,  dt,  0,    0;
                0,  1,   0,    0;
                0,  0,   1,    dt;
                0,  0,   0,    1;
            ];

            obj.Q = [
                dt, 0,  0,  0;
                0, dt,  0,  0;
                0,  0, dt,  0;
                0,  0,  0, dt;
            ] * 0.01;

            X_n_n = obj.X_n1;

            P_n_n = obj.P;

            X_n1_n = F * X_n_n;                 % 4 * 1 卡尔曼滤波预测值

            P_n1_n = F * P_n_n * F' + obj.Q;        % 4 * 4 预测值的协方差矩阵 

            Z_n = Z;                            % 2 * 1 观测值
            

            isValidMeasurementData = true;
            outRangeMeasurementData = false;
            if isnan(Z_n(1)) || isnan(Z_n(2))
                isValidMeasurementData = false;
            else

                % 新息向量
                innovation = Z_n - obj.H * X_n1_n;
%                 obj.r = (1 - obj.bet) * obj.r + obj.bet * innovation;
%                 v_n = Z_n - obj.H * X_n1_n - obj.r;
%                 R_n = (1 - obj.bet) * obj.R + obj.bet * abs(v_n * v_n' - obj.H * P_n1_n * obj.H');
                
               
                R_diff = abs(innovation' / (obj.H * P_n1_n * obj.H' + obj.R) * innovation);
                obj.R_diff_arr = [obj.R_diff_arr; R_diff];
                obj.innovation_arr = [obj.innovation_arr; innovation'];
                if R_diff <= obj.R_max
%                     R_n = (1 - obj.bet) * obj.R + obj.bet * abs(innovation * innovation' - obj.H * P_n1_n * obj.H');
                      R_n = obj.R;
                    
                else
                    outRangeMeasurementData = true;
                    R_n = R_diff / obj.R_max * obj.R;
                end
                
                K_n = P_n1_n * obj.H' / (obj.H * P_n1_n * obj.H' + R_n);
                obj.K = K_n;
    
                P_n1_n1 = (eye(4) - K_n * obj.H) * P_n1_n;

                X_n1_n1 = X_n1_n + K_n * (Z_n - obj.H * X_n1_n);
%                 X_n1_n1 = X_n1_n + K_n * v_n;

%                 obj.q = (1 - obj.bet) * obj.q + obj.bet * (X_n1_n1 - F * X_n_n);

%                 Q_n1 = (K_n * (innovation * innovation') * K_n' + P_n1_n1 - F * P_n_n * F' - 2 * K_n * obj.H * P_n1_n * obj.H' * K_n'...
%                     - 2 * K_n * R_n * K_n' + P_n1_n * obj.H' * K_n' + K_n * obj.H * P_n1_n); 
    
%                 Q_n1 = K_n * (innovation * innovation') * K_n'+ P_n1_n1 - F * P_n_n * F';
%                 Q_n1 = diag(abs([Q_n1(1,1), Q_n1(2, 2), Q_n1(3, 3), Q_n1(4, 4)]));
%                 obj.Q = (1 - obj.bet) * obj.Q + obj.bet * Q_n1; 
                
            end

            if ~isValidMeasurementData
                X_n1_n1 = X_n1_n;
                P_n1_n1 = P_n1_n;
                obj.unValid_mea_arr = [obj.unValid_mea_arr; X_n1_n(1), X_n1_n(3)];
            end
            
            if outRangeMeasurementData
%                 P_n1_n1 = P_n1_n1 * obj.p;
                obj.outrange_mea_arr = [obj.outrange_mea_arr; Z_n'];
            end
            

            obj.updateBet();
            % obj.RTS_range_smooth(F, X_n1_n, X_n1_n1, P_n1_n, P_n1_n1);

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
            %KFtime = obj.t;

            obj.time = obj.time + dt;
            % 存储所有的时间间隔
            obj.dts = [obj.dts; dt];

            obj.XYPositionKalmanFilter(dt, Z);
%             obj.mean_Kf();

            kal_res.pos_x_est = obj.X_n(1);
            kal_res.pos_y_est = obj.X_n(3);
            kal_res.pos_x_cor = obj.X_n1(1);
            kal_res.pos_y_cor = obj.X_n1(3);
            kal_res.k_x = obj.K(1, 1);
            kal_res.k_y = obj.K(3, 2);
%             kal_res.mean_x = mean_res(1);
%             kal_res.mean_y = mean_res(2);
            obj.step = obj.step + 1;
        end

    end
end