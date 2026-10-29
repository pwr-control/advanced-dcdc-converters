%% Defines Cost Function of the Optimization
%% ========================================================================
%
% Description:
%   Computes the cost based on power loss estimates.
%
% Inputs:
%   params    - parameter of the CLLC
%   wr        - angular frequency (1/s)
%   I_ref     - Reference Current (A)
%   U1        - Primary DC side Voltage (V)
%   U2        - Secondary DC side Voltage (V)
%   R1        - Primary Side winding resistance (Ohm)
%   R2        - Secondary side Winding resistance (Ohm)
%   Psw_model - Function for the switching Losses (W)
%   coredata  - data from selected core from library (Struct)
%
% Outputs:
%   J - Cost (W)
%   phi_star  - Demanded phase shift by Iref (rad)
%
%% ========================================================================
function [J, phi_star] = cost(params, wr, I_ref, fs, U1, U2, R1, R2, Psw_model, coredata)
    % Init
    Lm = params(1);
    Lr = params(2);
    Cr = 1 / (wr^2 * Lr);
    
    % Set State Space Model
    [A, B] = state_matrices(Lr, Lm, Cr, R1, R2);
    
    % Check that I_ref is reachable within [0, pi/2]
    Iout_lo = compute_Iout(1e-6, A, B, fs, U1, U2);
    Iout_hi = compute_Iout(pi/2, A, B, fs, U1, U2);
    
    if (Iout_lo - I_ref) * (Iout_hi - I_ref) > 0
        J        = 1e10;
        phi_star = pi/4;
        return;
    end
    
    phi_star = fzero(@(phi) compute_Iout(phi, A, B, fs, U1, U2) - I_ref, [1e-6, pi/2], optimset('TolX', 1e-8, 'Display', 'off'));
    
    % Conduction losses
    [IL1rms, IL2rms] = compute_rms(phi_star, A, B, fs, U1, U2);
    P_cond = IL1rms^2 * R1 + IL2rms^2 * R2;
    
    % Switching losses
    [xt1, ~, xt2, ~, x0, x1] = solve_ODE(phi_star, A, B, fs, U1, U2);
    i_sw1 = abs(x0(1));
    i_sw2 = abs(x1(2));
    P_sw  = Psw_model(i_sw1, fs) + Psw_model(i_sw2, fs);
    
    iLm_peak = max([abs(xt1(1,:) - xt1(2,:)), abs(xt2(1,:) - xt2(2,:))]);
    
    % Core losses
    Pcore = compute_core_loss(iLm_peak, Lm, fs, coredata);
    
    Bpeak = Lm * iLm_peak / (coredata.N1 * coredata.Ac);
    fprintf('Lm=%6.1fuH  Lr=%5.1fuH  iLm_pk=%6.1fA  Bpeak=%.3fT  Pcond=%6.1fW  Psw=%6.1fW  Pcore=%6.1fW  J=%6.1fW\n', ...
        Lm*1e6, Lr*1e6, iLm_peak, Bpeak, P_cond, P_sw, Pcore, P_cond+P_sw+Pcore);
    
    J = P_cond + P_sw + Pcore;
end