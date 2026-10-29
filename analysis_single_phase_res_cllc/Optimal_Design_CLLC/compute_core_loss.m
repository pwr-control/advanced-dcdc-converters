%% Compute Core Losses
%% ========================================================================
%
% Description:
%   Computes Core losses based on the Simple Steinmetz equation
%
% Inputs:
%   iLm_peak  - Peak of magnetizing current (A)
%   Lm        - Magnetizing inductance (H)
%   fs        - Switching frequency (Hz)
%   coredata  - data from selected core from library (Struct)
% Outputs:
%   Pcore     - Core losses (W)

%% ========================================================================
function Pcore = compute_core_loss(iLm_peak, Lm, fs, coredata)
    % Init
    Vc = coredata.Vc;
    k_stein = coredata.k_stein;
    alpha = coredata.alpha;
    beta = coredata.beta;
    Ac = coredata.Ac;
    N1 = coredata.N1;
    
    % Compute Losses
    Bpeak = Lm * iLm_peak / (N1 * Ac);
    Pcore = k_stein * fs^alpha * Bpeak^beta * Vc;
end