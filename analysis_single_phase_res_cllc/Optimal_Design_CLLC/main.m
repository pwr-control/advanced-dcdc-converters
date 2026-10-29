%% High-Power Converter System Optimization & Simulation
%% ========================================================================
%
% Description:
%   This script initializes system specifications, magnetic core parameters 
%   (Steinmetz model), switching loss models for Wolfspeed SiC MOSFETs, and 
%   optimization bounds for a high-power power electronics converter (e.g., 
%   resonant or dual active bridge converter). It then executes the 
%   optimization routine to find optimal magnetizing and leakage inductances 
%   and evaluates the final performance.
%
% Dependencies:
%   - optimization.m       (Main optimization driver)
%   - evaluate.m           (Post-optimization performance evaluation)
%   - cost.m               (Cost function calculation)
%   - Constraints.m        (Optimization constraints evaluation)
%   - solve_ODE.m          (Solves differential equation for circuit states)
%   - state_matrices.m     (State-space model A and B matrices builder)
%   - compute_rms.m        (RMS current and voltage calculations)
%   - compute_lout.m       (Output inductance / load computations)
%   - compute_core_loss.m  (Steinmetz core loss evaluation)
%
% Authors: 
%   Tobias Rainer & Davide Bagnara
%
%% ========================================================================
clear; clc; close all;

%% =========================================================================
%  SYSTEM SPECIFICATIONS
%% =========================================================================
U1   = 800;
U2   = 800;
Pnom = 250e3;
fs   = 12e3;
R1   = 0.026;
R2   = 0.026;
I_ref    = Pnom / U2;

%% =========================================================================
%  CORE SPECIFICATIONS
%% =========================================================================
coredata.alpha = 1.160;       % frequency exponent  (x in Ferroxcube notation)
coredata.beta  = 2.800;       % flux density exponent (y in Ferroxcube notation)
coredata.k_stein = 42366;

n_cores        = 1;                       % start here, try 5, 10, 15, 20
coredata.Vc    = n_cores * 200e-6;
coredata.Ac    = n_cores * 3.68e-4;      % Ac also scales so Bpeak stays same
coredata.N1    = 150;

%% =========================================================================
%  OPTIMIZATION SETUP
%% =========================================================================
fr_fixed = 1.2*fs;
wr       = 2*pi*fr_fixed;

%% =========================================================================
%  SWITCHING LOSS MODEL  (Wolfspeed C3M0016120U2)
%% =========================================================================
Crss = 11e-12;
Ciss = 6000e-12;
Vds  = 800;
Vp   = 7;
Voff = 0;
Rg   = 10;
Vth  = 2.1;

tr = (Vds * Crss) / (Vp - Voff) * Rg;
tf = Rg * Ciss * log((Vp - Voff) / (Vth - Voff));

Psw_model = @(i_sw, fs) 0.5 * 2 * U1 * i_sw * (tr + tf) * fs;

%% =========================================================================
%% =========================================================================
%  EXECUTION
%% =========================================================================
Lm_init = 100e-6;
Lr_init = 10e-6;
lb = [50e-6,  1e-6];      % [Lm_min, Lr_min]
ub = [300e-6, 30e-6];     % [Lm_max, Lr_max]

param_opt = optimization(Lm_init, Lr_init, lb, ub, wr, I_ref, fs, U1, U2, R1, R2, Psw_model, Pnom, coredata);
evaluate(param_opt, wr, I_ref, fs, U1, U2, R1, R2, Psw_model, coredata);
% param_opt(1)/param_opt(2)