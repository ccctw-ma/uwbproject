function X = myChan3_test(BSN, BS, R, dR)
    %   在myChan2.m的基础上，将其改为3维
    %   实现无线定位中的CHAN算法
    %   参考：ChanAlgorithm.m NetworkTop.m 李金伦，西南交通大学，10 December, 2004, 第一版
    %         李招华, 汪毓铎, 邵青. 基于Chan的TDOA三维定位算法[J]. 现代电信科技, 2014(11):36-40.
    %       - BSN 为基站个数，3 < BSN <= 7；
    %       - BS 为 (3, BSN) 矩阵，为各个 BS 的坐标 x 和 y 和 z
    %       - R 为 (BSN-1) 向量，为论文中的 r_{i,1}，即第 2,3,...BSN 个基站与第一个基站
    %           距 MS 的距离之差，可由TDOA乘以光速直接算得
    %       - X 为算得的 MS 的位置 x 和 y 和 z
     
        % 噪声功率：
        anchorPosition;
        % 第一次LS：
        Q = eye(BSN - 1); % (BSN-1,BSN-1)
        % K1 = 0;
        % dR(abs(dR) > 5) = 0;
        % Q = cov(dR);
        % Q = (0.5 * eye(BSN - 1) + 0.5 * ones(BSN - 1)) * (100);
        for i = 1: BSN
            K(i) = BS(1, i) ^ 2 + BS(2, i) ^ 2 + BS(3, i) ^ 2; % x^2+y^2+z^2, K(1,BSN-1)
        end
    
        % Ga (BSN-1,4)
        for i = 1: BSN - 1
            Ga(i, 1) = -(BS(1, i + 1) - BS(1, 1));
            Ga(i, 2) = -(BS(2, i + 1) - BS(2, 1));
            Ga(i, 3) = -(BS(3, i + 1) - BS(3, 1)); % 新增
            Ga(i, 4) = -R(i);
        end
    
        % h (1,BSN-1) 论文中转置就好
        for i = 1: BSN - 1
            h(i) = 0.5 * (R(i) ^ 2 - K(i + 1) + K(1));
        end
    
        % 由（14b）给出B的估计值：(4,1)
        Za0 = pinv(Ga' * pinv(Q) * Ga) * Ga' * pinv(Q) * h';
    
        % 利用这个粗略估计值计算B：(BSN-1,BSN-1)
        B = eye(BSN-1);
        for i = 1: BSN - 1
            B(i, i) = sqrt((BS(1, i + 1) - Za0(1)) ^ 2 + (BS(2 , i + 1) - Za0(2)) ^ 2 + (BS(3, i + 1) - Za0(3)) ^ 2); % 第三项
        end
    
        % FI: (BSN-1,BSN-1)
        FI = B * Q * B;
    
        % 第一次LS结果：(BSN-1,1)
        Za1 = pinv(Ga' * pinv(FI) * Ga) * Ga' * pinv(FI) * h';

        Za1(4) = abs(Za1(4));
      
        %***************************************************************
    
        % 第二次LS：
        % 第一次LS结果的协方差：(4,4)
        CovZa = pinv(Ga' * pinv(FI) * Ga);
    
        % sB：
        % sB = eye(4); % (4,4)
        % for i = 1 : 4
        %     sB(i , i) = Za1(i);
        % end
        sB = [
            Za1(1) - BS(1, 1), 0 ,0 ,0;
            0, Za1(2) - BS(2, 1), 0, 0;
            0, 0, Za1(3) - BS(3, 1), 0;
            0, 0, 0, Za1(4);
        ];
        % sFI：
        sFI = 4 * sB * CovZa * sB; % (4,4)
    
        % sGa：
        sGa = [1, 0, 0; 0, 1, 0; 0, 0, 1; 1, 1, 1]; % 改掉 (4,3)
    
        % sh
        sh  = [(Za1(1) - BS(1, 1)) ^ 2; (Za1(2) - BS(2, 1)) ^ 2; (Za1(3) - BS(3, 1)) ^ 2; Za1(4) ^ 2]; % 多了第四项 (4,1)
    
        % 第二次LS结果：
        Za2 = pinv(sGa' * pinv(sFI) * sGa) * sGa' * pinv(sFI) * sh; % (3,1)
    
        % Za = sqrt(abs(Za2));
    
        Za = sqrt(Za2);
    
        % 输出:
        % if Za1(1) < 0,
        %     out1 = -Za(1);
        % else
        %     out1 = Za(1);
        % end
        % if Za2(1) < 0,
        %     out2 = -Za(2);
        % else
        %     out2 = Za(2);
        % end
        % 
        % out = [out1;out2];
        % out1 = [Za(1) + BS(1, 1), Za(2) + BS(2, 1), Za(3) + BS(3, 1)];
        % out2 = [-Za(1) + BS(1, 1), -Za(2) + BS(2, 1), -Za(3) + BS(3, 1)];
        % if out1(3) < BS(3, 1)
        %     out = out1
        % else
        %     out = out2
        % end
        % 当要把高度取负根的时候用
        % out(3) = -out(3); 
    
        out = Za;
    
        if nargout == 1
            X = out;
        elseif nargout == 0
            disp(out);
        end
    end