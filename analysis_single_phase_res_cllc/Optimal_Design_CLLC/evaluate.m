%% Evaluate Results
%% ========================================================================
%
% Description:
%   Plots and prints results.
%
% Inputs:
%   params_opt    - optimized parameter
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
%% ========================================================================
function evaluate(params_opt, wr, I_ref, fs, U1, U2, R1, R2, Psw_model, coredata)
    % Init
    Lm_eval = params_opt(1);
    Lr_eval = params_opt(2);
    Cr_eval = 1/(wr^2 * Lr_eval);
    
    % Set State Space Model
    [A_eval, B_eval] = state_matrices(Lr_eval, Lm_eval, Cr_eval, R1, R2);
    
    % Sweep Phaseshift
    phi_vec = linspace(0.05, pi-0.05, 200);
    Iout_vec = zeros(size(phi_vec));
    
    % Compute Iout
    for k = 1:length(phi_vec)
        Iout_vec(k) = compute_Iout(phi_vec(k), A_eval, B_eval, fs, U1, U2);
    end
    
    % Find Phase Shift for Nominal Current
    phi_star = fzero(@(phi) compute_Iout(phi, A_eval, B_eval, fs, U1, U2) - I_ref, ...
        [1e-6, pi/2], optimset('TolX', 1e-8, 'Display', 'off'));
    fprintf('phi_star = %.4f rad = %.2f deg\n', phi_star, phi_star*180/pi);
    
    % Plot Iout vs Phase Shift
    figure;
    plot(phi_vec*180/pi, Iout_vec, 'b', 'LineWidth', 1.5);
    hold on;
    yline(I_ref, 'r--', 'I_{ref}');
    xline(phi_star*180/pi, 'g--', '\phi^*');
    grid on;
    xlabel('Phase shift \phi (deg)');
    ylabel('I_{out} (A)');
    title('Iout vs \phi');
    
    % Plot Waveforms
    [xt1, tau1, xt2, tau2, x0, x1] = solve_ODE(phi_star, A_eval, B_eval, fs, U1, U2);
    t1_us = tau1 * 1e6;
    t2_us = (tau1(end) + tau2) * 1e6;
    t_end = t2_us(end);
    
    % Magnetizing Current
    iLm1 = xt1(1,:) - xt1(2,:);
    iLm2 = xt2(1,:) - xt2(2,:);
    
    % Plot Inductor Current
    figure;
    hold on;
    plot(t1_us, xt1(1,:), 'b',   'LineWidth', 1.5);
    plot(t1_us, xt1(2,:), 'r',   'LineWidth', 1.5);
    plot(t1_us, iLm1,     'k',   'LineWidth', 1.5);
    plot(t2_us, xt2(1,:), 'b--', 'LineWidth', 1.5);
    plot(t2_us, xt2(2,:), 'r--', 'LineWidth', 1.5);
    plot(t2_us, iLm2,     'k--', 'LineWidth', 1.5);
    xline(tau1(end)*1e6, 'k:', 'T1');
    grid on;
    xlim([0, t_end]);
    xlabel('Time (\mus)');
    ylabel('Current (A)');
    legend('iLr1 - interval 1', 'iLr2 - interval 1', 'iLm - interval 1', ...
        'iLr1 - interval 2', 'iLr2 - interval 2', 'iLm - interval 2');
    title('Current waveforms - half period');
    
    % Plot Capacitor Voltage
    figure;
    hold on;
    plot(t1_us, xt1(3,:), 'b',   'LineWidth', 1.5);
    plot(t1_us, xt1(4,:), 'r',   'LineWidth', 1.5);
    plot(t2_us, xt2(3,:), 'b--', 'LineWidth', 1.5);
    plot(t2_us, xt2(4,:), 'r--', 'LineWidth', 1.5);
    xline(tau1(end)*1e6, 'k:', 'T1');
    grid on;
    xlim([0, t_end]);
    xlabel('Time (\mus)');
    ylabel('Voltage (V)');
    legend('Vcr1 - interval 1', 'Vcr2 - interval 1', ...
        'Vcr1 - interval 2', 'Vcr2 - interval 2');
    title('Capacitor voltage waveforms - half period');
    
    % Compute RMS and Losses
    [IL1rms, IL2rms] = compute_rms(phi_star, A_eval, B_eval, fs, U1, U2);
    fprintf('IL1rms = %.4f A,  IL2rms = %.4f A\n', IL1rms, IL2rms);
    fprintf('ZVS check: x0(1) = %.4f (need <0),  x1(2) = %.4f (need >0)\n', x0(1), x1(2));
    params_eval = [Lm_eval, Lr_eval];
    [J_eval, phi_star_cost] = cost(params_eval, wr, I_ref, fs, U1, U2, R1, R2, Psw_model, coredata);
    fprintf('Cost J = %.4f W\n', J_eval);
end