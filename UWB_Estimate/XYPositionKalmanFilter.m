function [X, K, P] = XYPositionKalmanFilter(dt, X_n_n, P_n_n, Z_n)

    % F = [
    %     1, dt, 0.5*dt^2, 0, 0,    0;
    %     0, 1,  0.5*dt^2, 0, 0,    0;
    %     0, 0,     1,     0, 0,    0;
    %     0, 0,     0,     1, dt, 0.5*dt^2;
    %     0, 0,     0,     0, 1,    dt;
    %     0, 0,     0,     0, 0,    1;
    % ]

    
    F = eye(6);
    F(1, 2) = dt;
    F(1, 3) = 0.5 * dt ^ 2;
    F(2, 3) = dt;
    F(4, 5) = dt;
    F(4, 6) = 0.5 * dt ^ 2;
    F(5, 6) = dt;
    % R is the measurement covariance matrix 

    z_var = var(Z_set, 1, 1);
    R_n = [z_var(1), 0; 0, z_var(2)];
    % Q is the process noise matrix
    Q = [
        (dt ^ 4) / 2, (dt ^ 3) / 2, (dt ^ 2) / 2, 0, 0 ,0;
        (dt ^ 3) / 2, dt ^ 2, dt, 0, 0, 0;
        (dt ^ 2) / 2, dt, 1, 0, 0, 0;
        0, 0, 0, (dt ^ 4) / 2, (dt ^ 3) / 2, (dt ^ 2) / 2;
        0, 0 ,0, (dt ^ 3) / 2, dt ^ 2, dt;
        0, 0 ,0, (dt ^ 2) / 2, dt, 1;
    ] * 0.001;
    
    % H is the observation matrix Z_n = H * X_n + V_n   the X is the measurement state 
 

    H = [
        1, 0, 0, 0, 0, 0;
        0, 0, 0, 1, 0, 0;
    ];

    X_n1_n = F * X_n_n;

    P_n1_n = F * P_n_n * F' + Q;

    % The Kalman Gain 
    K_n = P_n1_n * H' * inv(H * P_n1_n * H' + R_n);

    % The State Update Equation
    X_n1_n1 = X_n1_n + K_n * (Z_n - H * X_n1_n);

     % The Covariance Update Equation 
    P_n1_n1 = (eye(6) - K_n * H) * P_n1_n * (eye(6) - K_n * H)' + K_n * R_n * K_n';

    X = X_n1_n1;
    K = K_n;
    P = P_n1_n1;

end