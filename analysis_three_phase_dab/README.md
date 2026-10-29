# DAB3 1200 V ↔ 1200 V, 250 kW

Simulink/Simscape bench of a 250 kW isolated bidirectional DC/DC stage with the three-phase dual
active bridge (DAB3): two six-step bridges of 2 kV SiC MOSFET half-bridge modules, three single-phase
transformers in star-star with floating star points, phase-shift control, 10 kHz, a battery on each
side. The sizing and the design choices are in [`dab3_sizing.md`](dab3_sizing.md); this file
describes the model and how to run it.

**Working assumptions, to be confirmed**: 1200 V on both sides, transformer ratio 1:1, transformer
frequency 10 kHz. They are the numbers of `private/dab3_param.m`; with other values the procedure of
the sizing note is the same.

## Sizing in short

| Quantity | Value |
|---|---|
| DC voltages | 1200 V / 1200 V, n = 1 (14 : 14) |
| Power, DC current | 250 kW in both directions, 208 A |
| fs, fPWM_DAB, dead time | 10 kHz; 60 kHz = 6 fs (the library modulator makes the six-step pattern at fPWM/6); 500 ns, not applied by the library modulator |
| Series inductance | 28 µH per phase (14 + 14 µH, leakage + external inductor), φ = 30° at 250 kW, Pmax = 500 kW at 90°, φ_max = 60° |
| Phase currents | 161 A rms, 240 A peak; 124 A at the commutations of both bridges (ZVS in 63 ns) |
| Transformers | 3 single-phase, 3 × AM-NC-320C nanocrystalline cut cores each, 14 turns, 0.18-0.20 T, Lm = 1 mH (gapped), Rfe = 3 kΩ |
| DC links, chokes | 500 µF / 1 mΩ and 250 µH / 2 mΩ per side (bench values), 40 A rms of six-pulse ripple at 60 kHz |
| Devices | `danfoss_SKM1700MB20R4S2I4` on both bridges, 1.04 mΩ, Coss 3.28 nF |
| Current loop | battery current of side 1, PI kp = 0.01, ki = 60 (18 Hz, PM 90°, GM 14 dB), feed-forward k_ff = 0.5 |
| Loss budget | about 2.4 kW, η ≈ 99.0 % (turn-off losses as an upper bound; 99.6 % without them) |

## Model `three_phase_dab.slx`

Root: `battery_1` and `battery_2` (library block `lithium_ion_battery` on side 1 and side 2,
`param.battery.pack_1/2`, open circuit voltage at start `battery_voltage_init_m`), `dab_modA`,
`global timing`, `measurment` (logs every `*_sim` variable at `param.glb_time.tc` in the last
`param.time.t_measure` seconds), `scopes`. Solver Configuration: local solver, Backward Euler, step
`param.glb_time.tc`, `param.sim.nonlinear_iterations`.

`dab_modA/dcdc_with_galvanic_isolation`: DC chokes `Ldc_dc1_1/2`, `Ldc_dc2_1/2` (two per side, half
of `Ldc_dc*` each), the two bridges (`three_phase_inverter_mosfet_based_with_thermal_model`, device
`param.dab3.mosfet`, heatsink `param.thermal.heatsink`; the ideal switch bridges are kept commented
out) with their DC links `CFi_dc1`, `CFi_dc2` (initial voltages `param.dab3.ic.vc_dc1/2`, priority
High), and the three `single_phase_transformer` blocks (Ld1, Ld2, Lm, Rfe, Rs1, Rs2 of
`param.dab3.hw`).

`dab_modA/dab_ctrl`: `three_phase_dab_modulator` (`fPWM_DAB`, φ = u · `param.dab3.mod.phi_max`),
normalization of the feedbacks, and `ui_ctrl1`, triggered once per PWM period by `TRGO_DAB_1`: the
current reference of the bench (`Step6`, `Step7` and the rate limiter, `param.dab3.bench`), the
current PI (library `pi_ctrl`, gains `param.dab3.ctrl`) on the battery current of side 1
(`current_battery_1`) plus the feed-forward `param.dab3.mod.k_ff` · i_ref. The output voltage loop
(`Vout Ctrl`) is in the model but not selected (Variant Source).

## How to run

1. `init_model.m`: first puts the companion library on the path (`private/library_setup.m`: the copy
   already on the path, else the folder `library` next to this repository or the one named by the
   environment variable `PWR_CONTROL_LIBRARY`, cloned from GitHub when it does not exist), then
   builds `param` (one group per subsystem, numbers in `private/dab3_param.m`), prints the timing,
   the series inductance, φ at nominal power, the transformer flux density, the switching currents
   and the transition times at the nominal point, the open circuit voltages of the batteries, and
   opens the model.
