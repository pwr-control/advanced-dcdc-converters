# Single-phase dual active bridge

250 kW single-phase DAB between two ~1100 V DC links (690 V application voltage), switching
at 12 kHz with 2 µs deadtime, with the resonant/leakage frequency set to `fPWM_DAB/5`.

## Files

- `init_model.m` — full initialization (see the root README); the DAB controller is
  `ctrl_dab_setup` with DC-link voltage loop and current loop (`dab_ctrl.kp_idc = 0.02`,
  `ki_idc = 1`, `ki_udc = 35`). Device thermal models are off by default.
- `single_phase_dab.slx` — model of the DAB with transformer, DC-side filters, phase-shift
  modulator and controller, between a battery model on one side and a single-phase inverter
  connected to the AC grid on the other.
- `dab_modulator.slx` — the phase-shift modulator alone.
- `plotting_results.m` — DAB input/output voltage and current, transformer primary and
  secondary quantities, DC and AC grid, single-phase-inverter section (Q1/Q2 losses,
  voltages, currents), DAB device losses; EPS output.
- `plotting_results_zvs.m` — per-device (Q1…Q8) current/voltage, snubber current and gate
  command around the switching instants, to check ZVS; loads `sim_result_1.mat`.
- `power_loss_calculus.m` — mean input/output powers and loss balance from the logged data.
- `spectrum.m` — FFT of the AC-side current.
