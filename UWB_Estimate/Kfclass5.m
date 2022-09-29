% version 5.0 主要增加对滤波后的结果的平滑 后处理方式
classdef Kfclass5 < handle 


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
        mean_posiRes


        smooth_set
        X_n1_n_set
        X_n1_n1_set
        P_n1_n_set
        P_n1_n1_set
        smooth_window_size
        smooth_window_max_size
        smooth_window_min_size
        smooth_velocity_size
        smooth_static_threshold
        smooth_posiRes_set
        smooth_analysis_set
        smooth_deg_set
        smooth_static_center
        smooth_static_step
        smooth_pre_factor
        smooth_distance_set
    end
    
    methods 
        function obj = Kfclass5(~)
            obj.mean_set_size = 100;
            obj.mean_set = ones(2, obj.mean_set_size);

            obj.real_time_data_set_size = 20;
            obj.real_time_data_set = zeros(3, obj.real_time_data_set_size);
            obj.real_time_data_resSet = [];

            obj.velocity_var_set_size = 5;
            obj.velocity_var_set = zeros(2, obj.velocity_var_set_size);
            obj.velocity_var_set_resSet = [];

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

            %用于平滑算法
            obj.smooth_set = [];
            obj.X_n1_n_set = [];
            obj.X_n1_n1_set = [];
            obj.P_n1_n_set = [];
            obj.P_n1_n1_set = [];
            obj.smooth_window_max_size = 200; % 存储数据的上限，及窗口的最大值
            obj.smooth_window_min_size = 2; % 窗口的最小值
            obj.smooth_window_size = 2; % 可变
            obj.smooth_velocity_size = 20; % 用于计算区间速度
            obj.smooth_static_threshold = 0.5; % 当速度小于0.5m/s的时候，就大致可以认为是静止的
            obj.smooth_posiRes_set = zeros(3, obj.smooth_window_size);
            obj.smooth_analysis_set = [];
            obj.smooth_deg_set = [];
            obj.smooth_static_center = [0, 0];
            obj.smooth_static_step = 0;
            obj.smooth_pre_factor = 0.95;
            obj.smooth_distance_set = [];
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
            for i = 1 : obj.smooth_window_max_size
                obj.smooth_posiRes_set(1, i) = node.pos_x;
                obj.smooth_posiRes_set(2, i) = node.pos_y;
                obj.smooth_posiRes_set(3, i) = node.time_stamp;
            end
            obj.t = node.time_stamp;
            obj.smooth_static_center = [node.pos_x, node.pos_y];
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

        function real_time_analysis_res = realTimeDataAnalysis(obj, node)
            for i = 1 : obj.real_time_data_set_size - 1
                obj.real_time_data_set(1, i) = obj.real_time_data_set(1, i + 1);
                obj.real_time_data_set(2, i) = obj.real_time_data_set(2, i + 1);
                obj.real_time_data_set(3, i) = obj.real_time_data_set(3, i + 1);
            end
            if isnan(node.pos_x)
                obj.real_time_data_set(1, obj.real_time_data_set_size) = obj.real_time_data_set(1, obj.real_time_data_set_size - 1);
            else
                obj.real_time_data_set(1, obj.real_time_data_set_size) = node.pos_x;
            end
            if isnan(node.pos_y)
                obj.real_time_data_set(2, obj.real_time_data_set_size) = obj.real_time_data_set(2, obj.real_time_data_set_size - 1);
            else
                obj.real_time_data_set(2, obj.real_time_data_set_size) = node.pos_y;
            end
            obj.real_time_data_set(3, obj.real_time_data_set_size) = node.time_stamp;

            posi_var_res = var(obj.real_time_data_set(1:2, :), 1, 2);

            v_x = (obj.real_time_data_set(1, end) - obj.real_time_data_set(1, 1)) / (obj.real_time_data_set(3, end) - obj.real_time_data_set(3, 1));
            v_y = (obj.real_time_data_set(2, end) - obj.real_time_data_set(2, 1)) / (obj.real_time_data_set(3, end) - obj.real_time_data_set(3, 1));
            for i = 1 : obj.velocity_var_set_size - 1
                obj.velocity_var_set(1, i) = obj.velocity_var_set(1, i + 1);
                obj.velocity_var_set(2, i) = obj.velocity_var_set(2, i + 1);
            end
            obj.velocity_var_set(1, obj.velocity_var_set_size) = v_x;
            obj.velocity_var_set(2, obj.velocity_var_set_size) = v_y;
            velocity_var_res = var(obj.velocity_var_set, 1, 2);
            
            obj.real_time_data_resSet = [obj.real_time_data_resSet; posi_var_res(1), v_x, velocity_var_res(1), posi_var_res(2), v_y, velocity_var_res(2)];
            real_time_analysis_res = [posi_var_res(1), v_x, velocity_var_res(1), posi_var_res(2), v_y, velocity_var_res(2)];
        end

        % 对滤波结果通过滑动窗口平滑算法进行处理
        function [smooth_pos_x, smooth_pos_y] = sliding_window_smooth(obj, node)
            % 更新滑动窗口
            for i = 1 : obj.smooth_window_max_size - 1
                obj.smooth_posiRes_set(1, i) = obj.smooth_posiRes_set(1, i + 1);
                obj.smooth_posiRes_set(2, i) = obj.smooth_posiRes_set(2, i + 1);
                obj.smooth_posiRes_set(3, i) = obj.smooth_posiRes_set(3, i + 1);
            end
            obj.smooth_posiRes_set(1, obj.smooth_window_max_size) = node.pos_x;
            obj.smooth_posiRes_set(2, obj.smooth_window_max_size) = node.pos_y;
            obj.smooth_posiRes_set(3, obj.smooth_window_max_size) = node.time_stamp;
            
            % 计算数据处理区间的速度，角度变化

            obj.smooth_deg_set = [obj.smooth_deg_set; obj.getDeg([0, 0] ,[obj.smooth_posiRes_set(1:2, end)])];

            vxs = zeros(obj.smooth_velocity_size, 1);
            vys = zeros(obj.smooth_velocity_size, 1);
            for i = 1 : obj.smooth_velocity_size 
                v_x = (obj.smooth_posiRes_set(1, end) - obj.smooth_posiRes_set(1, end - i)) / (obj.smooth_posiRes_set(3, end) - obj.smooth_posiRes_set(3, end - i));
                v_y = (obj.smooth_posiRes_set(2, end) - obj.smooth_posiRes_set(2, end - i)) / (obj.smooth_posiRes_set(3, end) - obj.smooth_posiRes_set(3, end - i));
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
            v = sqrt(v_x ^ 2 + v_y ^ 2);
     
