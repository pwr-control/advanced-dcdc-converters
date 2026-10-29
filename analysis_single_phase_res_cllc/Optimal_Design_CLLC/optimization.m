%% Setup the optimization wioth helper functions
%% ========================================================================
%
% Description:
%   Sets up the Optimizations parameters and calls the solver.
%
% Inputs:
%   Lm_init   - Initial guess for the magnetizing inductance (H)
%   Lr_init   - Initial guess for the resonance inductance (H)
%   lb        - Constraints of the optimization
%   ub        - Constraints of the optimization
%   wr        - angular frequency (1/s)
%   I_ref     - Reference Current (A)
%   fs        - Switching frequency (Hz)
%   U1        - Primary DC side Voltage (V)
%   U2        - Secondary DC side Voltage (V)
%   R1        - Primary Side winding resistance (Ohm)
%   R2        - Secondary side Winding resistance (Ohm)
%   Psw_model - Function for the switching Losses (W)
%   Pnom      - Nominal output power (W)
%   coredata  - data from selected core from library (Struct)
%
% Outputs:
%   params_opt  - Optimization output
%
%% ========================================================================
function params_opt = optimization(Lm_init, Lr_init, lb, ub, wr, I_ref, fs, U1, U2, R1, R2, Psw_model, Pnom, coredata)
    % Init
    params0 = [Lm_init, Lr_init];
    
    % Define Constraints and Cost Function
    costFun = @(p) deal_J(p, wr, I_ref, fs, U1, U2, R1, R2, Psw_model, coredata);
    conFun  = @(p) Constraints(p, wr, I_ref, fs, U1, U2, R1, R2, Psw_model, coredata);
    
    options = optimoptions('fmincon', ...
        'Algorithm',           'interior-point', ...
        'Display',             'iter', ...
        'MaxIter',             500, ...
        'OptimalityTolerance', 1e-6, ...
        'ConstraintTolerance', 1e-6);
    
    % Minimizing Cost Function
    [params_opt, J_opt, exitflag, output] = fmincon(costFun, params0, ...
        [], [], [], [], lb, ub, conFun, options);
    
    % Evaluate optimized Parameters
    Lm_opt = params_opt(1);
    Lr_opt = params_opt(2);
    Cr_opt = 1 / (wr^2 * Lr_opt);
    fprintf('Optimal Lm = %.4f uH,  Lr = %.4f uH, Cr = %.4f nF, J = %.4f W, Efficiency = %.4f %\n', ...
        Lm_opt*1e6, Lr_opt*1e6, Cr_opt*1e9, J_opt, (1 - J_opt/Pnom)*100);
    
    % Check Constraints
    [c_check, ~] = conFun(params_opt);
    fprintf('ZVS primary   ir1(t0) = %.4f  (must be <=0)\n', c_check(1));
    fprintf('ZVS secondary ir2(t1) = %.4f  (must be >=0)\n', -c_check(2));
    fprintf('phi bounds    phi  = %.4f  (0 =< c(3) =< 90°)\n', -c_check(3)*180/pi);
    fprintf('Flux bounds    Bpeak - Bsat  = %.4f  (Bpeak - Bsat <= 0)\n', c_check(5));
    fprintf('k ratio bound    5*Lr - Lm = %.4e H  (must be <= 0, k = %.2f)\n', ...
        c_check(6), params_opt(1)/params_opt(2));
    
    if exitflag > 0
        disp('Optimisation converged successfully.')
    else
        fprintf('Warning: exitflag = %d  —  %s\n', exitflag, output.message);
    end
end
%% ========================================================================
%
% Description:
%   Defines Cost function for solver compability.
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
%
%% ========================================================================
function J = deal_J(params, wr, I_ref, fs, U1, U2, R1, R2, Psw_model, coredata)
[J, ~] = cost(params, wr, I_ref, fs, U1, U2, R1, R2, Psw_model, coredata);
end