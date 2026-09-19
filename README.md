# advanced-dcdc-converters

Simulink/Simscape studies of isolated bidirectional DC-DC converters for high-power
applications (250 kW class, 690 V AC application voltage, ~1100 V DC link): the single-phase
dual active bridge (DAB), the three-phase dual active bridge (DAB3) and the resonant CLLC
converter, plus an analytic/optimization study of a CLLLC resonant tank.

## Prerequisites

- MATLAB with Simulink, Simscape and Simscape Electrical.
- The companion [library](https://github.com/pwr-control/library) repository on the MATLAB
  path **with subfolders**. The init scripts call its setup functions
  (`init_environment`, `timing_setup`, `*_hwdata`, `ctrl_dab_setup`, `ctrl_cllc_setup`,
  `device_igbt_setup`, `device_mosfet_setup`, ...) and the models use its Simscape components
  (MOSFET/IGBT loss and thermal models, transformers) and C-Caller control code.

## How to use a project

1. Run `init_model.m` in the project folder: it sets the global timing (`fpwm = 4 kHz` for
   AFE/inverter, `3*fpwm = 12 kHz` for DAB and CLLC, double update), the application voltage
   (690 V), the nominal powers (250 kW per DAB/CLLC stage, 750 kW for the DAB3), the hardware
   data of every stage, the controller gains and the device set, then opens the model.
2. Simulate the `.slx`.
3. Run the plotting / spectrum / loss scripts on the logged results (`sim_results*.mat`).
   Figures are exported as EPS into `figures/` (ignored by git).

Flags in `init_model.m` select the device model of the bridges (`use_mosfet_thermal_model`,
`use_thermal_model`; default device `danfoss_SKM1700MB20R4S2I4` SiC MOSFET,
`mitsubishi_CM1200DW_24T` IGBT, or ideal switch) and whether the control blocks run as
Simulink subsystems or as C-Caller code (`use_*_ccaller`).

## Repository layout

| Folder | Content |
|---|---|
| [`analysis_single_phase_dab`](analysis_single_phase_dab) | Single-phase DAB, 250 kW: phase-shift modulator, ZVS analysis per device, losses, spectrum |
| [`analysis_three_phase_dab`](analysis_three_phase_dab) | Three-phase DAB (DAB3), 750 kW: AC-side waveforms, spectrum, MP4 animations of the transformer quantities |
| [`analysis_resonant_cllc`](analysis_resonant_cllc) | Resonant CLLC converter: tank transfer function, simulation in both power directions, losses, HF transformer sizing |
| [`analysis_single_phase_res_cllc`](analysis_single_phase_res_cllc) | Analytic state-space model of a CLLLC tank (800 V / 800 V, 250 kW) and an optimizer for the resonant elements and transformer |

Each folder has its own README.