%             disp([num2str(v_x),'  ',num2str(v_y), ' ', num2str(v)]);
            obj.smooth_analysis_set = [obj.smooth_analysis_set; v_x, v_y, v];
            if v <= obj.smooth_static_threshold % 如果速度小于0.5m/s 认为是静止状态，平滑窗口大小增加， 并建立静止中点
                obj.smooth_window_size = min(obj.smooth_window_size  + 1, obj.smooth_window_max_size);
            else  % 认为是运动状态，平滑窗口大小线性减小
                obj.smooth_window_size = max(obj.smooth_window_size - 2, obj.smooth_window_min_size);
            end
            obj.smooth_set = [obj.smooth_set;obj.smooth_window_size];
%             obj.smooth_window_size = 100;
            smooth_pos_x = mean(obj.smooth_posiRes_set(1, end - obj.smooth_window_size + 1 : end));
            smooth_pos_y = mean(obj.smooth_posiRes_set(2, end - obj.smooth_window_size + 1 : end));
        end


        % 对滤波结果通过滑动窗口平滑算法进行处理
        function [smooth_pos_x, smooth_pos_y] = sliding_window_smooth2(obj, node)
            % 更新滑动窗口
            for i = 1 : obj.smooth_window_max_size - 1
                obj.smooth_posiRes_set(1, i) = obj.smooth_posiRes_set(1, i + 1);
                obj.smooth_posiRes_set(2, i) = obj.smooth_posiRes_set(2, i + 1);
                obj.smooth_posiRes_set(3, i) = obj.smooth_posiRes_set(3, i + 1);
            end
            obj.smooth_posiRes_set(1, obj.smooth_window_max_size) = node.pos_x;
            obj.smooth_posiRes_set(2, obj.smooth_window_max_size) = node.pos_y;
            obj.smooth_posiRes_set(3, obj.smooth_window_max_size) = node.time_stamp;
            

            vxs = zeros(obj.smooth_velocity_size, 1);
            vys = zeros(obj.smooth_velocity_size, 1);
            for i = 1 : obj.smooth_velocity_size 
                v_x = (obj.smooth_posiRes_set(1, end) - obj.smooth_posiRes_set(1, end - i)) / (obj.smooth_posiRes_set(3, end) - obj.smooth_posiRes_set(3, end - i));
                v_y = (obj.smooth_posiRes_set(2, end) - obj.smooth_posiRes_set(2, end - i)) / (obj.smooth_posiRes_set(3, end) - obj.smooth_posiRes_set(3, end - i));
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
            v = sqrt(v_x ^ 2 + v_y ^ 2); % 速度因子
            distance = norm([node.pos_x, node.pos_y] - obj.smooth_static_center); % 距离因子
            deg = obj.getDeg(obj.smooth_posiRes_set(1:2, end - 2), obj.smooth_posiRes_set(1:2, end - 1), obj.smooth_posiRes_set(1:2, end));
            % 计算数据处理区间的速度，角度变化
            obj.smooth_deg_set = [obj.smooth_deg_set; deg];
            obj.smooth_distance_set = [obj.smooth_distance_set, distance];
            isLeaving = issorted(obj.smooth_distance_set(end - min(20, length(obj.smooth_distance_set)) + 1:  end));
            stdDeg = std(obj.smooth_deg_set(end - min(10, length(obj.smooth_deg_set)) + 1 : end));
            obj.smooth_analysis_set = [obj.smooth_analysis_set; v_x, v_y, v, distance, stdDeg];
            disp([num2str(v), ' ', num2str(distance), ' ', num2str(deg)]);
            
           
            % 如果速度小于0.5m/s 
            % 
            % 认为是静止状态，平滑窗口大小增加， 并建立静止中点
            if v <= obj.smooth_static_threshold || (obj.smooth_static_step > 20 && distance < 0.5)
                obj.smooth_window_size = min(obj.smooth_window_size  + 1, obj.smooth_window_max_size);
                % 处于静止中心的范围内，但是有离开的趋势
                if isLeaving
                    obj.smooth_static_center = obj.smooth_static_center * 0.9  + [node.pos_x, node.pos_y] * 0.1;
                else
                    obj.smooth_static_center = (obj.smooth_static_center * obj.smooth_static_step  + [node.pos_x, node.pos_y]) /  (obj.smooth_static_step + 1);
                end
                obj.smooth_static_step = obj.smooth_static_step + 1;
                obj.smooth_pre_factor = 0.95;
                smooth_pos_x = obj.smooth_static_center(1);
                smooth_pos_y = obj.smooth_static_center(2);
            else  % 认为是运动状态，平滑窗口大小线性减小
                obj.smooth_window_size = max(obj.smooth_window_size - 2, obj.smooth_window_min_size);
                obj.smooth_static_center = obj.smooth_static_center * obj.smooth_pre_factor + [node.pos_x, node.pos_y] * (1 - obj.smooth_pre_factor);
                obj.smooth_static_step =  0;
                obj.smooth_pre_factor = max(obj.smooth_pre_factor - 0.01, 0.5);
