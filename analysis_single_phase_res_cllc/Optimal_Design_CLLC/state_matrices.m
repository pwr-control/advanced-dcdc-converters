%% Build state-space model matrices
%% ========================================================================
%
% Description:
%   Computes the 4x4 state matrix (A) and 4x2 input matrix (B) for a the
%   resonant tank and transformer model of a CLLC converter
%
% Inputs:
%   Lr - Resonant / leakage inductance (H)
%   Lm - Magnetizing inductance (H)
%   Cr - Resonant capacitance (F)
%   R1 - Primary-side resistance (Ohm)
%   R2 - Secondary-side resistance (Ohm)
%
% Outputs:
%   A  - 4x4 system state matrix
%   B  - 4x2 input matrix
%
%% ========================================================================
function [A, B] = state_matrices(Lr, Lm, Cr, R1, R2)
    Lr1 = Lr; Lr2 = Lr; Cr1 = Cr; Cr2 = Cr;
    Delta = Lr1*Lr2 + Lr1*Lm + Lr2*Lm;
    A = zeros(4,4);
    A(1,1) = -R1*(Lr2+Lm)/Delta;  A(1,2) = -R2*Lm/Delta;
    A(1,3) = -(Lr2+Lm)/Delta;     A(1,4) = -Lm/Delta;
    A(2,1) = -R1*Lm/Delta;        A(2,2) = -R2*(Lr1+Lm)/Delta;
    A(2,3) = -Lm/Delta;           A(2,4) = -(Lr1+Lm)/Delta;
    A(3,1) = 1/Cr1;
    A(4,2) = 1/Cr2;
    
    B = zeros(4,2);
    B(1,1) = (Lr2+Lm)/Delta;  B(1,2) = -Lm/Delta;
    B(2,1) = Lm/Delta;        B(2,2) = -(Lr1+Lm)/Delta;
end