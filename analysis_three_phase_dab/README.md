# Three-phase dual active bridge (DAB3)

Three-phase DAB rated `3 × 250 kW`, same DC-link levels and timing as the single-phase
study (12 kHz, 2 µs deadtime). The SiC MOSFET thermal model is enabled by default
(`use_mosfet_thermal_model = 1`, `danfoss_SKM1700MB20R4S2I4`).

## Files

- `init_model.m` — initialization (see the root README); `hwdata.three_phase_dab` comes from
  `three_phase_dab_hwdata`.
- `three_phase_dab.slx` — the DAB3 model.
- `scripts/plotting_sim_results.m` — DAB currents and secondary-side voltages
  (`figures/sim_results_1/dab_ac_quantities.eps`).
- `spectrum.m` — spectrum of the AC-side current.
- `sim_results/` — three stored runs (`sim_results_1..3.mat`) used by the plots and by the
  animations.
- `animation/` — `dab3_video.m` (versions `ii`…`iv`) builds `dab3.mp4`, a sliding-window
  animation of transformer voltages and current (phase U) and of the output voltage/current
  from `sim_results_3.mat`; `growing_harmonic_video.m` produces `growing_harmonic.mp4`, an
  illustrative animation of a harmonic with linearly growing amplitude. Both are the sources
  of the videos linked from the organization page.