%                 smooth_pos_x = mean(obj.smooth_posiRes_set(1, end - obj.smooth_window_size + 1 : end));
%                 smooth_pos_y = mean(obj.smooth_posiRes_set(2, end - obj.smooth_window_size + 1 : end));

                smooth_pos_x = obj.smooth_static_center(1);
                smooth_pos_y = obj.smooth_static_center(2);
            end
            obj.smooth_set = [obj.smooth_set;obj.smooth_window_size];
        end


     

        % 更新陈旧观测噪声的置信比例 不断减小陈旧量测噪声的影响
        function updateBet(obj)
            obj.bet = (1 - obj.b) / (1 - obj.b ^ (obj.step + 1));
        end

        % 计算两个位置之间连线与坐标轴之间的角度
        function [deg] = getDeg(~, a, b, c)
            ab = b - a;
            bc = c - b;
            if norm(ab) > 1e-6 && norm(bc) > 1e-6
                cc = acos(dot(ab, bc)/ (norm(ab) * norm(bc)));
                deg = rad2deg(cc);
            else
                deg = 0;
            end
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

            X_n_n = obj.X_n1;

            P_n_n = obj.P;

            X_n1_n = F * X_n_n;                 % 4 * 1 卡尔曼滤波预测值

            P_n1_n = F * P_n_n * F' + obj.Q;        % 4 * 4 预测值的协方差矩阵 

            Z_n = cur_Z;                            % 2 * 1 观测值
            

            isValidMeasurementData = true;
            outRangeMeasurementData = false;
            real_time_analysis_res = obj.realTimeDataAnalysis(node);
            % 观测结果为NaN或者超过设定的界限那么观测结果为无效数据 
            % || Z_n(1) < 0 || Z_n(1) > 20.8 || Z_n(2) < 0 || Z_n(2) > 7.2
            if isnan(Z_n(1)) || isnan(Z_n(2)) 
                isValidMeasurementData = false;
            else

                % 新息向量
                innovation = Z_n - obj.H * X_n1_n;
                % 区间内观测值的方差 可以判断该区间内观测值的稳定情况
                
                R_diff = abs(innovation' / (obj.H * P_n1_n * obj.H' + obj.R_base) * innovation);
                obj.R_diff_arr = [obj.R_diff_arr; R_diff];
                obj.innovation_arr = [obj.innovation_arr; innovation'];

                p_x_var = real_time_analysis_res(1);
                v_x = real_time_analysis_res(2);
                v_x_var = real_time_analysis_res(3);
                p_y_var = real_time_analysis_res(4);
                v_y = real_time_analysis_res(5);
                v_y_var = real_time_analysis_res(6);
%                 disp([p_x_var, v_x, v_x_var, p_y_var, v_y, v_y_var]);
                v_x_var = obj.vb * obj.v_x_var_pre + (1 - obj.vb) * v_x_var;
                v_y_var = obj.vb * obj.v_y_var_pre + (1 - obj.vb) * v_y_var;
%                 disp([v_x_var, v_y_var]);
                if R_diff <= obj.R_upper_bound
%                     R_n = (1 - obj.bet) * obj.R + obj.bet * abs(innovation * innovation' - obj.H * P_n1_n * obj.H');
%                     R_n = [(obj.MeasNoiseVar + mearsurement_var(1)) / 2, 0;
%                           0, (obj.MeasNoiseVar + mearsurement_var(2)) / 2];
                    R_n = [(obj.MeasNoiseVar + p_x_var) * max(R_diff, 0.5), 0;
                          0, (obj.MeasNoiseVar + p_y_var) * max(R_diff, 0.5)];
                else
                    % 超过预期 需要进一步判断该段数据的可信度 有可能确实是不可靠的数据 也可能是可靠数据只是变化特别快
                    outRangeMeasurementData = true;
                    % 判断x,y方向的误差是否超过限度
                    baseRate = R_diff / obj.R_upper_bound;
                    expansionRatio = 100;
                    

                    if v_x_var > obj.MeasNoiseVar
                        r_x = obj.MeasNoiseVar * expansionRatio;
                    else
                        r_x = p_x_var;
                    end
                    if v_y_var > obj.MeasNoiseVar
                        r_y = obj.MeasNoiseVar * expansionRatio;
                    else
                        r_y = p_x_var;
                    end
                    additional_r = [r_x, 0; 0, r_y];
                    R_n = baseRate * obj.R_base + additional_r;
                end
%                 R_n = obj.b * obj.R_pre + (1 - obj.b) * R_n;
                obj.v_x_var_pre = v_x_var;
                obj.v_y_var_pre = v_y_var;
                obj.R_pre = R_n;
                if isValidMeasurementData
                    K_n = P_n1_n * obj.H' / (obj.H * P_n1_n * obj.H' + R_n);
                    obj.K = K_n;
                    P_n1_n1 = (eye(4) - K_n * obj.H) * P_n1_n;
                    X_n1_n1 = X_n1_n + K_n * (Z_n - obj.H * X_n1_n);

                end

            end

            % 用于检验结果
            if ~isValidMeasurementData
                X_n1_n1 = X_n1_n;
                P_n1_n1 = P_n1_n;
                obj.unValid_mea_arr = [obj.unValid_mea_arr; X_n1_n(1), X_n1_n(3)];
            end
            
            if outRangeMeasurementData
                obj.outrange_mea_arr = [obj.outrange_mea_arr; Z_n'];
            end

            obj.updateBet();
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
            % KFtime = obj.t;

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

            node.pos_x = obj.X_n1(1);
            node.pos_y = obj.X_n1(3);
            [smooth_pos_x, smooth_pos_y] = obj.sliding_window_smooth2(node);
            kal_res.pos_x_smo = smooth_pos_x;
            kal_res.pos_y_smo = smooth_pos_y;
            obj.step = obj.step + 1;
        end

    end
end



