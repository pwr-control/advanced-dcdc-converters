%% CLLLC Time-Based Analytic Model
%  Symmetric design: VL = VH = 800V, n = 1, fr = 100kHz, Pnom = 250kW
%  State-space eigenvalue decomposition approach
clear; clc; close all;
%% =========================================================================
%  Simulation
%% =========================================================================
tc = 1e-7;
simlength = 2;

%% =========================================================================
%  SYSTEM SPECIFICATIONS
%% =========================================================================
VL      = 800;          % Low-side voltage [V]
VH      = 800;          % High-side voltage [V]
n       = 1;            % Transformer turns ratio
Pnom    = 250e3;        % Nominal power [W]
fs      = 90e3;         % Switching frequency [Hz]
phase_shift = pi/6;     % Phase shift between bridges [rad]
alpha1 = 0;
alpha2 = 0;

%% =========================================================================
%  COMPONENT DESIGN
%% =========================================================================
ws  = 2*pi*fs;          % Angular switching frequency [rad/s]
Ts  = 1/fs;             % Switching period [s]
Td  = 0.015 * Ts;

Lr1 = 4.0744e-06;       % Primary leakage inductance [H]
Lr2 = 4.0744e-06;       % Secondary leakage inductance reflected [H]
Lm  = 1.6297e-05;       % Magnetizing inductance [H]
Cr1 = 6.2170e-07;       % Primary resonant capacitor [F]
Cr2 = 6.2170e-07;       % Secondary resonant capacitor reflected [F]
Rcu = 0.1;              % Winding resistance [Ohm]
Lr  = Lr1;              % For display
Cr  = Cr1;

R1  = Rcu;
R2  = Rcu;

m   = Lm / Lr1;         % Inductance ratio Lm/Lr
Zr  = sqrt(Lr1/Cr1);    % Characteristic impedance [Ohm]
fr  = 1/(2*pi*sqrt(Lr1*Cr1));  % Series resonant frequency [Hz]
Rac = (8/pi^2) * (VH^2 / Pnom);  % Equivalent AC load [Ohm]

fprintf('===== Component Parameters =====\n');
fprintf('fs   = %.0f kHz\n',   fs/1e3);
fprintf('fr   = %.2f kHz\n',   fr/1e3);
fprintf('Zr   = %.4f Ohm\n',   Zr);
fprintf('Rac  = %.4f Ohm\n',   Rac);
fprintf('Lr   = %.4f uH\n',    Lr*1e6);
fprintf('Cr   = %.2f nF\n',    Cr*1e9);
fprintf('Lm   = %.4f uH\n',    Lm*1e6);
fprintf('m    = %.2f (Lm/Lr)\n', m);
fprintf('Phase shift = %.1f deg\n', Phase_shift*180/pi);
fprintf('================================\n\n');

Delta = Lr1*Lr2 + Lr1*Lm + Lr2*Lm;