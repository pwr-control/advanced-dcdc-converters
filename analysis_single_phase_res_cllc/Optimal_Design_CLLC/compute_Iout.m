%% Compute average Output current
%% =========================================================================
%
% Description:
%   Computes the average output current of the CLLC converter
%
% Inputs:
%   phi  - Selected Phase Shift (rad)
%   A    - State Matrix A (4x4)
%   B    - Input Matrix B (4x2)
%   fs   - switching frequency (Hz)
%   U1   - Primary DC side Voltage (V)
%   U2   - Secondary DC side Voltage (V)
%
% Outputs:
%   Iout - average output current (A)
%
%% =========================================================================
function Iout = compute_Iout(phi, A, B, fs, U1, U2)
    Ts = 1/fs;
    [xt1, tau1, xt2, tau2, ~, ~] = solve_ODE(phi, A, B, fs, U1, U2);
    I1 = sum(xt1(2,:)) * (tau1(2));
    I2 = sum(xt2(2,:)) * (tau2(2));
    Iout = (2/Ts) * (I1 - I2);
end