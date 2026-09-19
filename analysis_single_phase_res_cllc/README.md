# CLLLC resonant tank — analytic model and optimization

Time-domain analytic study of a symmetric CLLLC tank (`VL = VH = 800 V`, `n = 1`,
`Pnom = 250 kW`): the tank is written as a 4-state linear system driven by the two
square-wave bridge voltages (with phase shift), from which average and RMS currents and the
waveforms are obtained without a circuit simulation.

## Files

- `init.m` — tank data (`Lr1 = Lr2 ≈ 4.07 µH`, `Lm ≈ 16.3 µH`, `Cr1 = Cr2 ≈ 622 nF`,
  `fr ≈ 100 kHz`), phase shift `pi/6`, derived quantities (`m = Lm/Lr`, `Zr`, `Rac`).
- `state_space_equations.m` — the `A1` state matrix and input matrices of the tank, primary
  and secondary square-wave voltages, and a first-harmonic-approximation (FHA) cross-check.
  Comments partly in German.
- `Optimal_Design_CLLLC.m` — optimization of the tank and transformer for `fs = 12 kHz`,
  `fr = 1.2 fs`: Steinmetz core-loss model (Ferroxcube-style `alpha`, `beta`, `k`),
  switching-loss model of the Wolfspeed C3M0016120U2 (`tr`/`tf` from `Crss`, `Ciss`, `Rg`),
  state-space evaluation of the currents, phase shift solved with `fzero` for the required
  output current, cost function minimized with `fmincon` over the tank parameters; prints the
  resulting design.
- `CLLC_simu.slx` — Simulink counterpart of the analytic model.
