% KFclass definition & methods

% For questions/comments contact:
% leor.banin@intel.com,
% ofer.bar-shalom@intel.com,
% nir.dvorecki@intel.com,
% yuval.amizur@intel.com

% Copyright (C) 2018 Intel Corporation
% SPDX-License-Identifier: BSD-3-Clause

classdef KfFtmclass < handle
    
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

        mean_set_size
        mean_set
    end
    
    methods
        
        function obj = KfFtmclass(cfg)
            
            obj.sysNoisePos       = [cfg.posLatStd...
                                     cfg.posLatStd...
                                     cfg.heightStd...
                                     cfg.biasStd].^2; % [m^2]
            obj.rangeMeasNoiseVar =  cfg.rangeMeasNoiseStd^2;
            obj.zMeasNoiseVar     =  cfg.zMeasNoiseStd^2;
            obj.knownZ            =  cfg.knownZ;
            
            obj.init.posLatStd    = cfg.init.posLatStd;
            obj.init.heightStd    = cfg.init.heightStd;
            obj.init.biasStd      = cfg.init.biasStd;
            
            obj.scaleSigmaForBigRange = cfg.scaleSigmaForBigRange; % 
            obj.outlierFilterEnable   = cfg.outlierFilterEnable; % 
            obj.OutlierRangeFilter    = cfg.OutlierRangeFilter;
            obj.gainLimit             = cfg.gainLimit;
            
            obj.type.MEAS_RANG    = cfg.MEAS_RANG;
            obj.type.MEAS_CONST_Z = cfg.MEAS_CONST_Z;

            obj.mean_set_size = 50;
            obj.mean_set = ones(2, obj.mean_set_size);
        end
        
        % KF Prediction
        function predictKF(obj,F,Q)
            obj.X  = F * obj.X;          % calculate X n/n-1
            obj.P  = F * obj.P * F' + Q; % calculate P n/n-1
        end
        
        % KF Update
        function updateKF(obj,y,H,R,hi)
            K = obj.P * H' / (H * obj.P * H' + R); % calculate K - filter gain
            obj.X = obj.X + K*(y - hi);            % calculate X - Update states
            obj.P    = obj.P   - K * H * obj.P;    % calculate P - Update states covariance
        end
        
        function obj = initKF(obj,initTs,initPos)
            obj.t = initTs;         % Init. EKF time
            
            Xinit = [initPos;0];   % Initialize EKF client position states
            
            Pinit = diag([
                obj.init.posLatStd
                obj.init.posLatStd
                obj.init.heightStd
                obj.init.biasStd].^2);%             
            
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
        function F = CreateF(~)
             F = eye(4);
        end
        
        function Q = CreateQ(obj, dt)
            Q = diag( dt * obj.sysNoisePos );
        end
        
        function H = CreateH(obj, type, x_n_n, wifiAPpos)
            
            switch type
                case obj.type.MEAS_RANG % a branch used to update x and y 
                    H = (x_n_n(1:3)' -  wifiAPpos.pos') / norm (x_n_n(1:3)' -  wifiAPpos.pos'); %a unit direction vector.
                    H = [H,1]; % adding bias
                case obj.type.MEAS_CONST_Z % or E.MEAS_POSZ) % a branch used to updated z
                    H = [0, 0, 1, 0];
                otherwise
                    H = nan;
            end
        end
        
        function hi = CreateHx(obj, type, x_n_n, wifiAPpos)
            switch type
                case obj.type.MEAS_RANG % a branch used to update x and y 
                    hi = norm (x_n_n(1:3)' -  wifiAPpos.pos') + x_n_n(4); % based on line 76,xnn4 is 0.
                case obj.type.MEAS_CONST_Z  % a branch used to updated z
                    hi = x_n_n(3);
                otherwise
                    hi = nan;
            end
        end
        %%
        function [R,gain] = CreateR(obj, range, expRange,H,inov,P)
            
            R = obj.rangeMeasNoiseVar;
            minSigma = sqrt(obj.rangeMeasNoiseVar);
            if obj.scaleSigmaForBigRange
                R = ( max(minSigma,0.4*range-2) ) ^ 2;
            end

            if obj.outlierFilterEnable  % modify R if the range is too far from current solution
                tmp = svd(obj.P);
                latErrPredict = sqrt(sum(tmp(1:3)));
                %filter also negative outliers
                d = abs(range - expRange) - latErrPredict - minSigma;
                if (d > 0) || (range > obj.OutlierRangeFilter)% outlier
                    R = 20 ^ 2;
                end
            end
            inovCov = H*P*H' + R;
            gain = inov/sqrt(inovCov);
        end % CreateR
        

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
        function [posEst,updateDone,bias,latErrPredict,latErrUpdate,KFtime] = Run(obj,y,t,Rsp)
            dt    = max(0,t - obj.t);  % time difference from last update
            obj.t = (obj.t + dt);      % update current KF time
            KFtime = obj.t;
            F = obj.CreateF();         % generate the states transition matrix, an eye matrix, doing nothing.
            Q = obj.CreateQ(dt);       % generate the system noise covariance matrix
            obj.predictKF(F,Q);        % Do KF prediction
            tmp = svd(obj.P);  % the std of state
            latErrPredict = sqrt(sum(tmp(1:3))); % std sum in the prediction phase
            
            obj.Nstep = obj.Nstep + 1;
            H  = obj.CreateH(obj.type.MEAS_RANG, obj.X, Rsp);
            hi = obj.CreateHx(obj.type.MEAS_RANG, obj.X, Rsp); % calculate predicted range
            
            obj.Innovation = y - hi;
            obj.InnovationMean = (obj.InnovationMean + obj.Innovation)/obj.Nstep; % useless
            obj.InnovationStd = (obj.Innovation - obj.InnovationMean)/obj.Nstep; % useless

            [R,gain]  = obj.CreateR(y, hi,H,obj.Innovation,obj.P);
            if abs(gain) < obj.gainLimit
                obj.updateKF(y,H,R,hi); % Do KF update
                updateDone = 1;
            else
                updateDone = 0;
            end
            % up update x and y
            % below update z
            Hz  = obj.CreateH(obj.type.MEAS_CONST_Z, obj.X, Rsp);
            obj.updateKF(obj.knownZ,  Hz,  obj.zMeasNoiseVar,  obj.X(3)); % Do KF update
            
            posEst = obj.X(1:3); % updated current position estimation vector
            
            bias = obj.X(4);
            
            tmp = svd(obj.P);
            latErrUpdate = sqrt(sum(tmp(1:3)));% std sum in the update phase
        end % function Run

    end % methods
end % classdef




