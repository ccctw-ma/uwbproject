function [z, esti, pos, mean_res, k] = DvKalman(z, dt)
    persistent  zs H Q R sums
    persistent x P
    persistent firstRun

    if isempty(firstRun)
        firstRun = 1;
    
        H = [1, 0];
        
        Q = [ 1, 0;
                0, 1] * 0.01;

        zs = ones(1, 3) * z;   
        
        x = [ 0, 0 ]';

        P = 100 * eye(2);

        sums = ones(1, 5) * z;
    end
    
    A = [ 1 dt;
          0 1  ];
    
   

    xp = A*x;  
    Pp = A*P*A' + Q;    
    

    if abs(z) > 8
        z = xp(1);
    end      
    zs(1) = [];
    zs(3) = z;
    R = var(zs);

    K = Pp*H'*inv(H*Pp*H' + R);
    
    x = xp + K*(z - H*xp);
    P = Pp - K*H*Pp;   
    
    esti = xp(1);
    k = K(1);  
    pos = x(1);
    vel = x(2);

    sums(1) = [];
    sums(5) = pos;
    mean_res = mean(sums);

end
