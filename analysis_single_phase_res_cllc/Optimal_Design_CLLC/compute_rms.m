%% Compute RMS Currents
%% =========================================================================
%
% Description:
%   Computes the average output current of the CLLC converter
%
% Inputs:
%   phi    - Selected Phase Shift (rad)
%   A      - State Matrix A (4x4)
%   B      - Input Matrix B (4x2)
%   fs     - switching frequency (Hz)
%   U1     - Primary DC side Voltage (V)
%   U2     - Secondary DC side Voltage (V)
%
% Outputs:
%   IL1rms - Primary side RMS current (A)
%   IL2rms - Secondary side RMS current (A)
%
%% =========================================================================
function [IL1rms, IL2rms] = compute_rms(phi, A, B, fs, U1, U2)
    Ts = 1/fs;
    [xt1, tau1, xt2, tau2, ~, ~] = solve_ODE(phi, A, B, fs, U1, U2);
    
    IL1sq_int1 = sum(xt1(1,:).^2) * tau1(2);
    IL1sq_int2 = sum(xt2(1,:).^2) * tau2(2);
    
    IL2sq_int1 = sum(xt1(2,:).^2) * tau1(2);
    IL2sq_int2 = sum(xt2(2,:).^2) * tau2(2);
    
    IL1rms = sqrt((2/Ts) * (IL1sq_int1 + IL1sq_int2));
    IL2rms = sqrt((2/Ts) * (IL2sq_int1 + IL2sq_int2));
end