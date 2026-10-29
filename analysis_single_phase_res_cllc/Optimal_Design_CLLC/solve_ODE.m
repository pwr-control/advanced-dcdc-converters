%% Solves linear ODE of CLLC converter.
%% ========================================================================
%
% Description:
%   Solves the 1. Order non-homogeneous differential equation analytically
%   for an exact solution.
%
% Inputs:
%   phi   - Phase shift (rad)
%   A     - State matrix (4x4)
%   B     - Input matrix (4x2)
%   fs    - Switching frequency (Hz)
%   U1    - Primary DC side Voltage (V)
%   U2    - Secondary DC side Voltage (V)
%
% Outputs:
%   xt1   - State trajectories during first segment
%   tau1  - Time vector during first segment
%   xt2   - State trajectories during second segment
%   tau2  - Time vector during second segment
%   x0    - Starting state values
%   x1    - State values during transition from segment 1 to 2
%
%% ========================================================================
function [xt1, tau1, xt2, tau2, x0, x1] = solve_ODE(phi, A, B, fs, U1, U2)
    % Init
    ws = 2*pi*fs;  Ts = 1/fs;
    T2 = phi/ws;
    T1 = Ts/2 - T2;
    N = 300;
    
    u1 = [U1; U2];
    u2 = [U1;-U2];
    
    % Solve State Space Model
    Phi1   = expm(A*T1);  Gamma1 = A\(Phi1-eye(4))*B;
    Phi2   = expm(A*T2);  Gamma2 = A\(Phi2-eye(4))*B;
    M      = Phi2*Phi1 + eye(4);
    b      = -Phi2*(Gamma1*u1) - Gamma2*u2;
    x0     = M \ b;
    x1     = Phi1*x0 + Gamma1*u1;
    
    xp1 = -A\B*u1;
    xp2 = -A\B*u2;
    
    tau1 = linspace(0, T1, N);
    tau2 = linspace(0, T2, N);
    
    xt1 = zeros(4,N);
    xt2 = zeros(4,N);
    
    for n = 1:length(tau1)
        xt1(:,n) = expm(A*tau1(n)) * (x0 - xp1) + xp1;
        xt2(:,n) = expm(A*tau2(n)) * (x1 - xp2) + xp2;
    end
end
