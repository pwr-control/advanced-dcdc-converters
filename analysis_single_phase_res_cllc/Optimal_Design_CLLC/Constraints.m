%% Define Problem Constraints
%% ========================================================================
%
% Description:
%   Defines constraints.
%
% Inputs:
%   params    - converter parameter
%   wr        - angular frequency (1/s)
%   I_ref     - Reference Current (A)
%   fs        - Switching frequency (Hz)
%   U1        - Primary DC side Voltage (V)
%   U2        - Secondary DC side Voltage (V)
%   R1        - Primary Side winding resistance (Ohm)
%   R2        - Secondary side Winding resistance (Ohm)
%   Psw_model - Function for the switching Losses (W)
%   coredata  - data from selected core from library (Struct)
%
% Outputs:
%   c         - Inequality constraints
%   ceq       - Equality constraints
%
%% ========================================================================
function [c, ceq] = Constraints(params, wr, I_ref, fs, U1, U2, R1, R2, Psw_model, coredata)
    % Init
    Lm = params(1);
    Lr = params(2);
    Cr = 1 / (wr^2 * Lr);
    
    % Set State Space Model
    [A, B] = state_matrices(Lr, Lm, Cr, R1, R2);
    
    % Find Phase Shift
    [~, phi_star] = cost(params, wr, I_ref, fs, U1, U2, R1, R2, Psw_model, coredata);
    
    % Find Boundary values
    [~, ~, ~, ~, x0, x1] = solve_ODE(phi_star, A, B, fs, U1, U2);
    
    % Magnetising current at switching instants
    iLm_t0   = x0(1) - x0(2);
    iLm_t1   = x1(1) - x1(2);
    iLm_peak = max(abs(iLm_t0), abs(iLm_t1));
    
    % Flux saturation constraint
    Bpeak = Lm * iLm_peak / (coredata.N1 * coredata.Ac);
    Bsat  = 0.30;
    
    % Return
    c(1) =  x0(1);                  % ZVS polarity primary
    c(2) = -x1(2);                  % ZVS polarity secondary
    c(3) = -phi_star;               % phi >= 0
    c(4) =  phi_star - pi/2;        % phi <= pi/2
    c(5) =  Bpeak - Bsat;           % no saturation
    c(6) = (2 * Lr - Lm) / 1e-6;    % Lm >= 5*Lr (physical k ratio)
    
    ceq = [];                       % no equality constraints
end
