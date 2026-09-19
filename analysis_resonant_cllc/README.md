# Resonant CLLC converter

Bidirectional CLLC resonant converter, 250 kW, switching at 12 kHz with the tank resonance
at `1.2 × fPWM_CLLC`; tank parameters from `single_phase_cllc_hwdata` in the library.

## Files

- `init_model.m` — initialization (see the root README); short run (`simlength = 0.25 s`),
  controller from `ctrl_cllc_setup`.
- `single_phase_cllc.slx` — the converter model.
- `cllc_analysis.m` — builds the tank transfer function `Ht(s)` (`Ls1`, `Cs1`, `Lm`, `Ls2`,
  `Cs2`, load `Rload`) from `hwdata.cllc`, plots its Bode diagram around the switching
  frequency and evaluates gain and phase at `fPWM_CLLC`.
- `plotting_sim_results.m`, `plotting_sim_results_pdir.m`, `plotting_sim_results_ndir.m` —
  output voltage/current, device losses and resonant-tank quantities for the positive and
  negative power direction (`figures/CLLC_quantities_pdir.eps`).
- `power_loss_calculus.m` — mean powers and losses from the logged data.
- `spectrum.m` — FFT of the AC-side current.
- `transformer_sizing.m` — first-cut design of the HF transformer (800 V / 475 A, 150 kHz,
  1:1): core area and turns from Faraday's law with `Bmax`, `J`, AMMET AM-NC-412
  nanocrystalline cut cores, core and copper losses, efficiency, leakage inductance and
  short-circuit voltage estimate.
