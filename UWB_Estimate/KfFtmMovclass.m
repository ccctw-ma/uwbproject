% KFclass definition & methods

% For questions/comments contact:
% leor.banin@intel.com,
% ofer.bar-shalom@intel.com,
% nir.dvorecki@intel.com,
% yuval.amizur@intel.com

% Copyright (C) 2018 Intel Corporation
% SPDX-License-Identifier: BSD-3-Clause

classdef KfFtmMovclass < handle
    
    properties
        P                   % KF Covariance Matrix
        X                   % KF State vector
        sysNoisePos         % System noise variance vector for position states
        rangeMeasNoiseVar       
        zMeasNoiseVar
        knownZ
        t                   % KF time (client time)
        Pe                  % copy of KF Pe to allow ellipsoid plot
        scaleSigmaForBigRange
        outlierFilterEnable
        OutlierRangeFilter
        Innovation
        InnovationMean
        InnovationStd
        Nstep
        gainLimit
        init
        type

        %测试使用
        mean_set_size
        mean_set
        InnovationSet
        X_set
        temp
    end
    
    methods
        
        function obj = KfFtmMovclass(cfg)
            
            obj.sysNoisePos       = [cfg.posLatStd...
                                     cfg.velStd...
                                     cfg.posLatStd...
                                     cfg.velStd...
                                     cfg.heightStd...
                                     cfg.biasStd] .^ 2; % [m^2]
            obj.rangeMeasNoiseVar =  cfg.rangeMeasNoiseStd ^ 2;
            obj.zMeasNoiseVar     =  cfg.zMeasNoiseStd ^ 2;
            obj.knownZ            =  cfg.knownZ;
            
            obj.init.posLatStd    = cfg.init.posLatStd;
            obj.init.heightStd    = cfg.init.heightStd;
            obj.init.velStd       = cfg.init.velStd;  
            obj.init.biasStd      = cfg.init.biasStd;
            
            obj.scaleSigmaForBigRange = cfg.scaleSigmaForBigRange; % 
            obj.outlierFilterEnable   = cfg.outlierFilterEnable; % 
            obj.OutlierRangeFilter    = cfg.OutlierRangeFilter;
            obj.gainLimit             = cfg.gainLimit;
            
            obj.type.MEAS_RANG    = cfg.MEAS_RANG;
            obj.type.MEAS_CONST_Z = cfg.MEAS_CONST_Z;

            %测试使用
            obj.mean_set_size = 50;
            obj.mean_set = ones(2, obj.mean_set_size);
            obj.InnovationSet = [];
            obj.X_set = [];
            obj.temp = zeros(1, 10);
        end
        
        % KF Prediction
        function predictKF(obj, F, Q)
            obj.X  = F * obj.X;          % calculate X n/n-1
            obj.P  = F * obj.P * F' + Q; % calculate P n/n-1

            obj.temp(1, 2) = obj.X(1);
            obj.temp(1, 7) = obj.X(3);
        end
        
       
        
        function obj = initKF(obj, initTs, initPos)
            obj.t = initTs;         % Init. EKF time
            
            Xinit = [initPos(1); 0; initPos(2); 0; initPos(3); 0];   % Initialize EKF client position states
            
            Pinit = diag([
                obj.init.posLatStd
                obj.init.velStd
                obj.init.posLatStd
                obj.init.velStd
                obj.init.heightStd
                obj.init.biasStd] .^ 2);%             
            
            % init KF:
            obj.X  = Xinit; % Init state vector
            obj.P  = Pinit; % Init state covariance matrix
            
            obj.Nstep = 0;
            obj.Innovation = 0;
            obj.InnovationMean = 0;
            obj.InnovationStd = 0;

            obj.mean_set(1, :) = obj.mean_set(1, :) * initPos(1);
            obj.mean_set(2, :) = obj.mean_set(2, :) * initPos(2);
        end
        
        %-% Create state transition matrix
        function F = CreateF(obj, dt)
             F = eye(6);
             F(1, 2) = dt;
             F(3, 4) = dt;
        end
        
        function Q = CreateQ(obj, dt)
            Q = diag(dt * obj.sysNoisePos);
        end
        
        function H = CreateH(obj, type, x_n_n, anchor_pos)
            
            switch type
                case obj.type.MEAS_RANG % a branch used to update x and y 
                    x = x_n_n(1);
                    y = x_n_n(3);
                    x_hat = anchor_pos(1);
                    y_hat = anchor_pos(2);

                    range = sqrt((x - x_hat) ^ 2 + (y - y_hat) ^ 2);
                    
                    % H = (x_n_n(1:3)' -  anchor_pos') / norm (x_n_n(1:3)' -  wifiAPpos.pos'); %a unit direction vector.
                    % 通过观测值与状态集之间的关系求导，构建雅克比矩阵

                    H = [(x - x_hat) / range, 0, (y - y_hat) / range, 0, 0];
                    H = [H, 1]; % adding bias
                case obj.type.MEAS_CONST_Z % or E.MEAS_POSZ) % a branch used to updated z
                    H = [0, 0, 1, 0];
                otherwise
                    H = nan;
            end
        end
        
        function hi = CreateHx(obj, type, x_n_n, anchor_pos)
            switch type
                case obj.type.MEAS_RANG % a branch used to update x and y 
                    hi = norm (x_n_n([1, 3])' -  anchor_pos([1, 2])) + x_n_n(6); % based on line 76,xnn4 is 0.
                case obj.type.MEAS_CONST_Z  % a branch used to updated z
                    hi = x_n_n(5);
                otherwise
                    hi = nan;
            end
        end

        %%
        function [R,gain] = CreateR(obj, range, expRange, H, inov, P)
            
            R = obj.rangeMeasNoiseVar;
            % 观测误差的标准差， 意思就是观测方面可以接受的底线就是这个值
            minSigma = sqrt(obj.rangeMeasNoiseVar);

            % disable this judgement since all the measurements are in range
            if obj.scaleSigmaForBigRange
                R = (max(minSigma, 0.4 * range - 2)) ^ 2;
            end

            % 对因为各种原因导致出现的异常观测数据进行处理
            if obj.outlierFilterEnable  % modify R if the range is too far from current solution
                tmp = svd(obj.P);
                % 这个是个先验数据集， 可以理解为预测误差的累计值， 暂时不必去深究其原理当做黑盒去使用它
                latErrPredict = sqrt(sum(tmp(2:3)));
%                 latErrPredict = 0.1;
                %filter also negative outliers
                d = abs(range - expRange) - latErrPredict - minSigma;
                % 如果新息 innovation 超过观测和预测能接受的误差和 那么这个观测数据就当做是不太可靠数据
                if (d > 0) || (range > obj.OutlierRangeFilter)  % outlier
                    toc
                    range
                    expRange
                    latErrPredict
                    minSigma
                    obj.X
                    R = 10;
                end  
            end
            inovCov = H * P * H' + R;
            gain = inov / sqrt(inovCov);
        end % CreateR
        
         % KF Update
        function updateKF(obj, y, H, R, hi)
            K = obj.P * H' / (H * obj.P * H' + R);      % calculate K - filter gain
            % K
            obj.X = obj.X + K * (y - hi);               % calculate X - Update states
             
            obj.P = obj.P   - K * H * obj.P;            % calculate P - Update states covariance
        end


        function mean_res = mean_Kf(obj, pos)
            for i = 1 : obj.mean_set_size - 1
                obj.mean_set(1, i) = obj.mean_set(1, i + 1);
                obj.mean_set(2, i) = obj.mean_set(2, i + 1);
            end
            obj.mean_set(1, obj.mean_set_size) = pos(1);
            obj.mean_set(2, obj.mean_set_size) = pos(2);
            mean_res = mean(obj.mean_set, 2);
        end

        % ----------------------------------------------
        % y : 观测值
        % t : 时间戳
        % Rsp : 此时数据的来源基站
        function [posEst, updateDone, bias, latErrPredict, latErrUpdate, KFtime] = Run(obj, y, t, Anchors)

            dt = mod(max(t - obj.t, 0) + 86400, 86400);        % time difference from last update
            if dt == 0
                dt = 0.005;
            end
            obj.t = (obj.t + dt);                      % update current KF time
            KFtime = obj.t;


            obj.temp(1, 1) = y(1);
            obj.temp(1, 6) = y(2);


            F = obj.CreateF(dt);                       % generate the states transition matrix, an eye matrix, doing nothing.
            Q = obj.CreateQ(dt);                       % generate the system noise covariance matrix
            obj.predictKF(F,Q);                        % Do KF prediction
            tmp = svd(obj.P);                          % the std of state
            latErrPredict = sqrt(sum(tmp(1:3)));       % std sum in the prediction phase
            
            obj.Nstep = obj.Nstep + 1;

            temp_res = [];
            for i = 1 : length(Anchors)
                
                anchor_pos = [Anchors(i, 1), Anchors(i, 2), Anchors(i, 3)];
                y_hat = norm(y([1 : 2]) - Anchors(i, 1 : 2));

                H  = obj.CreateH(obj.type.MEAS_RANG, obj.X, anchor_pos);  % 观测数据的状态转移方程的雅克比矩阵
                hi = obj.CreateHx(obj.type.MEAS_RANG, obj.X, anchor_pos); % calculate predicted range
            
                obj.Innovation = y_hat - hi;

                % obj.InnovationMean = (obj.InnovationMean + obj.Innovation)/obj.Nstep; % useless
                % obj.InnovationStd = (obj.Innovation - obj.InnovationMean)/obj.Nstep; % useless
                % obj.InnovationSet = [obj.InnovationSet; obj.Innovation];

                [R, gain]  = obj.CreateR(y_hat, hi, H, obj.Innovation, obj.P);
                if abs(gain) < obj.gainLimit
                    obj.updateKF(y_hat, H, R, hi); % Do KF update
                    updateDone = 1;
                    temp_res = [temp_res; obj.X(1), obj.X(3)];
                else
                    updateDone = 0;
                    temp_res = [temp_res; y([1 : 2])];
                end
            end
            % up update x and y
            % below update z 这里先不更新高度 因为观测数据里没有可用的高度信息
            % Hz  = obj.CreateH(obj.type.MEAS_CONST_Z, obj.X, Rsp);
            % obj.updateKF(obj.knownZ, Hz, obj.zMeasNoiseVar, obj.X(3)); % Do KF update
            
            obj.temp(1, 3) = obj.X(1);
            obj.temp(1, 8) = obj.X(3);

            posEst = mean(temp_res); % updated current position estimation vector
            
            bias = obj.X(6);
            tmp = svd(obj.P);
            latErrUpdate = sqrt(sum(tmp(1:3)));% std sum in the update phase

            obj.X_set = [obj.X_set; obj.temp];
        end % function Run

    end % methods
end % classdef