2. Simulate: 0.3 s (`param.sim.simlength`), the last 20 ms logged at `tc` (`param.sim.tc` = 100 ns,
   1000 steps per period; 500 ns for quick structural checks). Bench (`param.dab3.bench`): 0 until
   10 ms, −1 pu (power from side 2 to side 1) with a ramp of 20 pu/s, reversal at 0.1 s, +1 pu
   (side 1 to side 2) from 0.2 s to the end of the run.
3. `scripts/plotting_sim_results.m`: transformer currents and voltages, last four periods
   (`dab_ac_quantities.eps`). `spectrum.m`: spectrum of the phase current of side 1
   (`spectrum_i1_dab_transformer.eps`), harmonics h = 6k ± 1 of fs. `dab3_analysis.m`: steady state
   by harmonic superposition (nominal point, power and current against φ, map over load and
   voltage ratio, ZVS boundaries), the numbers of the sizing note; it needs only `param`.
4. Save a run with the commented `save(...)` line of `init_model.m` (`sim_results_xx.mat`, `*.mat`
   are ignored by git) and list it in this file. The checks to do with the first runs are in Sec. 10
   of `dab3_sizing.md`.

## Numerical settings and limits of the model

- tc = 100 ns: phase resolution 0.36°, 1 % of the power at 30°. The run time scales with 1/tc.
- The library modulator does not apply its `dead_time` parameter and the bridges have no Coss: the
  legs switch at once. The model gives the switching currents (sign and value at the edges), not
  the ZVS transitions, and the switching losses of the bridge blocks are those of hard switching.
- The transformer flux starts at zero: the magnetizing current has a DC offset of up to about 13 A
  that decays in about 0.9 s (Lm / (R1 ∥ R2')). Average the rising and falling edges of a leg to read
  the switching current.
- The batteries start at soc 0.85 (about 1248 V) and drop or rise by about 30 V at 208 A: on the
  default bench d = V2'/V1 ≈ 1 ± 0.05 · load.

## Library dependencies

Blocks: `three_phase_dab_modulator`, `three_phase_inverter_mosfet_based_with_thermal_model`,
`single_phase_transformer`, `lithium_ion_battery` (with the `battery_voltage_init_m` parameter),
`pi_ctrl`, `discrete_time_low_pass_filter`. Functions and classes: `init_environment`,
`timing_setup`, `hw_dab_three_phase_setup` (the series inductance it derives is overwritten by
`init_model.m` with the one of the sizing), `ctrl_dab_setup`, `device_mosfet_setup`,
`device_ideal_switch_setting`, `lithium_ion_battery_setup`, `liquid_cooled_plate_2kw_setup`, device
datasets `danfoss_SKM1700MB20R4S2I4` and `silicon_high_power_ideal_switch`. A library function that
must change for this model only goes in `private/` with the same name (private functions come before
the path); `init_model.m` prints the list at every run.

## Files

| File | Content |
|---|---|
| `three_phase_dab.slx` | Simulink/Simscape model, reads only `param.*` |
| `init_model.m` | builds `param`, writes the series inductance of the sizing over the library one, sets the initial voltages, opens the model |
| `private/dab3_param.m` | the numbers of this DAB3: operating point, PWM, hardware, series inductance, modulator, PI gains, bench |
| `private/library_setup.m` | puts the library on the path (clones it when missing) |
| `private/dab3_ideal_op.m`, `private/dab3_harmonic_op.m` | phase shift for a power (De Doncker), steady state by harmonic superposition |
| `dab3_sizing.md` | sizing note: operating point, principle, series inductance, transformer, devices and ZVS, DC links, control, loss budget, numerics, checks to do |
| `dab3_analysis.m` | steady-state analysis of the sizing note (figures and tables) |
| `scripts/plotting_sim_results.m`, `spectrum.m` | figures of a run (EPS in the current folder) |
| `animation/` | `dab3_video.m` (versions `ii`…`iv`) builds `dab3.mp4`, a sliding-window animation of transformer voltages and current (phase U) and of the output voltage/current; `growing_harmonic_video.m` produces `growing_harmonic.mp4`. They read the runs saved with the previous init (`../sim_results/sim_results_1..3.mat`, with `glb_time` at the top level), which are not in git |

## Saved runs

None yet with this init. The runs of the previous model (`sim_results_1..3.mat`: 3 × 250 kW data,
fPWM_DAB = 12 kHz, so 2 kHz on the transformers) are not comparable with this sizing.
