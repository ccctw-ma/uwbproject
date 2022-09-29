% version 6.0 增加改进自适应卡尔曼滤波对静止状态的处理
classdef Kfclass6 < handle
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

        real_time_data_set
        real_time_data_set_size 
        real_time_data_resSet
        
        velocity_var_set
        velocity_var_set_size
        velocity_var_set_resSet
        v_x_var_pre
        v_y_var_pre

        MeasNoiseVar            % 观测误差
        R_base                  % 观测误差矩阵
        R_pre
        R_upper                 % 观测误差超过上限后的替代值
        R_upper_bound           % 观测误差的上限
        R_lower                 % 观测误差超过下限后的替代值
        R_lower_bound           % 观测误差的下限
        R_valid_bound           % 观测误差是否有效的上限
        R_max                   % 判断观测信息是否正常的阈值
        b                       % 观测误差遗忘因子
        p                       % 预测误差遗忘因子
        vb                      % 速度方差遗忘因子
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
        static_mea_arr
        mean_posiRes


        F_set
        X_n1_n_set
        X_n1_n1_set
        P_n1_n_set
        P_n1_n1_set
        smooth_window_size
        smooth_posiRes


        analysis_window_size
        static_step
        static_vel_threshold
        status
        static_step_set
    end
    
    methods 
        function obj = Kfclass6(~)
        
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
            obj.vb = 0.8;
            obj.v_x_var_pre = 0;
            obj.v_y_var_pre = 0;

            obj.bet = 1;
            obj.MeasNoiseVar = 0.1;
            obj.R_base = [obj.MeasNoiseVar, 0;
                          0, obj.MeasNoiseVar];
            obj.R_pre = obj.R_base;
            obj.R_max = 2;
            
            obj.K = zeros(4, 2);

            obj.R_lower_bound = 0;
            obj.R_lower = 0.0001;
            obj.R_upper_bound = 2;
            obj.R_upper = 1;
            obj.R_valid_bound = 40;
            
            obj.dts = [];
            obj.R_diff_arr = [];
            obj.innovation_arr = [];
            obj.abnormal_mea_arr = [];
            obj.outrange_mea_arr = [];
            obj.unValid_mea_arr = [];
            obj.mean_posiRes = [];
            obj.static_mea_arr = [];

            obj.F_set = [];
            obj.X_n1_n_set = [];
            obj.X_n1_n1_set = [];
            obj.P_n1_n_set = [];
            obj.P_n1_n1_set = [];
            obj.smooth_window_size = 20;
            obj.smooth_posiRes = [];

            obj.mean_set_size = 100;
            obj.mean_set = ones(2, obj.mean_set_size);

            obj.real_time_data_set_size = 200;
            obj.real_time_data_set = zeros(3, obj.real_time_data_set_size);
            obj.real_time_data_resSet = [];

            obj.velocity_var_set_size = 10;
            obj.velocity_var_set = zeros(2, obj.velocity_var_set_size);
            obj.velocity_var_set_resSet = [];

            obj.analysis_window_size = 40;
            obj.static_step = 0;
            obj.static_vel_threshold = 0.5;
            obj.status = 1; % 0 -> static 1-> moving
            obj.static_step_set = [];
        end

        function obj = initKf(obj, node)
            
            obj.X_n1 = [node.pos_x; 0; node.pos_y; 0;];
            for i = 1 : obj.mean_set_size
                obj.mean_set(1, i) = node.pos_x;
                obj.mean_set(2, i) = node.pos_y;
            end
            for i = 1 : obj.real_time_data_set_size
                obj.real_time_data_set(1, i) = node.pos_x;
                obj.real_time_data_set(2, i) = node.pos_y;
                obj.real_time_data_set(3, i) = node.time_stamp;
            end
            obj.t = node.time_stamp;
        end



        % 对记录的数据集进行分析
        function [posi_x_var, vel_x_var, v_x, posi_y_var, vel_y_var, v_y, v, distance] = realTimeDataAnalysis(obj, node)
            % 更新数据集
            for i = 1 : obj.real_time_data_set_size - 1
                obj.real_time_data_set(1, i) = obj.real_time_data_set(1, i + 1);
                obj.real_time_data_set(2, i) = obj.real_time_data_set(2, i + 1);
                obj.real_time_data_set(3, i) = obj.real_time_data_set(3, i + 1);
            end
            if isnan(node.pos_x)
                obj.real_time_data_set(1, obj.real_time_data_set_size) = obj.real_time_data_set(1, obj.real_time_data_set_size - 1);
                node.pos_x = obj.real_time_data_set(1, obj.real_time_data_set_size - 1);
            else
                obj.real_time_data_set(1, obj.real_time_data_set_size) = node.pos_x;
            end
            if isnan(node.pos_y)
                obj.real_time_data_set(2, obj.real_time_data_set_size) = obj.real_time_data_set(2, obj.real_time_data_set_size - 1);
                node.pos_y = obj.real_time_data_set(2, obj.real_time_data_set_size - 1);
            else
                obj.real_time_data_set(2, obj.real_time_data_set_size) = node.pos_y;
            end
            obj.real_time_data_set(3, obj.real_time_data_set_size) = node.time_stamp;


            % 区间坐标位置方差
            posi_var_res = var(obj.real_time_data_set(1:2, end - obj.analysis_window_size + 1: end), 0, 2);
            posi_x_var = posi_var_res(1);
            posi_y_var = posi_var_res(2);
            
            % 区间速度
            vxs = zeros(obj.analysis_window_size, 1);
            vys = zeros(obj.analysis_window_size, 1);
            for i = 1 : obj.analysis_window_size 
                v_x = (obj.real_time_data_set(1, end) - obj.real_time_data_set(1, end - i)) / (obj.real_time_data_set(3, end) - obj.real_time_data_set(3, end - i));
                v_y = (obj.real_time_data_set(2, end) - obj.real_time_data_set(2, end - i)) / (obj.real_time_data_set(3, end) - obj.real_time_data_set(3, end - i));
                if isnan(v_x) || isinf(v_x)
                    vxs(i) = 0;
                else
                    vxs(i) = v_x;
                end
                if isnan(v_y) || isinf(v_y)
                    vys(i) = 0;
                else
                    vys(i) = v_y;
                end
            end
            v_x = mean(vxs);
            v_y = mean(vys);
            v = norm([v_x, v_y]);

            for i = 1 : obj.velocity_var_set_size - 1
                obj.velocity_var_set(1, i) = obj.velocity_var_set(1, i + 1);
                obj.velocity_var_set(2, i) = obj.velocity_var_set(2, i + 1);
            end
            obj.velocity_var_set(1, obj.velocity_var_set_size) = v_x;
            obj.velocity_var_set(2, obj.velocity_var_set_size) = v_y;
            velocity_var_res = var(obj.velocity_var_set, 0, 2);
            vel_x_var = velocity_var_res(1);
            vel_y_var = velocity_var_res(2);


            distance = norm([node.pos_x, node.pos_y] - [obj.X_n1(1), obj.X_n1(3)]);

            % 收集数据
            obj.real_time_data_resSet = [obj.real_time_data_resSet; posi_var_res(1), v_x, velocity_var_res(1) ...
                , posi_var_res(2), v_y, velocity_var_res(2), v, distance]; 
        end


        % 更新陈旧观测噪声的置信比例 不断减小陈旧量测噪声的影响
        function updateBet(obj)
            obj.bet = (1 - obj.b) / (1 - obj.b ^ (obj.step + 1));
        end
        
        function XYPositionKalmanFilter(obj, dt, node)
            cur_Z = [node.pos_x; node.pos_y];
            % F 是需要实时更新的
            F = [
                1,  dt,  0,    0;
                0,  1,   0,    0;
                0,  0,   1,    dt;
                0,  0,   0,    1;
            ];

            
            obj.Q = [
                dt,   0,   0,   0;
                0,   dt * 2,   0,   0;
                0,    0,  dt,   0;
                0,    0,   0,  dt * 2;
            ] * 0.02;


            static_F = eye(4, 4);
            
            static_Q = zeros(4, 4);


            isValidMeasurementData = true;
            outRangeMeasurementData = false;
            isStaticMeasurementData = false;
            
            
            X_n_n = obj.X_n1;
            P_n_n = obj.P;

