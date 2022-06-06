function X = myChan2_test(BSN, BS, R)
    %   实现无线定位中的CHAN算法
    %   参考：ChanAlgorithm.m NetworkTop.m 李金伦，西南交通大学，10 December, 2004, 第一版
    %       - BSN 为基站个数，3 < BSN <= 7；
    %       - BS 为 (2, BSN) 矩阵，为各个 BS 的坐标 x 和 y
    %       - R 为 (BSN-1) 向量，为论文中的 r_{i,1}，即第 2,3,...BSN 个基站与第一个基站
    %           距 MS 的距离之差，可由TDOA乘以光速直接算得
    %       - X 为算得的 MS 的位置 x 和 y
     
        % 噪声功率：
        anchorPosition;
        Q = eye(BSN - 1);
        % dR(abs(dR) > 5) = 0;
        % Q 是 R的协方差矩阵
        % Q = cov(dR)
        % Q = (0.5 * eye(BSN - 1) + 0.5 * ones(BSN - 1)) * (100);
        % 第一次LS：
        % K1 = 0;
        % for i = 1: BSN-1
        %     K(i) = BS(1,i+1)^2 + BS(2,i+1)^2;
        % end
        K = [K1, K2, K3, K4];
        % Ga
        for i = 1: BSN - 1
            Ga(i,1) = -(BS(1, i + 1) - BS(1, 1));
            Ga(i,2) = -(BS(2, i + 1) - BS(2, 1));
            Ga(i,3) = -R(i);
        end
    
        % h
        for i = 1 : BSN - 1
            h(i) = (R(i) ^ 2 - K(i + 1) + K(1)) / 2;
        end
    
        % 由（14b）给出B的估计值：即假设标签到基站都很远 可以使用R1进行代替 求出大致位置
        Za0 = Inverse(Ga' * Ga) * Ga' * h';
        
        Za0

        % 利用Za0这个粗略估计值计算B：
        B = eye(BSN - 1);
        for i = 1 : BSN - 1
            B(i, i) = sqrt((Za0(1) - BS(1, i + 1)) ^ 2 + (Za0(2) - BS(2, i + 1)) ^ 2);
        end
    
        % FI: 为误差矩阵fi的协方差矩阵
        FI =  B * Q * B;
    
        % 第一次LS结果：
        Za1 = Inverse(Ga' * Inverse(FI) * Ga) * Ga' * Inverse(FI) * h';

        Za1
    
        %***************************************************************
    
        % 第二次LS：
        % 第一次LS结果的协方差：
        CovZa = Inverse(Ga' * Inverse(FI) * Ga);
    
        % sB：
        % sB = eye(3);
        sB = [
            Za1(1) - BS(1, 1), 0, 0;
            0, Za1(2) - BS(2, 1), 0;
            0, 0, Za1(3)
            ];
    

        % sFI：
        sFI = 4 * sB * CovZa * sB;
    
        % sGa：
        sGa = [1, 0; 0, 1; 1, 1];
    
        % sh
        sh  = [(Za1(1) - BS(1, 1) ^ 2); (Za1(2) - BS(2, 1) ^ 2); Za1(3) ^ 2];
    
        % 第二次LS结果：
        Za2 = Inverse(sGa' * Inverse(sFI) * sGa) * sGa' * Inverse(sFI) * sh;

        Za2
        
        % Za = sqrt(abs(Za2));
        
        Zp = sqrt(Za2);
    
        out1 = [Zp(1) + BS(1, 1), Zp(2) + BS(2, 1)];
        out2 = [-Zp(1) + BS(1, 1), -Zp(2) + BS(2, 1)];    
        if nargout == 1
            X = out1;
        elseif nargout == 0
            disp(out);
        end
end