%             X_n1_n = F * X_n_n;                 % 4 * 1 卡尔曼滤波预测值
%             P_n1_n = F * P_n_n * F' + obj.Q;        % 4 * 4 预测值的协方差矩阵 

            Z_n = cur_Z;                            % 2 * 1 观测值
            


            [posi_x_var, vel_x_var, v_x, posi_y_var, vel_y_var, v_y, v, distance] = obj.realTimeDataAnalysis(node);
            disp([posi_x_var, vel_x_var, v_x, posi_y_var, vel_y_var, v_y, v, distance]);
            % 观测结果为NaN或者超过设定的界限那么观测结果为无效数据 
            if isnan(Z_n(1)) || isnan(Z_n(2)) || Z_n(1) < 0 || Z_n(2) < 0 
                isValidMeasurementData = false;
                X_n1_n = static_F * X_n_n;                 
                P_n1_n = static_F * P_n_n * static_F' + static_Q;        % 使用静止模型来推断无效数据的位置

                X_n1_n1 = X_n1_n;
                P_n1_n1 = P_n1_n;
                obj.unValid_mea_arr = [obj.unValid_mea_arr; Z_n(1), Z_n(2)];
%                 obj.real_time_data_resSet = [obj.real_time_data_resSet; 0, 0, 0, 0, 0, 0, 0, 0];
                disp('Invalid data');
            % 有效数据， 进行分类分析
            else
                % 认为处于静止状态
                % v <= obj.static_vel_threshold * 2 &&
                
                if v <= obj.static_vel_threshold || (v <= obj.static_vel_threshold * 2 && obj.static_step >= 20 && distance < 0.5)
                    isStaticMeasurementData = true;
                    if v <= obj.static_vel_threshold
                        obj.static_step = obj.static_step + 1;
                    else
                        obj.static_step = obj.static_step - 1;
                    end
                    X_n1_n = static_F * X_n_n;  % 静止运动方程
                    P_n1_n = static_F * P_n_n * static_F' + static_Q;
                    
                    % 静止状态的新息向量
                    innovation = Z_n - obj.H * X_n1_n;
                    % 区间内观测值的方差 可以判断该区间内观测值的稳定情况
                    
                    R_diff = abs(innovation' / (obj.H * P_n1_n * obj.H' + obj.R_base) * innovation);
    
                    obj.R_diff_arr = [obj.R_diff_arr; R_diff];
                    obj.innovation_arr = [obj.innovation_arr; innovation'];
    
               
                    if R_diff <= obj.R_upper_bound
                        R_n = [(obj.MeasNoiseVar + posi_x_var) * max(R_diff, 0.5), 0;
                              0, (obj.MeasNoiseVar + posi_y_var) * max(R_diff, 0.5)];
                    else
                        
                        outRangeMeasurementData = true;
                        baseRate = R_diff / obj.R_upper_bound;
                        expansionRatio = 100;
                        
                        R_n = (baseRate + expansionRatio) * obj.R_base;
                    end
    
                    K_n = P_n1_n * obj.H' / (obj.H * P_n1_n * obj.H' + R_n);
                    obj.K = K_n;
                    P_n1_n1 = (eye(4) - K_n * obj.H) * P_n1_n;
                    X_n1_n1 = X_n1_n + K_n * (Z_n - obj.H * X_n1_n);

                % 认为处于运动状态
                else
                    X_n1_n = F * X_n_n;                 % 4 * 1 卡尔曼滤波预测值
                    P_n1_n = F * P_n_n * F' + obj.Q;        % 4 * 4 预测值的协方差矩阵 
                    % 新息向量
                    innovation = Z_n - obj.H * X_n1_n;
                    % 区间内观测值的方差 可以判断该区间内观测值的稳定情况
                    
                    R_diff = abs(innovation' / (obj.H * P_n1_n * obj.H' + obj.R_base) * innovation);
                    obj.R_diff_arr = [obj.R_diff_arr; R_diff];
                    obj.innovation_arr = [obj.innovation_arr; innovation'];
    
               
%                     v_x_var = obj.vb * obj.v_x_var_pre + (1 - obj.vb) * vel_x_var;
%                     v_y_var = obj.vb * obj.v_y_var_pre + (1 - obj.vb) * vel_y_var;
                    v_x_var = vel_x_var;
                    v_y_var = vel_y_var;
                    if R_diff <= obj.R_upper_bound 
                        R_n = [(obj.MeasNoiseVar + posi_x_var) * max(R_diff, 0.5), 0;
                              0, (obj.MeasNoiseVar + posi_y_var) * max(R_diff, 0.5)];
                    else
                        % 超过预期 需要进一步判断该段数据的可信度 有可能确实是不可靠的数据 也可能是可靠数据只是变化特别快
                        outRangeMeasurementData = true;
                        % 判断x,y方向的误差是否超过限度
                        baseRate = R_diff / obj.R_upper_bound;
                        expansionRatio = 100;
                        
    
                        if v_x_var > obj.MeasNoiseVar
                            r_x = obj.MeasNoiseVar * expansionRatio;
                        else
                            r_x = posi_x_var;
                        end
                        if v_y_var > obj.MeasNoiseVar
                            r_y = obj.MeasNoiseVar * expansionRatio;
                        else
                            r_y = posi_y_var;
                        end
                        additional_r = [r_x, 0; 0, r_y];
                        R_n = baseRate * obj.R_base + additional_r;
                    end
%     
%                     obj.v_x_var_pre = v_x_var;
%                     obj.v_y_var_pre = v_y_var;
               
                    K_n = P_n1_n * obj.H' / (obj.H * P_n1_n * obj.H' + R_n);
                    obj.K = K_n;
                    P_n1_n1 = (eye(4) - K_n * obj.H) * P_n1_n;
                    X_n1_n1 = X_n1_n + K_n * (Z_n - obj.H * X_n1_n);
                    obj.static_step = max(0, obj.static_step - 10);
                end

                obj.static_step_set = [obj.static_step_set; obj.static_step];
            end
            
            if outRangeMeasurementData
                obj.outrange_mea_arr = [obj.outrange_mea_arr; Z_n'];
            end
            
            if isStaticMeasurementData
                obj.static_mea_arr = [obj.static_mea_arr; Z_n'];
            end

            obj.X_n = X_n1_n;
            obj.X_n1 = X_n1_n1;
            obj.P = P_n1_n1;
            obj.Z = cur_Z;
        end

        function kal_res = Run(obj, node)
            dt = mod(max(node.time_stamp - obj.t, 0) + 86400, 86400);        % time difference from last update
            if dt == 0
                dt = 0.005;
            end
            obj.t = (obj.t + dt);                      % update current KF time
            
            obj.time = obj.time + dt;
            % 存储所有的时间间隔
            obj.dts = [obj.dts; dt];
            obj.XYPositionKalmanFilter(dt, node);


            kal_res.pos_x_est = obj.X_n(1);
            kal_res.pos_y_est = obj.X_n(3);
            kal_res.pos_x_cor = obj.X_n1(1);
            kal_res.v_x = obj.X_n1(2);
            kal_res.pos_y_cor = obj.X_n1(3);
            kal_res.v_y = obj.X_n1(4);
            kal_res.k_x = obj.K(1, 1);
            kal_res.k_y = obj.K(3, 2);

            obj.step = obj.step + 1;
        end

    end
end



