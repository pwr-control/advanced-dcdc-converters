clear;
[model, options] = init_environment('three_phase_dab');

CTRPIFF_CLIP_RELEASE = 0.001;
s = tf('s');
%[text] ### Global timing
% simulation length
simlength = 2;

fpwm = 4e3;
fpwm_afe = fpwm; % for PWM
trgo_afe = 1; % double update
fpwm_inv = fpwm; % for MPC
trgo_inv = 1; % double update
fpwm_dab = 12 * fpwm;
trgo_dab = 0; % double update
fpwm_cllc = 5 * fpwm;
trgo_cllc = 0; % double update
% t_measure = 0.648228176318064;
t_measure = 2;
tc_factor = 200; % tc is ts_afe / tc_factor
tc_decimation = 1;
delay_pwm = 0;
dead_time_afe = 2e-6;
dead_time_inv = 2e-6;
dead_time_dab = 2e-6;
dead_time_cllc = 2e-6;

glb_time = timing_setup(fpwm_afe, trgo_afe, fpwm_inv, trgo_inv, fpwm_dab, trgo_dab, ...
                fpwm_cllc, trgo_cllc, t_measure, tc_factor, tc_decimation, delay_pwm, dead_time_afe, ...
                dead_time_inv, dead_time_dab, dead_time_cllc);

% fPWM_AFE = glb_time.fPWM_AFE;
% TRGO_AFE_double_update = glb_time.TRGO_AFE_double_update;
% fPWM_INV = glb_time.fPWM_INV;
% TRGO_INV_double_update = glb_time.TRGO_INV_double_update;
% fPWM_DAB = glb_time.fPWM_DAB;
% TRGO_DAB_double_update = glb_time.TRGO_DAB_double_update;
% fPWM_CLLC = glb_time.fPWM_CLLC;
% TRGO_CLLC_double_update = glb_time.TRGO_CLLC_double_update;
% 
% ts_afe = glb_time.ts_afe;
% ts_inv = glb_time.ts_inv;
% ts_dab = glb_time.ts_dab;
% ts_cllc = glb_time.ts_cllc;
% tc = glb_time.tc;
% 
% Nc = glb_time.Nc;
% Ns_afe = glb_time.Ns_afe;
% Ns_inv = glb_time.Ns_inv;
% Ns_dab = glb_time.Ns_dab;
% Ns_cllc = glb_time.Ns_cllc;


%[text] ### Settings for simulink model initialization and data analysis
use_mosfet_thermal_model = 1;
use_thermal_model = 0;

if (use_mosfet_thermal_model || use_thermal_model)
    nonlinear_iterations = 5;
else
    nonlinear_iterations = 3;
end
load_step_time = 1.25;
transmission_delay = 125e-6*2;
sst_num_of_modules = 2;

%[text] ### 
%[text] ### Enable one/two modules
number_of_modules = 1;
enable_two_modules = number_of_modules;
%[text] ### Control Mode Settings
use_torque_curve = 1; 
use_speed_control = 1-use_torque_curve; %
use_mtpa = 1; %
use_psm_encoder = 0; % 
use_im_encoder = 1; % 
use_load_estimator = 0; %
use_estimator_from_mb = 0; % mb model based
use_motor_speed_control_mode = 0; 

% advanced dqPLL
use_dq_pll_fht_pll = 1; % 
use_dq_pll_fht_simulink_pll = 0; % 
use_dq_pll_mod1 = 0; % 
use_dq_pll_ccaller_mod1 = 0; % 
use_dq_pll_ccaller_mod2 = 0; % 

% dqPLL
use_dq_pll_mode1 = use_dq_pll_mod1;
use_dq_pll_mode2 = use_dq_pll_ccaller_mod1;
use_dq_pll_mode3 = use_dq_pll_fht_simulink_pll;
use_dq_pll_mode4 = use_dq_pll_fht_pll;

use_dq_pll_mode1_modn = 0; % simulink dqPLL
use_dq_pll_mode2_modn = 0; % ccaller dqPLL
use_dq_pll_mode3_modn = 1; % fht simulink dqPLL
use_dq_pll_mode4_modn = 0; % fht ccaller dqPLL

% single phase inverter
rpi_enable = 0; % use RPI otherwise DQ PI
system_identification_enable = 0;
use_current_controller_from_ccaller_mod1 = 1;
use_phase_shift_filter_from_ccaller_mod1 = 1;
use_sogi_from_ccaller_mod1 = 1;

% four modules in parallel connected to a dc microgrid
ixi_ref_mod1 = -0.85;
ixi_ref_mod2 = -0.85;
ixi_ref_mod3 = -0.85;
ixi_ref_mod4 = -0.85;

% common mode voltage control for hard parallelization
en_parallel_mode = 1;
if en_parallel_mode
   u_cm_comp_mod1 = 0;
   u_cm_comp_mod2 = -1;
   u_cm_comp_mod3 = -1;
   u_cm_comp_mod4 = -1;
else
    u_cm_comp_mod1 = 0;
    u_cm_comp_mod2 = 0;
    u_cm_comp_mod3 = 0;
    u_cm_comp_mod4 = 0;
end
%[text] ### Settings for CCcaller versus Simulink
use_ekf_bemf_module_1 = 1;
use_ekf_bemf_module_2 = 1;
use_observer_from_simulink_module_1 = 0;
use_observer_from_ccaller_module_1 = 0;
use_observer_from_simulink_module_2 = 0;
use_observer_from_ccaller_module_2 = 0;

% current controllers
use_current_controller_from_simulink_module_1 = 0;
use_current_controller_from_ccaller_module_1 = 1;
use_current_controller_from_simulink_module_2 = 0;
use_current_controller_from_ccaller_module_2 = 0;

% moving average filters
use_moving_average_from_ccaller_mod1 = 1;
use_moving_average_from_ccaller_mod2 = 0;
use_moving_average_from_ccaller_mod3 = 0;
use_moving_average_from_ccaller_mod4 = 0;

use_single_phase_inverter_based_FHT = 0;
use_single_phase_inverter_based_SOGI = 0;
use_single_phase_inverter_based_PHSH = 0;
use_single_phase_inverter_based_SOGI_ccaller = 1;
use_single_phase_inverter_based_PHSH_ccaller = 0;

use_system_identification_based_FHT = 0;
use_system_identification_based_SOGI = 0;
use_system_identification_based_PHSH = 0;
use_system_identification_based_SOGI_ccaller = 0;
use_system_identification_based_PHSH_ccaller = 1;


%[text] ### Single phase inverter control
iph_grid_pu_ref_1 = 1/3;
iph_grid_pu_ref_2 = 1/3.;
iph_grid_pu_ref_3 = 1/3;
time_step_ref_1 = 0.025;
time_step_ref_2 = 0.5;
time_step_ref_3 = 1;
%[text] ### Setting global behavioural (system identification versus normal functioning) and operative frequency
if system_identification_enable
    frequency_set = 300;
else
    frequency_set = 50;
end
omega_set = frequency_set*2*pi;
%[text] ### Settings average filters
mavarage_filter_frequency_base_order = 2; % 2 means 100Hz, 1 means 50Hz
dmavg_filter_enable_time = 0.025;
%%
%[text] ### Grid Emulator Settings
grid_nominal_power = 1000e3;
application_voltage = 690;
grid_nominal_current = grid_nominal_power/application_voltage/sqrt(3);

% Transformer Dyn11

if application_voltage == 690
    % trafo data
    us1 = 690; us2 = 690; fgrid = 50;
    eta = 95; ucc = 5;
    p_iron = 1800;
elseif application_voltage == 480
    % trafo data
    us1 = 480; us2 = 480; fgrid = 60;
    eta = 95; ucc = 5;
    p_iron = 1400;
else
    % trafo data
    us1 = 400; us2 = 400; fgrid = 50;
    eta = 95; ucc = 5;
    p_iron = 1000;
end

n2 = 14; n1 = floor(n2*sqrt(3));
core_area = 0.05; core_length = 2.5;
mu0 = 4*pi*1e-7; mur = 10e3;

% two simple calculation:
Lm1 = (n1^2 * mu0 * mur * core_area) / core_length;
% Lm1 = u1_nom/sqrt(3)/i1m/(2*pi*fgrid);
i1m = us1/sqrt(3)/Lm1/(2*pi*fgrid);

% reference for the voltage sequence
up_xi_pu_ref = 1; up_eta_pu_ref = 0; un_xi_pu_ref = 0; un_eta_pu_ref = 0;

% grid impedance
Lgrid_base = us1/sqrt(3)*ucc/100/2/pi/fgrid/grid_nominal_current;
if ~exist('ucc_factor', 'var')
    ucc_factor = 1;
end
eq_grid_inductance = Lgrid_base*ucc_factor; % [H]
eq_grid_resistance = 2e-3; % [Ohm]

grid_emu = grid_three_phase_emulator('Dyn11', grid_nominal_power, application_voltage, us1, us2, fgrid, ...
                eq_grid_inductance, eq_grid_resistance, eta, ucc, i1m, p_iron, n1, n2, core_area, core_length, mur, ...
                up_xi_pu_ref, up_eta_pu_ref, un_xi_pu_ref, un_eta_pu_ref);



%%
%[text] ## Global Hardware Settings
single_phase_inverter_pwr_nom = 225e3;
afe_pwr_nom = 250e3;
inv_pwr_nom = 250e3;
dab_pwr_nom = 750e3;
cllc_pwr_nom = 250e3;
fres_dab = glb_time.fPWM_DAB/5;
fres_cllc = glb_time.fPWM_CLLC*1.2;

hwdata.single_phase_inverter = single_phase_inverter_hwdata(application_voltage, single_phase_inverter_pwr_nom, glb_time.fPWM_INV);
hwdata.afe = three_phase_afe_hwdata(application_voltage, afe_pwr_nom, glb_time.fPWM_AFE); %[output:9cdfb918]
hwdata.inv = three_phase_inverter_hwdata(application_voltage, inv_pwr_nom, glb_time.fPWM_INV); %[output:33b853f5]
hwdata.dab = single_phase_dab_hwdata(application_voltage, dab_pwr_nom, glb_time.fPWM_DAB, fres_dab); %[output:635c8c4c]
hwdata.three_phase_dab = three_phase_dab_hwdata(application_voltage, dab_pwr_nom, glb_time.fPWM_DAB, fres_dab); %[output:6f2c0eb4]
hwdata.cllc = single_phase_cllc_hwdata(application_voltage, dab_pwr_nom, glb_time.fPWM_CLLC, fres_cllc); %[output:83166646]

%[text] ### Sensors endscale, and quantization
adc_quantization = 1/2^11;
adc12_quantization = adc_quantization;
adc16_quantization = 1/2^15;

Imax_adc = 1049.835;
CurrentQuantization = Imax_adc/2^11;

Umax_adc = 1500;
VoltageQuantization = Umax_adc/2^11;
%[text] ## AFE Settings and Initialization
%[text] ### Behavioural Settings

time_gain_afe_module_1 = 1.0;
time_gain_inv_module_1 = 1.0;
time_gain_afe_module_3 = 0.9988;
time_gain_afe_module_4 = 1.0020;

time_gain_inv_module_1 = 1.0005;
time_gain_inv_module_2 = 1.0;
wnp = 0;
white_noise_power_afe_mod1 = wnp;
white_noise_power_inv_mod1 = wnp;
white_noise_power_afe_mod2 = wnp;
white_noise_power_inv_mod2 = wnp;

trgo_th_generator = 0.025;

afe_pwm_phase_shift_mod1 = 0;
white_noise_power_afe_pwm_phase_shift_mod1 = 0.0;
inv_pwm_phase_shift_mod1 = 0;
white_noise_power_inv_pwm_phase_shift_mod1 = 0.0;

afe_pwm_phase_shift_mod2 = 0;
white_noise_power_afe_pwm_phase_shift_mod2 = 0.0;
inv_pwm_phase_shift_mod2 = 0;
white_noise_power_inv_pwm_phase_shift_mod2 = 0.0;

afe_pwm_phase_shift_mod3 = 0;
white_noise_power_afe_pwm_phase_shift_mod3 = 0.0;
inv_pwm_phase_shift_mod3 = 0;
white_noise_power_inv_pwm_phase_shift_mod3 = 0.0;

afe_pwm_phase_shift_mod4 = 0;
white_noise_power_afe_pwm_phase_shift_mod4 = 0.0;
inv_pwm_phase_shift_mod4 = 0;
white_noise_power_inv_pwm_phase_shift_mod4 = 0.0;
%[text] ### FRT Settings
test_index = 25; % type of fault: index
test_subindex = 4; % type of fault: subindex
% test_subindex = 1; % type of fault: subindex
enable_frt_1 = 0; % faults generated from abc
enable_frt_2 = 0; % faults generated from xi_eta_pos and xi_eta_neg
start_time_LVRT = 0.75;
asymmetric_error_type = 1;
deepPOSxi = 1;
deepPOSeta = -0.4;
deepNEGxi = 0.4;
deepNEGeta = 0.4;
frt_data = frt_settings(test_index, test_subindex, asymmetric_error_type, ...
    enable_frt_1, enable_frt_2, start_time_LVRT, deepPOSxi, deepPOSeta, deepNEGxi, deepNEGeta);
grid_fault_generator;
%[text] ### Reactive Current References Settings
% reactive current references 
enable_i_react_pos_steps = 1;
if enable_i_react_pos_steps
    time_i_react_pos_ref_1 = start_time_LVRT + error_length + 0.335;
    time_i_react_pos_ref_2 = time_i_react_pos_ref_1 + 0.5;
    i_react_pos_ref_1 = 0;
    i_react_pos_ref_2 = -ixi_ref_mod1*tan(acos(0.95));  % cos(phi) = 0.9
    i_react_pos_ref_3 = ixi_ref_mod1*tan(acos(0.95)); % cos(phi) = 0.9
else
    time_i_react_pos_ref_1 = 0;
    time_i_react_pos_ref_2 = 0;
    i_react_pos_ref_1 = 0;
    i_react_pos_ref_2 = 0;
    i_react_pos_ref_3 = 0;
end
%[text] #### 
%[text] #### DClink Lstray model (partial loop inductance)
parasitic_dclink_data; %[output:787a510a]
%%
%[text] ## INVERTER Settings and Initialization
%[text] ### Mode of operation
motor_torque_mode = 1 - use_motor_speed_control_mode; % system uses torque curve for wind application
time_start_motor_control = 0.25;
%[text] ### IM Machine settings
im = im_calculus(); %[output:84f6c1e7]
%[text] ### PSM Machine settings
psm = psm_calculus(); %[output:49271bd5]
n_sys = psm.number_of_systems;

% load
b = psm.load_friction_m;
% external_load_inertia = 6*psm.Jm_m;
external_load_inertia = 1;
%[text] ### Motor Voltage to Udc Scaling
u_psm_scale = 2/3*hwdata.inv.udc_nom/psm.ubez;
u_im_scale = 2/3*hwdata.inv.udc_nom/im.ubez;

u_psm_scale_ekf = sqrt(3)/2 * 2/3 * hwdata.inv.udc_nom/psm.ubez;
u_im_scale_ekf = (2/3)^2 * hwdata.inv.udc_nom/im.ubez;
%[text] ## **CONTROL Settings and Initialization**
%[text] #### Permanent magnet synchronous motor control with EKF based observer
psm_ctrl = ctrl_pmsm_setup(glb_time.ts_inv, psm.omega_bez, u_psm_scale, psm.Jm_norm);
% psm_ctrl.ekf = ekf_pmsm_setup(psm.Rs_norm, psm.Ls_norm, psm.Jm_norm, glb_time.ts_inv);
psm_ctrl.ekf = ekf_pmsm_setup(psm.Rs_norm, psm.Ls_norm, 1e6, glb_time.ts_inv); %[output:4f73be20]
psm_ctrl.kp_i = 0.25;
psm_ctrl.ki_i = 35;
%[text] #### Induction Motor Control
im_ctrl = ctrl_im_setup(glb_time.ts_inv, im.omega_bez, u_im_scale, im.Jm_norm);
im_ctrl.ekf = ekf_im_setup(im.alpha_norm, im.beta_norm, im.gamma_norm, im.sigma_norm, ... %[output:group:7bd2ee93] %[output:41ee8af2]
        im.mu_norm, im.Lm_norm, im.Jm_norm, glb_time.ts_inv); %[output:group:7bd2ee93] %[output:41ee8af2]
%[text] #### AFE control (with sequences)
afe_ctrl = ctrl_afe_setup(glb_time.ts_afe, grid_emu.omega_grid_nom);

kp_udc = 0.5;
ki_udc = 18.0;
kp_idc = 0.5;
ki_idc = 18.0;

%% gain for weak grids
afe_ctrl.res_pi.kp_rpi = 0.5;
afe_ctrl.res_pi.ki_rpi = 18;

%% gains for LVRT
afe_ctrl.res_pi.kp_rpi = 0.6;
afe_ctrl.res_pi.ki_rpi = 35;

%[text] #### DCDC Control
dab_ctrl = ctrl_dab_setup(kp_udc, ki_udc, kp_idc, ki_idc);
cllc_ctrl = ctrl_cllc_setup(kp_udc, ki_udc, kp_idc, ki_idc);
dab_ctrl.kp_idc = 0.2;
dab_ctrl.ki_idc = 0;
%[text] #### Resonant PI settings
pres_ctrl.kp_rpi = 0.75;
pres_ctrl.ki_rpi = 45;
pres_ctrl.delta_rpi = 0.025;
pres_ctrl.omega_set = omega_set;
pres_ctrl.res_nom = s/(s^2 + 2*pres_ctrl.delta_rpi*pres_ctrl.omega_set*s + (pres_ctrl.omega_set)^2);

pres_ctrl.Ares_nom = [0 1; -omega_set^2 -2*pres_ctrl.delta_rpi*pres_ctrl.omega_set];
pres_ctrl.Aresd_nom = eye(2) + pres_ctrl.Ares_nom*glb_time.ts_inv;
pres_ctrl.a11d = 1;
pres_ctrl.a12d = glb_time.ts_inv;
pres_ctrl.a21d = -pres_ctrl.omega_set^2*glb_time.ts_inv;
apres_ctrl.a22d = 1 -2*pres_ctrl.delta_rpi*pres_ctrl.omega_set*glb_time.ts_inv;

pres_ctrl.Bres = [0; 1];
pres_ctrl.Cres = [0 1];
pres_ctrl.Bresd = pres_ctrl.Bres*glb_time.ts_inv;
pres_ctrl.Cresd = pres_ctrl.Cres;
%[text] #### Sogi
sogi_delta = 1;
kepsilon = 2;
sogi = sogi_filter(omega_set, sogi_delta, kepsilon, glb_time.ts_afe); %[output:5e14b5f4]
%[text] #### Current control parameters DQ PI
dqvector_pi.kp_inv = 0.5;
dqvector_pi.ki_inv = 45;
dqvector_pi.pi_ctrl = dqvector_pi.kp_inv + dqvector_pi.ki_inv/s;
dqvector_pi.pid_ctrl = c2d(dqvector_pi.pi_ctrl, glb_time.ts_inv);
dqvector_pi.plant = 1/(s*grid_emu.trafo.Ld1 + 1);
dqvector_pi.plantd = c2d(dqvector_pi.plant, glb_time.ts_inv);

G = sogi.fltd.alpha * dqvector_pi.pid_ctrl * dqvector_pi.plantd;
figure; margin(G, options);  %[output:1eb52ed8]
grid on %[output:1eb52ed8]
%[text] #### Single phase inverter - with resonant PI and virtual DQ
single_phase_inverter_ctrl = ctrl_single_phase_inverter_setup(glb_time.ts_inv, pres_ctrl.omega_set, ...
    dqvector_pi.kp_inv, dqvector_pi.ki_inv, pres_ctrl.kp_rpi, pres_ctrl.ki_rpi, pres_ctrl.delta_rpi);
%[text] #### 
%[text] ### Local time alignment to master time
kp_align = 0.25;
ki_align = 18;
lim_up_align = 0.05;
lim_down_align = -0.05;
%[text] ### Simulation parameters: speed reference, load torque for energy production application
run('n_sys_generic_1M5W_torque_curve');
torque_overload_factor = 1;
%[text] ### Simulation parameters: speed reference, load torque for driver application
% rpm_sim = 3000;
rpm_sim = 17.8;
% rpm_sim = 15.2;
omega_m_sim = psm.omega_m_bez;
omega_sim = omega_m_sim*psm.number_poles/2;
tau_load_sim = psm.tau_bez/5; %N*m
b_square = 0;
%[text] ### Settings Global Filters
filters = setup_global_filters(glb_time.ts_afe, glb_time.ts_inv, glb_time.ts_dab, glb_time.tc);
%[text] ## Power semiconductors modelization, IGBT, MOSFET,  and snubber data
%[text] ### Diode rectifier
Vf_diode_rectifier = 0.35;
Rdon_diode_rectifier = 3.5e-3;
%[text] ### HeatSink settings
% Aluminum plate liquid cooled with a size fit for primepack2
% heat exchange made by an aluminum plate with a liquid flow > 28 l/min
% "A" as "ambient" here means water: so HA means delta temperature between water and
% heatsink surface
% moreover the delta temperature between water in and water out is maximum
% 5K assuming a overall power losses of 2kW 

weight = 0.150;                         % kg
no_weight = 0.150/10;                   % kg - when /10 is applied thermal inertia is not accounted 
cp_al = 900;                            % specific heat_capacity J/K/kg - aluminum
heat_capacity_hs = cp_al * weight;      % J/K
thermal_conductivity_al = 160;          % W/(m K) - aluminum
Rth_switch_HA = 15/1000;                % K/W 
Rth_mosfet_HA = Rth_switch_HA;          % K/W
Rth_diode_HA = Rth_switch_HA;           % K/W
Tambient = 40;                          % degC - water temperature
DThs_init = 0;                          % degC

heatsink = liquid_cooled_plate_2kw_setup(weight, no_weight, cp_al, heat_capacity_hs, thermal_conductivity_al, ...
    Rth_switch_HA, Rth_mosfet_HA, Rth_diode_HA, Tambient, DThs_init);
%[text] ### DEVICES settings (IGBT)
% infineon_FF650R17IE4D_B2;
% infineon_FF650R17IE4;
% infineon_FF1200R17IP5;
% danfoss_DP650B1700T104001;
% infineon_FF1200XTR17T2P5;
% infineon_FF1800R23IE7;
% infineon_FF900R12IE4
used_device = 'infineon_FF900R12IE4';

igbt.inv = device_igbt_setup(used_device, glb_time.fPWM_INV, hwdata.inv.udc_nom);
igbt.afe = device_igbt_setup(used_device, glb_time.fPWM_AFE, hwdata.afe.udc_nom);
igbt.dab = device_igbt_setup(used_device, glb_time.fPWM_DAB, hwdata.dab.udc1_nom);
igbt.cllc = device_igbt_setup(used_device, glb_time.fPWM_CLLC, hwdata.cllc.udc1_nom);
%[text] ### DEVICES settings (MOSFET)

% wolfspeed_CAB760M12HM3
% infineon_FF1000UXTR23T2M1;
% danfoss_SKM1700MB20R4S2I4
used_device = 'danfoss_SKM1700MB20R4S2I4';

mosfet.inv = device_mosfet_setup(used_device, glb_time.fPWM_INV, hwdata.inv.udc_nom);
mosfet.afe = device_mosfet_setup(used_device, glb_time.fPWM_AFE, hwdata.afe.udc_nom);
mosfet.dab = device_mosfet_setup(used_device, glb_time.fPWM_DAB, hwdata.dab.udc1_nom);
mosfet.cllc = device_mosfet_setup(used_device, glb_time.fPWM_CLLC, hwdata.cllc.udc1_nom);
%[text] ### DEVICES settings (Ideal switch)
used_device = 'silicon_high_power_ideal_switch';
ideal_switch = device_ideal_switch_setting(used_device, glb_time.fPWM_AFE, hwdata.afe.udc_nom);
ideal_switch.afe = device_ideal_switch_setting(used_device, glb_time.fPWM_AFE, hwdata.afe.udc_nom);
ideal_switch.inv = device_ideal_switch_setting(used_device, glb_time.fPWM_INV, hwdata.inv.udc_nom);
ideal_switch.dab = device_ideal_switch_setting(used_device, glb_time.fPWM_DAB, hwdata.dab.udc1_nom);
ideal_switch.cllc = device_ideal_switch_setting(used_device, glb_time.fPWM_CLLC, hwdata.cllc.udc1_nom);
%[text] ### Setting Global Faults
time_aux_power_supply_fault = 1e3;
%[text] ### Lithium Ion Battery
% nominal_battery_voltage_1 = hwdata.cllc.udc1_bez;
nominal_battery_voltage_1 = hwdata.dab.udc1_bez;
% nominal_battery_voltage_1 = hwdata.afe.udc_nom;
% nominal_battery_voltage_2 = hwdata.cllc.udc2_bez;
nominal_battery_voltage_2 = hwdata.dab.udc2_bez;
% nominal_battery_voltage_2 = hwdata.afe.udc_nom;
nominal_battery_power = 750e3;
initial_battery_soc = 0.85;
lithium_ion_battery_1 = lithium_ion_battery_setup(nominal_battery_voltage_1, nominal_battery_power, initial_battery_soc, glb_time.ts_dab); %[output:57f75010]
lithium_ion_battery_2 = lithium_ion_battery_setup(nominal_battery_voltage_2, nominal_battery_power, initial_battery_soc, glb_time.ts_dab); %[output:70ab00ce]
lithium_ion_battery_1.R0 = lithium_ion_battery_1.R0/2;
lithium_ion_battery_1.R1 = lithium_ion_battery_1.R1/2;
lithium_ion_battery_2.R0 = lithium_ion_battery_2.R0/2;
lithium_ion_battery_2.R1 = lithium_ion_battery_2.R1/2;
lithium_ion_battery_1.C1 = lithium_ion_battery_1.C1/50;
lithium_ion_battery_2.C1 = lithium_ion_battery_2.C1/50;

%[text] ### Load
trafo_load_name = 'Load Single Phase Transformer';
trafo_load_pwr_nom = 225e3;
trafo_load_u1_nom = 400;
trafo_load_n1 = 50;
trafo_load_n2 = 1;
trafo_load_u2_nom = trafo_load_u1_nom/trafo_load_n1*trafo_load_n2;
% trafo_load_f_nom = 50;
trafo_load_f_nom = frequency_set;
trafo_load_eta = 98;
trafo_load_ucc = 5;
trafo_load_i1m = 10;
trafo_load_p_iron = 2e3;
output_transformer = single_phase_transformer_setup(trafo_load_name, trafo_load_pwr_nom, trafo_load_u1_nom, ...
    trafo_load_u2_nom, trafo_load_n1, trafo_load_n2, trafo_load_f_nom, trafo_load_eta, trafo_load_ucc, ...
    trafo_load_i1m, trafo_load_p_iron);

uload = 2;
rload = uload / output_transformer.i2_nom;
lload = 250e-6 / output_transformer.n12^2;

% rload = 0.86/m12_load_trafo^2;
% lload = 3e-3/m12_load_trafo^2;
%[text] ### C-Caller Settings
open_system(model);
% Simulink.importExternalCTypes(model,'Names',{'mavgflt_output_t'});
% Simulink.importExternalCTypes(model,'Names',{'bemf_obsv_output_t'});
% Simulink.importExternalCTypes(model,'Names',{'mavgflts_output_t'});
% Simulink.importExternalCTypes(model,'Names',{'bemf_obsv_output_t'});
% Simulink.importExternalCTypes(model,'Names',{'bemf_obsv_load_est_output_t'});
% Simulink.importExternalCTypes(model,'Names',{'dqvector_pi_output_t'});
% Simulink.importExternalCTypes(model,'Names',{'sv_pwm_output_t'});
% Simulink.importExternalCTypes(model,'Names',{'global_state_machine_output_t'});
% Simulink.importExternalCTypes(model,'Names',{'global_state_machine_output_t'});
% Simulink.importExternalCTypes(model,'Names',{'first_harmonic_tracker_output_t'});
% Simulink.importExternalCTypes(model,'Names',{'dqpll_thyr_output_t'});
% Simulink.importExternalCTypes(model,'Names',{'dqpll_grid_output_t'});
% Simulink.importExternalCTypes(model,'Names',{'rpi_output_t'});
% Simulink.importExternalCTypes(model,'Names',{'phase_shift_flt_output_t'});
% Simulink.importExternalCTypes(model,'Names',{'sogi_flt_output_t'});
% Simulink.importExternalCTypes(model,'Names',{'linear_double_integrator_observer_output_t'});

%[text] ### Remove Scopes Opening Automatically
open_scopes = find_system(model, 'BlockType', 'Scope');
for i = 1:length(open_scopes)
    set_param(open_scopes{i}, 'Open', 'off');
end

%[text] ### Enable/Disable Subsystems
% 
% if use_torque_curve
%     set_param('afe_inv_psm/fixed_speed_setting', 'Commented', 'off');
%     set_param('afe_inv_psm/motor_load_setting', 'Commented', 'on');
% else
%     set_param('afe_inv_psm/fixed_speed_setting', 'Commented', 'on');
%     set_param('afe_inv_psm/motor_load_setting', 'Commented', 'off');
% end

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
%[output:9cdfb918]
%   data: {"dataType":"text","outputData":{"text":"Device AFE_THREE_PHASE: afe690V_250kW\nNominal Voltage: 690 V | Nominal Current: 270 A\nCurrent Normalization Data: 381.84 A\nVoltage Normalization Data: 563.38 V\n---------------------------\n","truncated":false}}
%---
%[output:33b853f5]
%   data: {"dataType":"text","outputData":{"text":"Device INVERTER: inv690V_250kW\nNominal Voltage: 550 V | Nominal Current: 370 A\nCurrent Normalization Data: 523.26 A\nVoltage Normalization Data: 449.07 V\n---------------------------\n","truncated":false}}
%---
%[output:635c8c4c]
%   data: {"dataType":"text","outputData":{"text":"Single Phase DAB: DAB_1200V\nNominal Power: 750000 [W]\nNormalization Voltage DC1: 1200 [V] | Normalization Current DC1: 250 [A]\nNormalization Voltage DC2: 1200 [V] | Normalization Current DC2: 250 [A]\nInternal Tank Ls: 3.183099e-06 [H] | Internal Tank Cs: 8.634708e-05 [F]\n---------------------------\n","truncated":false}}
%---
%[output:6f2c0eb4]
%   data: {"dataType":"text","outputData":{"text":"Single Phase DAB: Three_phase_DAB_1200V\nNominal Power: 750000 [W]\nNormalization Voltage DC1: 1200 [V] | Normalization Current DC1: 750 [A]\nNormalization Voltage DC2: 1200 [V] | Normalization Current DC2: 750 [A]\nInternal Tank Ls: 1.000000e-05 [H] | Internal Tank Cs: 750 [F]\n---------------------------\n","truncated":false}}
%---
%[output:83166646]
%   data: {"dataType":"text","outputData":{"text":"Single Phase CLLC: CLLC_1200V\nNominal Power: 750000 [W]\nNormalization Voltage DC1: 1200 [V] | Normalization Current DC1: 250 [A]\nNormalization Voltage DC2: 1200 [V] | Normalization Current DC2: 250 [A]\nInternal Tank Ls: 5.160246e-06 [H] | Internal Tank Cs: 8.522115e-06 [F]\n---------------------------\n","truncated":false}}
%---
%[output:787a510a]
%   data: {"dataType":"image","outputData":{"dataUri":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAOEAAACHCAYAAADgHj49AAAQAElEQVR4AeydC5xO1frHfxtlFJJyjwi5HbnmjPulC+VSlEFFSkw45VJMqRjnEBJdTpNLqUTpqCNRp5tcTipHx3GJjxzXjnKJUBQV+b\/fVWv+r2nmnXnfeXn3zCwfz+z97r3W2ms\/e\/\/2c1nPela+k+6f44DjQEw5kE\/un+OA40BMOeBAGFP2u4s7DkgOhO4tcByIMQccCGP8AM7g5d2lfMoBB0KfPhjXrbzDAQfCvPOs3Z36lAMOhD59MK5beYcDDoR551m7O\/UpB04DCH16p65bjgM+5YADoU8fjOtW3uGAA2HeedbuTn3KAQdCnz4Y1628wwEHQh8+688++0x\/\/OMf1bx5c7Vo0UINGjRQ9+7dtWvXriz3durUqVq0aFGWylOuevXqp1zvz3\/+s44cOaLvv\/9eI0aM0MaNG9Npyx2KBgccCKPBxdPQRt26dfX222\/rn\/\/8p1auXKnKlSub36fhUqbJ+vXrm\/a53vLly82x8ePHq2DBgnr44YdVo0YNcyySPydPntSJEyciqZon6jgQ5oDH\/NNPP+m7775TyZIl9fPPP+uRRx4xkhJpyT7HoAkTJujyyy\/XVVddpf\/85z\/mzgDA7NmzjURt1qyZrIQzJzP4U6hQIfXu3VsbNmzQ5s2blZiYKKTz4cOHNXToUMXHx6tRo0Z69NFHTX84fvfdd5tjt9xyi\/r27WvKI40HDBigjh076pNPPtGSJUtMP5o0aaIOHTpo\/fr1+vrrr3XDDTdo1KhRon9I\/BdffFFt2rQx7S1evDiDXuaeww6EPn2WK1as0GWXXaZLLrlEtWrV0r59+8wL\/M4772jnzp1CWkEHDhzQvHnzxPEvv\/zSSE5+A1pujTKokh988IE+\/PBDnXvuuXrjjTc4FZKKFy+uCy+8UADMFvzXv\/6lKlWqGEBxvU2bNmn37t2aMWOGkZScR3ru37\/fVhH9mzNnjrmX9957T3wQPv74YwNy2qDgt99+q4YNG5r+lS1bVrT7\/vvva+LEiaavx48fp1iuJQdCnz5apM26deu0bds2I42QEiNHjtRHH32ka6+9VmeddZahK6+8Up9++qmWLVtmjiPFihQpYqQKtwYwAEG1atWMSpuSkqLVq1dzKmxq3bq1sRvnzp1rVFTAvXfvXv33v\/8V0s3zPJUrV061a9dObbtVq1aiP0WLFtXw4cNN2ccee0wvvfSS9uzZY8oh4ZHqnucpX758pu\/58+cXH4Jjx44JUi7+50sQ4hDga46agmOiRcA5wT7HOJeLn0e6t8YL2bJlS\/MyHj161IDPFkQNBZD2d9otjhVefsAMAZzk5OS0xX73GwmGFEQa2pPPPfecpk2bJgA9ZMgQI6FRd7H3AA\/l2Ed9Zj+YcCr1799fSMmEhAT169cv+PQp+6Hu55SCueSHr0DIA0Vl6tWrl\/lK4hB47bXXBGF\/AEBsjgULFuQS9mftNuALamVcXJyxBfFmAj7oH\/\/4h5FC2ILsc+zgwYNC\/aR1bDfUPwAFgLG94DHnMiLKTZkyRTVr1jR2qC2Hmti+fXvhNAJUABrJiwpJ\/+jnF198ISS4rWO333zzjZGI2IJIONs\/ez4vb30FQl4UvvqvvvqqMOj54qKqQJUqVRLg\/Pvf\/64yZcrk+me2Zs0aXXPNNcYObNy4sVFDk5KS1LVrV6OmoZ5C5cuXV7t27dSpUydzHLXw9ttvT+UR6ioAZYtqCADYT8tAHDn2erQLuHDCBJfj2mPGjDHqIjYbNusrr7xiHDEAOz7gsGE4o1SpUsHVzD625Pnnny8k+k033WQAvnbtWqOemgJ5+I+vQIjdgG2AjYEjgi\/yyy+\/bMap2PIbkPJS5eZnhk2FLceLzZABThocGkgcVDXUS85D7HMM0IwePdrYh6+\/\/rqefvppATbO3XXXXaIsZMsH849yn3\/+uXGMcL1Vq1YJ+7Nw4cKCUEHpE88GmxSpB9ieeuopjR07VkhaPhC0\/8QTTxi7DjX2zjvvFMS16B+eXNqmf3woADKA59nyoaUcGg\/9YZ9rcm36wO\/cSr4CIV4w1KVbb73VuLB5ULioUal4wJMnTxYqT259GDn1vhjoB5RNmzYV9h4mQ8TaSk5lQjb67SsQYsswbvTWW28JlRQDn3Gt66+\/3oxv4U3DsM\/G\/bqqp4EDf\/jDH8QzQ0oiSfGinobL5NomfQVCpBwqKaoLTgiiNQoUKGCYjxrKb8qYA+6P40Au4YCvQJhLeOpuw3EgLA74DoSMZeFgIPJi69atYou9wTHOhXV3rrDjQA7ggK9ASGQFnjxc6VdccYXx0LHF4OcY5ygTDb66NhwH\/MIBX4Hw7LPPFkY+QxDpEeco4xfmuX44DkSDA74CIaFSSLsbb7zRDFEQska4GsTMgMcff9zMb4vGjbs2HAf8wgFfgbBEiRIiAuPdd98103GYT8eANUTcKExj8JmtI8eB3MIBX4HQMpXwNaJjAKU9RigUxzhnj7mt40BWOOD3Mr4E4Xnnnacff\/zRROwTKAzNmjVLDN47x4zfXynXv3A54EsQMig\/btw4EcbWvXt3E7TMhNW\/\/OUvYiA\/3Jt05R0H\/MwBX4EQdZPQNBhG5AxBwYRBEQ5FoDBR+JyzZdh35DiQ0zngKxASorZw4UITeU\/ANvMHLYPZZ\/Y4UfmUscfd1nEgp3PAVyDE80mSoIceekhMUCUQmBwr0NVXX23m1BHQTRkfMt51yXEgIg74CoT2DshTQpgauVMIVYOYs0b4mp13Zsu6reNATueAL0GY05nq+u84EA4HHAjD4ZYr6zhwGjjgQHgamOqazPUciOoN+haEZGcmgRGJgUhxQYo8Bu2jeveuMccBH3DAlyBkvJAEP4MHDzbJZFkHgVTqpEDkXCR8Y0Y+6dXJV0NyoZkzZ7r1ESJhpKsTdQ74EoTEhxI1Q8pD7pjUFgxXkPKCcxwLl0jpR3YvgsMJDEe64n2lHaJxyGjmaIUcD0LzgHeFdyaa5EsQEh\/KwD3rHNibJdEsSZ4iDVsDcKTsI+qG9pmv+O9\/\/1swddiwYSIXpqOb8iwfhvRO0ITELnrhrk5aPeIq\/TKuebq84F3hnbHvZTS2+aLRSLTbAGikzSNdO3kqSUr7pz\/9SaReB0CRXG\/Lli266KKLUquy1NiOHTsMCInOuS5xhAb+5emIiLrHL6wmtpG2QT3q17oiQYmjnvytH+H3xw9tdBwyWVC9rkNVvFEXXXPXI+Y390gq\/XCIFJjdunXT9OnTFU694LK\/a2PSn\/Xcg4ma3q+tnmhWULNr79RLAZp06W4Nr1dQbasU00UtbjjlesQyM6+VdyVPgFCBf8yiR3VkSS1W72Gwvk6dOoEzmf+nLGkxsP9YPAUnD7Voi2PYhEuXLj0lh+nMvZU1dlXBiIi6R5oNF9tI26Ae9T8q0lYT1p4bUT\/80sas7ecJWvJzLW0r215zdl5gftO\/LgtOmntb98MFuvjiizMlJnbjlOOjmZXyvytTNL9alDtb\/epfoEtWTVWFt+9ThZd7mu0l295UrbgjKt3kOnkJE+Ulvizv\/n8aOtFl3Cl9Izky2d95j6JN+aLdYHbaI+s2syZgPIRnlJyjfIGwCTlHmVDXIHfpX\/\/6V7N2HotrsgjJk08+abJCY+8AbGxCvmgsE2bbmnJdCS0YUC8imnt7dU3vUlrz+tWOqH6k1412vX\/fd7miRbsebqxgsu0mta2ofUel5EX71XHml3px3TGTsp9kwdmlC\/P\/qGIHNqnwpneVf979Ojm1h06Oa6GT025S\/iUpKvDFKhWpUEMlBj6vMslLVPbJzb\/SoNkq0\/FPKtOsc4Z9ISH1oEGD7OsS1a2vQFi8eHEBIJbeYm2FPn36mJn2zLZHPUWqkV49FAcAacWKFVW1alVTDInKYiSsFoSdCXECZw+Lp7APXVzwiJoF1JDI6Hw1KBen+IqFs9FGsZjXvaRkYUWLcKIFk203qW0lrXmwsaGejS\/SE8v2qOyITwLb3fr6Bym4Tqj9Aof36OTWFfp5xSs6PKO\/Doy\/RvvuqaGDge3RBROkrf86BXAVnt4uCAAWadVbhWq1yvK16AfvFD4F3pVok69ACDCYTc+W6UpIQNZfgHCasNoPzplQTLj00kuF\/s76BYCMtBi0CQhZTQj7sm3btkIt5bxtC8mIjchaeJEQk5AZPomkrq1z6NAhofYgze2xcLd+aYN+h+pLyXOkQS3LaMW99QLb0prw7g7VHfOJoTmf7jHLwNk2Nq9cqoOr3tHhpS9oX8pt2pXcWv8bUEm7A1t+H167SMeLlFKRPlN0\/n1vq+TkjYb4fVZ8d\/1Yrm62+cq78dVXX9nXJarbX0EY1Saz3xgZ1QAbzhTb2t69e83adgDUHmNL2nzUVmZa3HvvvRwyxKIyLOPFeCBqBBIQYnY+a+n98ssvp9iELGRCWTyy4RIfDCQwfQy3bnD5aLTjlza4r6z05awfD6rXZXFadVdF9WtUTCWOfannXpij5IfGaNcTt+jAuHbKP7G1kXAWcMcKXfD\/Ntwj24QddyJgwx2p1laHilcT1w6mrPQjuHx6+7wbwwJedPNyRfmPL0FIegt0cJZHa968uaAePXqYpdFQWYN5wKyKZcuWiZkWrOhz8uRJMSjPvEPAxvkLLrjALKwZyiacOHGiuGaZMmUytAsyOkf+G6Rt6dKlw64b3GbFgBrN0Anb4OPh7FPXD23Q51B9wX6Dgu23fos7adqmBE37eqj67RirXWs+0sK9xfRclVHa1vN1lZ11NMs2HNe3FKoftkxmW94NPubB71609vNFq6Fot4MjBnCxbBb5Zci41qZNm0wvg\/uYRURZOw8VFhBSCQmKJITsb6uOljr7uH7+eod08EvpQPhU4PBe5f8uYKNEUDeS68WyDnZYZoSdFkzYaNZuw3bb1bOQsd+w4Th+fNNHPBIVqNY0VaUEcCUnbdShzo9pfsErlLD0PMU\/utrYjqZwDP5cFDTEFc3L+xKEqHZ4QhlmuPnmm40EJO8oxzgXigGosCw++eabb2r06NEmAoSvGHYWY4z16tUTVKxYMZM4irb2\/lRAjRbfq18ebq5dg6qGTbxMRmVKqh123UiuF8s62GGZEWqjpT2z7tfBRc8Ku+3Y0aNCldRVg36nTnp3zlFalRJVtVs1T1OukF7rXkJ1ShUwtiOOnOT5G7Vq087fqZ7pqZI7duww6zayTe98Vo7lCXX0u+++E\/YdhLTCS8oy2dAzzzxjkgHjnSLiBeBYonywTYhtiFrI7HzGC1khtnLlymLtdgx9ImdWr14tnCjYnbSDJPzljlnGbY3rOlzCGeAFxphKPPh+xG2Ee82IyycviWofyz4RcPOnR6iOASqfsv1XFZLhgNFLVTYwHFC21\/hMhwSsemhVySaXVdG0nrXNEEpSYJhj+spDZogjK8Mctg22tt1wt3zIc6U6iseSde2QeFdeeaXIvA3hwUSVBDDYc8SQDh06VDhTACvAsYS6idpqbUKAR1KumgAAEABJREFUhxcLKdi4cWMhGUkW9e2334rhDUCMRMS2xGakHSTh\/vOqCLd1pKTK8TqrWrNstRHptWNZL65sFaVLcXHCtR9tYqgjKTDMcWBya6X0qKGW1S4MqKh7UlXVcIY5wukbAEYI8L5Em\/JFu8GstkfiJvLFII3mz58vBtYBC4QD5fXXXzeS0X59du7cKcCVWfuMC8bHx4ucNAzGAzhCmHD2oJISAA4B5pMBJ45tzw9DFEhqR8dShycy40Xn2sU0qXMlM8zBfvAwx4R3t2e5ncyuw3lU2ay8f\/Z9CmcbMxAWKlRIDz74oPFIApTgTqNiMrxAnlESPqFiYhvWr19fSLK0ZYPVUUC9fv16oXKec845wvmSnJwsQMjMDOxBiKRSSFnblh+GKHjQSH+2WbFT0itDXT+0Qd\/OVF+wHYOHOchXCyAbjv9U2I4fr9vibEL7ogdv8VYCBBwtOFwIU7OESopdOHDgQDHTAVWT3KPMKUQlDW4nrTrKGCOE9EOi9u\/fX1zD8zx988035mEAUPaRlLYtPwxRRGOowy9tlAkM9cSiL8nX1zB2I2FyRORgO974yj71ffe4XtpwPOIhpBxpE9qXO7Mtkg1du0ePHiZE7dlnnxXjXKiKAPG+++4zaimRJAzGA55QbZYvX95k7kYaUg41FqkL0R7EcT4CSEn2IYY22EZCnueZavTZ7ET4hz5ie2CrRNiEyVDuhzbofyzvp2zRAiIih\/jVQS1Li+ee8tG+VNtx13fH6WJYlGuHKLDT0LV79uwpwtPYJ6oF6QXwcKywJBpjhThvcKiE4lyFChVEzCngxSv6xhtvCLUWwNWtW1c4fdILW8uOOgrgmWqzYcOGLLnMUdUc7T5jvEJVXXjrRYLaVYkzwxyoqtD0xZuz1I+ZM2cq10bM8NXH8CXkC3AxSE+kTNWqVcVahTVr1hRpLaBu3bqZLxrlLGE\/BtuEqK7Mml+0aJG2bt0q1EwCwLETAPHy5cuFBxXV17bBljjV6tWr64svvgibsH1wLuHciaS+rUN\/ATPOKXss3K1f2qDffumL7ceWNR+rXelvldL6hFqet1eEswXP5qDPGRHvBu8I70q0KWaOGXsjOGW4OSRhkyZNRKQLMybwYOKMwRYEMFD37t2NfWfrsk1rEwJCbBEkoud5atiwobEFGTvkYVAHYp\/cNagYqMPMFbv\/\/vt1++23h00jR46kSaWkpIRdN\/h6zJv729\/+ZoIMgo+Hs++XNuizX\/qSth8PDOqntTNHqOh7SYYOrPy7GeagzxkR7wbvCO8K74x54FH6E3MQch+tWrXS888\/L1RIXkJulnwwePlwoiAZICQaMZrUyYiwCVFlrWRlZj51kJa0Bbgh9lFPYSjSkvA4Ry8rEh7k5DqvPPuk5o3srn8kFMrSvfOu8M5k9P5FctwXIMQZg9Nl6tSpYvxu8ODBxkkzZcoUkfre0oQJE8z5UDfKVKbevXub\/CBI1tmzZ4uB\/vjA2CFAtDYhai9DHrQFUznvKF6OB6F5wLvCOxNNijkIDxw4IGI9mQNIPGelSpUE2B555BFxrmnTprLEHECGNUIxwPM8MZSB5MT2Q7LSpud5JgbV2oSovJ73q1czVHvunOPA6eZAzEFI6FpcXJwYWLc3y\/ABY3i9evUSg\/aWkF64vW05t3UcyA0ciDkIiefEZsMFTFA1k3FRS5GK1q7LDYx29+A4kBEHYg5Cz\/N09913izE9hhGIJ2UAnw7jHUUFxTPaokULpecdpZwjx4GczIGYgRA1FC8m43x4K9u1a6cZM2YIR0rfvn1NzkekYnBgd1a8ozn5Ybi+500OxAyEOF0YjCdOtEOHDkLaMV4IMahOrF5SUtIp3lGmJzHDnuiXUI9ryZIlpj3GdPCMAnJCykh7gWQl7yjqLx+CUO24c44DZ4IDMQMhdiCSjTygzJonFygAg+bMmWPmDgJU5gQCHGJAsRkXLlyoMWPGZMgbyiFRGbsigJvIG36HWosiw8bcCceBM8CBmIHQ3htSCnABSnusaNGiZuY744MMN5AAmNhOYkqZFQE4bdm0W2JNaYsofs\/zhNRjHQuGK5CM2JtE6RAkzgyNtPXdb19wIE91IuYgZJ4fOTtZCo31ByGS\/6JyMv\/PPg1URyYC47yxx9LbkgbdBkdTZ9myZWZ2PfZl8EArjiBiPmmDGRRITUcrTE4ev\/Nhx+rlCqajG5YqPTq89AWTqzSaW94V3ploUsxBCNAYqAdceD+7du1qBulJb0HkC6FsSMTbbrvNxIGiroaaScHAPF5V2iL6gyDd6tWrmzT4XCst82Aq0fFcz9FNJtIoFnwY0jshdVWkF35bGYnVkUgq9cu45oJKTmosiIRcwUSZ9Ghfym0mWXA0t7wrvDNp36Ps\/I4ZCFFBAQidR\/3ECUOUCwHbY8eOFasw4UhhFjwRM0TQJCQkmGgYZuRTLz0CzKiggJXYU7yuzCUj4RNB27YO+wRww1BmPxATiB0ZCfERwZFEfyOpn9fqvPjEOLMqUkrnamIlpFNWRaq4TyMuP1ftq1+o61o0VLOO3VX16ltU4+YHzRoSpLGH0ia6yjfiQ4Wir+\/5RNmlhc0eF+8K74x9j6KxjRkIAQZOFpL0cmOomvaG2Geowk70BZg4V5CMlAkVuoYqit341VdfGbuSsDW8rTh4uB62IKBmnxkbtAeVK1cu4rjJ6667zoTEMWMD6evo1PjLhpVLq9axz1V51TRVeOd+lX2xu1kVqdbRz\/XH+HgDMgss1ouwVDZ5SSrwzk8YpSKteqdS2uRWFes1UyiKxjPBp8C7Em2KGQgBEuOBpCYkj0zr1q1FLhkIbymgQ\/KVKlXKLO5CGBvlcbqEYkL58uXFkAd1W7VqJX4jDamDlOS6pMiAjh8Pf3Y17TjKmAPH9+1ItcNQA7d19cy6EewfDdhuZ5WoaICFJANsFmgADGAVCJzPuPXceSZmILTsRAKNHj3a5H5hLiDEbPgGDRqod+\/eQoKRQY0xxaVLlwpvqq2b3tbzPBGcjTcUCTt8+HCTAh9PaOfOnc2EXtYpRHoxzcm2QVkcNUwwjoRwLqFiR1LX1jl06JDIJkC2AXss3G1U29i2Xsd2bUklQARZR8fBuaONzWUXaAkG3L6XH9Kh7ev1Y+0OKtTrryox6dRFWrzK8VnKhhbV+zl4MEvXTI\/nvBtfBbQr+75EcxtzEKZ3MwRpwwhiR5m0y2xngrpJ4MuLnl6dzI4xdJGRd5S6ly++Vxj7u+6uqnDpwPDavy5aknRZ2HWDrxWNdiJuo2chkZ4eOtD3fJ39UA0dTJNR3Do\/kGpQcGbt4xc3+DWrdtBimyfumKX9rYfr26pXav+JgsJUCJfwGxBZxbsQbl1bPhptENyBU4Z3JdrkSxAyjnfDDTeI+YQk\/iVzWquAagkgQ3lGM2NOet5R6tQpcszYJUXqXKlIqFCtlsp\/adOI6qa9XrH67bLVzuEGN+uHRreKbVZpQ6UbtKH+IC1qNO4UYiGWgbXmaWy1KUosOdlQxzIvq2H5xb9S4RfVMECdCk1UYoF79OLZ7bW1xs0q06yzyWpWsWJFk7SLLeO2kRB1sePZRlKfOtTNbhs43mwOXN6ZaJIvQcgNYiOyyhI2Iuop432sPV6gQAFOh6T0wtYYPySlPtE3eE9fffVVAXAaWns4TlsbJBpbBQdBuHR+4rNGCrAeXrh1g8tT\/8i1I82iKMHHw9mvdmuyil6dKLZ1EscrK9Tx\/scF9Rt2n6Bedw3WVTd204Oj7tPbyZ01Y8ydej9liCF+s8gnqwSTATupbUWRWpDpaCz4mfDc52KtiPhHV2v5loNG+sFjzkdC1EWisY2kPnWou3v3bjYRZwUHyLnOMWM48tsf1A3GA5F+zHyvU6eOmchLPClEmnxsOLyllP2tWrqbjMLWkKBr1qwRqTMA4Lp165SRZEy3YXfQcKBC8ThBzaoUU4\/LSyupbSVDCwfWE6npAWhSAJgUBpD95u3Rih1H+OkoAw7EXBLisZwwYYKZykQfiZRB2pULDBmghiK9LLFIDGCiXEaE7YcHFTXE87zUsDXylZJTBiADdvZZnyKjdmJxnK82wQZsI70+dWPZBgBNCgATMEL0p8v0zzTn0z0R3RL1Y3k\/EXU6zEoxByFxoAwXIO2QTOQXBXx4CAEMuWeQYIS3AS4cNKHuEbUT9QUKDlvbvHmzGei36S0AIg4f25YfvKPHjh2L2Hvnx7olz5Fe7VNDJN8dOGejor0+xJm851ztHcUTCrB++OEHgwf2ixYtKiThO++8Y9L\/EcvIAqEMU5AIyhT87Q\/zEUnghO0IYPlqhhO29lszIkAcDxjgDZei4X3jmjxoonzY8jsSoq4f2qDvti\/dqnma3qV0AIQ7lDjrM2Mncj4rZNtgm5Xy6ZWhbnZ5wruRa72jeEIBGOtOEGQNkJhjSKLfYsWKCXXVAiW9LR5TnDaML+LIoTyOl6yGrdk2CVvDA4YaGy4RUICUJrdpmTJljGcw3DYoH412\/NJG2vvp0LCS5vWrrYUbj2jAgv1Z5pFf7od3I1d7R3HGvPnmm3rsscdMADG2H18uUhaSwp6QI7JqcxwpaYHDFtA98MAD+uyzz\/hpvrKosU2bNjVhaIMHDxYD\/wz6E6qGq5pz7KcNW8MDhg0SLiHNUaXDrZe2PNOsCDbn45P2XFZ\/+6UN+pu2L62qXyjsxN2Hj6euCUG5UJS2jVBlMzoXjTZ4N3K1d5QhhVGjRonVlAANES9EJzDpF+lmnSh4RrHzDNoCf0h1T0Y2JgYHfpr\/hLdRBnCePHlSvNSsEcFJjrmwNTgRO8JxAxDxrLJ8Wd0xnwTU1O2B4YxDsetUjK8cc8cMHkqCrFFHiU5nzcDSpUsLBwpgRDW1hE2II8fyjLKcwxljj3meJzyozE\/ElkTq4dTJStga5SMh2mYGBeOZkdS3dbjn+fPna+nSpRHP6\/NLG9xTqL6wFsS0qzxVOvFFAIQ71Onp1So+dIkAZceU1YFj2w3N+mSnXlu+UYtXro8pT7gfBIN9z6K5jTkIibksXLiw0P03bdpkEv++9957YuUkVutlepMlJCO2l2UA05xYkZe0ifYYAGQuITYlE3dJlYF6umXLFqUXtsYx1AwcM5HOo0MaY7izXkGkbVCPdsiJw3oI\/I6E\/NIGfc+sL0kDbzdrQhSb38esCRH3+Rv6+uO\/melCSElo0KtbxFgjawxeO\/eoLHV4YafSUqen1wTA\/HvqMn29aYNxS8pc\/+giRUJ4eHlXeGfM+xalPzEHIVKKtBUYvQRWo3vPmzdPHMNpE3yfOG3wguINxSsafM7u46BBKpGzhjmD1EGlRRXFbrPl7BaG4pTJa3P6\/Ha\/dk0I1oVYMKCuWRuC9SHe7F1e0IIB9USEDpTUtqKGdW54CnVr+Qd1vaZlhgR4LF3eur0iJd4V3hn7\/kRjG3MQAgwSNyGtmLhrHS\/kH8XhEXyTgAmQ4Q3FKxp8zu5zHiRC1E8AAAiJSURBVKma1VWZqAdTcf44ijfOLD\/xocllVQTZCB1syaS2lZSWAGcoIqInGsS7wjsTTYo5CLkZwEaoGjYeA7DNmzcXgMQRw\/lwiPmD1CPqnnpMV0KFRXqyEhNToSD2cfhQ5nQR+XL4uBCIgIp9uq7j2s3ZHIg5CFETkYQdO3YUM+C7dOmirl27CucMrvpw2RvJqkzhXiOr5Qk2IHMA6jVOCsCf1bquXN7hQMxBSHgaHk+GGe655x4zfemll14y4Vuel\/mqSTh18ITWrl3bPDXP80x4Gs4cJvbieSWKxvM8k4ICMHAcz6vnZd6+aTTCP0hkro3dy9AJ9xpJU65O7uZAzEEYzF4Ct1EjCVnbv3+\/AGfw+Zy0j4RnvDIuLs50m7A8hmPMD\/fHcSCIAzEHIcMLqJ7jxo0TUoMFQ4mcwZ7CVgzqq292sTNHjhyZ2h9mfjAThGgcQuYIIiAGluADwEhBPL3YvOw7chwI5kDMQeh5nphLyBgbLuT+\/fsLFRNXMC9ucGdjvY90fvjhh0VgAZLN9gfbj0AD1FzGMvmQbN++3QQNMHsDiU556\/m19dzWcQAOxByEdIKpTAzU8zKT7hDnCsHckeaToc3TQUi3hg0bioRRwe0zZHLttdeahFKo0mXLlhX3Q8ABKTpwNOH25+MSXM\/tOw7AgWAQ8vuME0BDskyePFnkF7W0cuVKoead8Q6FuCCBwEToEBBui\/HRwOGCWs0xz\/NM6kbmKgJIJOMHH3wg6nHekeNAWg7EHIS47ZEQqHCoepbIyJ1T1DckJPZfWua6344DWeFAzEGI3YcDBnd+VjrstzIMPfARwZFE35i5gT1ok0hxzJHjQCgOxAyEzJDHo8h8QQBIIqfExESx+AvEOcqE6rwfznmeJzLDYReiPhNpzzALa1\/4oX+uD\/7nQMxAiARhtsDgwYPNop+49QEkvyHOUcb\/LJTatWsn7EWGJ5g90KdPH5N+38d9d13zEQdiBkLsKKYxMd7GnEAcM57nicBsiHhPyviIV6ldIbyOYHJ7gInC2LAkiyJSB8loz7mt40BmHIgZCPGKIvlIO8HUI5wwOGXs4HZmHXfnHQdyCwdiBkK8oqibpB5kDuEdd9xhFnvJCXZgbnn47j78wYGYgZDbz5fv1MsTVeIkIZxxlJc4cCoKon7nrkHHAceBzDgQUxCS1pC0g6SsiI+PN4l82PKbSbgZpbDI7KbceceBnMSBmIEQDyhja6SjSI84R5mcxEzXV8eBSDgQMxBG0llXx3EgN3LAgTA3PtWY3JO7aKQccCCMlHOunuNAlDjgQBglRkajGXKkNmrUSCyMamns2LHRaDqmbRBJ9Pzzz4tpX4T1EaIY3CHue+rUqcGHUvcJhn\/88cd9N60ttYNR2HEgjAITo9kEUUOEvll64IEHUptnhgZ5a1IP5IAdgEdq\/0jnU5LyhGlipKHPAbcbURcdCCNi25mthJQYMGCAySJHlvL169eLWScEjJPyH2lBj1hYh5WskKKk009OThbDPEgftpRBCiF5APTs2bON1KUdki0DGM7TJinsSTfSt29fE8nEDBFywXKMSc1kDABcQ4YMSV2+DokFcR1L5ONhuhoTnO2xjLZIffoOscQBffj+++9FHlrSRhJrnFHdnHw854EwJ3M7C33v16+fmZnPWCkJke2Sb+SpYV0N5ik+9dRTSklJMYvmAAKC31lrY8aMGZo7d64Y3uGlB1QZXZLUjxs3bhSz\/j\/88EMRQsiCNpRnahkSmTJIIRa8IfXIzp07zWI1ABUVk8RVe\/bsMcvREYa4Zs0akeiYNiyxuE3NmjXtT7MNvkfuE4BxAqmPBsB9EspIxgX6xb1w\/0wRo1xuIwdCnz3R6dOny46brl27VjafaqtWrYRE2bFjh3hRkRa8wGT4XrdunZCOpP\/nhfU8zyRSZrJxRrcHiHjZATUL5wBqspJTHilEundmh3B9VGCSWAEwJmAzbQsbD6lLPqA1AfCRE4jrpZ1HCTg5TruWgu+ReyXhsz1HYP\/o0aPFmpXYxxznQ0DqyNyaMtKBkKecgwiVjNSKAI8XmGxuCxYsMBnqUDHtrbCgDiqk\/Z12i5o3fPjwVMAjFVFf05azv2mLdUPs70OHDgnAtGnTxkheVGFmxABSWybcLf2fNWuWmMZ22223yfNOb3LmcPt3uso7EJ4uzp6mdnFUMNME8PHSvvXWW5o0aZKZRIy6yMx+jiMtASwJlZForPHBcWw0uoaUQbohqQATi7SilnIuPQL4qLmAkfSOrBVJgivW88DexFZFOqetS07ZUGpxcHlUXu4HNZQ+23NIYvpOJnN7LDdtHQhz2NNE3Rw2bJhwrrAAKtncWO8CtRAHDKodcbeAETUQ1ZHfpF3EQ4ntCDCZmAyw2KLqsq4j+xmxo3379kYy4SRJSEgQU9BQWQGGjf\/ld9r6XAO7FhClPRf8G3AjBf\/3v\/8JxxCA7t69u7BPsTu5FyRkcJ3csu9A6KMnyWz99IAAyCDbVWwxHCpIMtYZJM+p53kmHyqpIpGCqHO8+J7niVQh2IDvv\/++nnnmGY0fP97kSEWacRxCNUX6cH36Ya\/FdTkGCMiSzlAB1yX3qud5xjMKSDp16mRAauvZLZ5UJCbSkzboL+3Z82y5Hn3hHHYp\/Yf4wAA87pW8rtlRdbmOX8mB0K9PJgf0CzUUMCJZSYqcXpcBXs+ePYXNyEchvTKhjjH8wjxTpHmocjn5XL6c3HnX94w5gFcTL2PGJbJ\/hlkuCxcuNJI1lJTC28qYn+eF72jBBkb1Rkpnv8f+bMGB0J\/PxfUqD3HAgVBSHnre7lZ9yAEHQh8+FNelvMUBB8K89bzd3fqQAw6EPnworkt5iwMOhHnreef5u\/UjAxwI\/fhUXJ\/yFAccCPPU43Y360cOOBD68am4PuUpDvwfAAAA\/\/9lwpE9AAAABklEQVQDADFVaVvcBEBjAAAAAElFTkSuQmCC","height":135,"width":225}}
%---
%[output:84f6c1e7]
%   data: {"dataType":"text","outputData":{"text":"Induction Machine: ABB M3BP 355MLB 6 261kW\nIM Normalization Voltage Factor: 375.6 V | IM Normalization Current Factor: 581.2 A\nRotor Resistance: 0.00274 Ohm\nMagnetization Inductance: 0.00376 H\n---------------------------\n","truncated":false}}
%---
%[output:49271bd5]
%   data: {"dataType":"text","outputData":{"text":"Permanent Magnet Synchronous Machine: WindGen\nPSM Normalization Voltage Factor: 365.8 V | PSM Normalization Current Factor: 486.0 A\nPer-System Direct Axis Inductance: 0.00624 H\nPer-System Quadrature Axis Inductance: 0.00756 H\n---------------------------\n","truncated":false}}
%---
%[output:4f73be20]
%   data: {"dataType":"text","outputData":{"text":"PSM EKF Fully controllable\nPSM EKF is stable.\n","truncated":false}}
%---
%[output:41ee8af2]
%   data: {"dataType":"text","outputData":{"text":"IM EKF Fully controllable\nIM EKF is stable.\n","truncated":false}}
%---
%[output:5e14b5f4]
%   data: {"dataType":"image","outputData":{"dataUri":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAOEAAACHCAYAAADgHj49AAAQAElEQVR4AezdBdSmRdkH8Hlev0\/XxlYUXTEP1tqtK3YdMY4ioiJ2IYp9LOxAxO7AwDh21zmCnagodmBiY7fyvb97ufabHeauJ959d\/fZs\/\/3nrnmmrpmrumZZ+Wyl73syccdd9zJv\/zlL0++znWuc\/KFL3zh5st+8uq\/j3zkIw0tp+e0F7\/4xatcJ5\/8pz\/96eQ73vGODa8ve+NQ\/BGXOIX3+te\/volLvOLjh192cQQfc7jxh4dd0NzQ8ApbOPyj+bLnfDkdP385DW9Oj7jks4tPOviFQw45pCqHCEOc4pA2aSzDFRYacMeX04QjHjKQPny+7OglxCVOfDmks+RlF37wiRdN2OJAF5YwpUv60HzZ8fKDBkHHzx8ad3xdwIMXmIUtLHbpkJ7wLx85PecVp7jx5nRhsXPDw3\/Q8Ob0iC\/iaeOTTn6ljR9hBi0PDz3HyqqH9KlPfSqtMqWf\/OQnyb\/HPvax6dznPjdjusENbpBuc5vbNOb4873vfa8x7rHHHlvdznSmM6UDDzywoR9\/\/PHphz\/8YWPu+nOe85wnXfnKV06\/\/\/3v06pA0l\/\/+tf0s5\/9LJ3\/\/OdPwsv9sh911FHpBz\/4QfJlz93lQxhj8pH7XxXa1jyvCihd6lKXyp0XYh6T1llkfpnLXCY9+9nPPlUe3v72t6c999yzwUte8pLG\/Ve\/+lV64xvf2JiVu\/JnIe9HPepR6cxnPnMi67F1Rhhj8MEPfrBhV8dWlaQpG3UFcWj9wnvDG94wyT+zOq2cmdV18mcOcMPDXqsDhx12WFP\/jjnmmCY9+HJEGan70hhpz3lq5hXE8MxMyJSDOXDRi140jM03+GXkale7WlOICvNe97pX466QKERj6fkjbPx5oe6+++7pjGc8Y9WnyiKuQMRZMg\/JR+5HOsKuwklD2Bf9HZLWWWVOmTRgQLnKPD3zmc9MZKvcNIrcc5mwqxe77bYbY4r0sAxJP76h0BB84QtfaNgpXihGpCfqS8PQ8+cmN7nJNhwRxjbEUyy5W1sd+OhHP7q1vquDt7rVrZpG6ZQgmo+6LI152huHU\/687GUva5RZWUCjhNxyobKvFSLj4gfxloJDg4c+9KFJZWF++MMf3mTkXe96V9M6o0GEwbzesb3SGi26CpDL7+Mf\/3j629\/+Nlhsi0q\/HkoDLyF5bx1ljy6tf\/7znxnXDBqpaPQ1ZOT32c9+NunxIhHSJG0aprve9a5B7vw2SkgRACcN1hoyB9qErRckMIkpoeUN\/11fQw2Z0PJF4rW4pZ+vfe1raXV83ZC1JPe5z30as7RKc2NZ\/TNNPla9LeS\/obUhdlvg06R1GplrvPbcc8903eteN+ll8vSUwy69Tq2344es815ymvQLpwsq8ate9aoulsbNcM+wr7F0\/CnrbtgpSa2etQX1m9\/8ZuswXQegIcOby4SdUoLpDNmi9WFFYq55zWumUAYenvSkJ20tLN2v1gg9ED2VyCDoXYUdPOX3DGc4QzMH1PIJSwXoE04IslZgY\/JRpmVe9qic8qSREq7KH3MtdhiT1llknqenLEsyB+kxBN+4cWMyN2LHq\/yZyfppT3taM\/Saps4IYwgoFgXDG71N3sBTAG4aXsM+5i6sLjIlDTgeX3bmIfUMXw1R\/7gdeeSRjUyYIeayq4s3p1rX4F7Dyn3ve99m4qoFtCCDSeXR4hrzRveLHtDLERA7d3yg0NAUovCY+1COvdvG0VoVrYvwDEvEpxJHBUIH8YqfuS8feOYFcthvv\/2SyhqVXtjo0kqe0oMWkNa1kPn++++fxC\/ekJ00gfShG41EBc\/5uePLZZ3XmXnLmmJRMGmKhoc5oMPQCLBr1DRuzG0QlnmbPPiy4yV38mcegnOe85zNIiJe9Vx4wIwGyt6ITvqkE62GkCn\/sBLDOsyUy1CPOaBgIOzx1R2XvCI3x8jDDP6uby7svALnfijrEUccsc34W0NACVUgvIYxBCH+Mm14a\/ngb1pYdbP6VvqvyVH8ZZr4q\/FKJ3DPMa3Myc6Kci1+4YvrmGzFL\/ilmXsOYZBv0JjRwu7LnzCZx0DZmZLwo0wpPnOOvDHWqMVII+fJzdIhPUGLOkruQRv6fcITnrC1MeNHw6b++bK\/4Q1vaHYY1Al1A20ImjlhzihxefdPyICWFxQ\/Je9Xv\/rVplfl1gaJwyc8\/vH5soO40Gp8Wi5pwAcqZU5T0VQg\/vMwgzcfRuCpxYEOwuYvwpQudvGLEw8EH7fgRa\/FHzT5Fzc+CLowQFzAXMZX8pZhCa8NpV\/hg7hqfvK84QNhlLxo3AL8jZF1hKfsyFA4Zb5rPPjELT5mfoURvPENdzylvJQDGjdhhR\/f8BfhCpsZLzCrC77sX\/7yl5vFQv74z5HHgzfHqZQw9zjE\/K9\/\/Su9\/OUvb7pqXev1r3\/99LGPfSytbloO8T53HuP+y13ucs0ycgwPRYIeCzttQ158SwyXAJkuZT1cXm2cMyvhW97ylvSc5zwn3elOd0of+MAH0lWvetV0\/\/vfP33yk59M2+OfFsdwQNyGCoY0GoeYDxiODF06FsYS7RJYyrpdNmNcVsYwl7y\/+93vknHw7W9\/+\/SgBz0oXeISl0gmvFe5ylXSW9\/61vTvf\/+79LImdsOBvLvPzYYeKs+aJGQXiGQ9ytoQ0XBWubcNtddT0cykhN\/\/\/vebY2bG0pPJpMnX6U9\/+nSlK10pHXvssVu3ORqH7M9Pf\/rTpJfqwte\/\/vU0FCeccEI6oQVf+cpX0lcqOProo9PRGSwo1WAJegjCbx5mpKkrn0u3z\/bWhfUkI3U3q8pzMc6khDaj\/+d\/\/ied\/exn3yYxl7zkJdMf\/\/jH9Nvf\/nYbOotMvPSlL00f+tCHOvG2t70tDUWXkoRylF8tZY6aoqKFIvV98UIeZqRLXuXFqOGFL3xhgkMPPTQ9+MEPTg984AOTJX9w9vYud7lLMpfdMbDfLpfWhz3sYUkdVpfnhZmU8Be\/+EWzIWkPZWiCZOBzn\/vcUPZ1w\/f3v\/891TA0gVbWyMkWDFjW3rx5c7rWta6VNm3alM573vMmhxQcXr\/QhS7UHGBgd8oF7C0dcsghaZ999mmO7h1++OGptMdc17I890WijHtMXGP89vF2ube51eh9tBvf+MZNUau76nBjmdOfmZRw2jTYD9q0WvHGQmXsgsWXAKHZML35zW+e0FTQGiwi5cDDr4MB0knghphtQyJugZxHA+WIF8WlfBSqlNeGDRvSbrvtljZu3NjsP1FMZjQjDO7RA+tNzbOdKDGvFb6VScppOmCv9Q53uEOS\/rCjLQp66jzuMfGM8dvH2+Xe5laj99Ee8YhHNOseaQH\/ZlJCK40O\/P7hD384VdJUotOc5jSnoiOoQCol5RgDPUcXcqVWoVVG81N0lbuESv7FL34xvfKVr0xPecpTmqHh3e52t+TKjiEjt3K\/S\/pBzyVclU8BgWNdr371q5tVYsejrBqjUXILBI9\/\/OObgpRnjYn0CCsgPWjClX5f9nD3pdhWnt\/85jc3i2CGsSDd6Gc961mTc47CWiTOdrazJdMODcbYeMb47ePtcm9zq9H7aMrByr8ymDdmUkLDpn\/84x9JxcgT9q1vfasZWp13dYiV07eXmdKbrznX94xnPKOZi13vetdrzkiyo3PHV6ZRHihDKBvFsg\/qyBQz5eMG+PCXYeR2lRafxkSvZVXZl1LmfCo2XoWPlx\/mWvjSDeac5r4akTx\/r3nNa5rFqTz8pXn9SGAmJbQlcb7znS85ahSb84Zwn\/70p5NtCq3LXLI6IhCVkVK9973vTY95zGOa3s35RosgucKVQarcQJkolh7MMTg9W65slKH0a8hpmOhburGjt7lTNrLT80VPSSEpIL8Bdkqo99HD61ntzepVa2niL2Rx5JFHbtPwkAXFBI0P3rHoylNfWGP89vF2ube51ehDaX15m8Z9JiU817nOlW5729s2w7lXvOIVzWl1rbAh3O1ud7s0mWzZtpgmYX1+VDAViMJRLhUrb\/3dJHcY2DZHGRZlU3FD4SiZng0oIDqlcE6RkpT+SzueLt4u99KNsun59JBAISlfHqf9V6MNq9PyoSfVO2sw7n73uzcHJ9BzP2EOuVFMKOU2VDHLdEf4Q75j\/Pbxdrm3udXoQ2lD8jeWZyYlFNkBBxzQtLIO8e6zzz7J3uHznve8dOlLX5rzzFBpoKZsKhAF5EYha5FROEqloubKxhwK11Zha+GtJS0UUtrbFPKYY45JhqDPfe5zm9vuF7nIRZJbEPJHMTUszMKAtryGjEvFNIqgmNAm47WUyc4Y18xK+L\/\/+7\/pnve8Z3KFgwK+\/\/3vb1b60sh\/KgFQKIpFwVSAABq3topA2VQwCke5VLyohOwHrDYW3PGNTNq6YK8pJFokzrxcz\/\/hD3842Yc9+uijmwMM8ivf8g+lXPoUU5lQTFAmMdpgppjQViaRtuW3WwIzK2F38HVXK6eW3CkWKNCasqkAZQgqFeTKprUHFYzCcTN3apuHlWHW7LU5Qo0PrY+3y73NrUYPmqHT5s2b073vfe\/moS1bMaVC6iEpjh6SQlJSaQ2EDEvFJEeKCZQ3+POvcqF4wgflN0Y5Ix++ebiNufiDp6scu9zb3Gr0obQieXOx9iqhva+b3exmyTDnYhe7WNp3330ToUTs09yi8IiTiqFnAwUa4cVXJQEKpUJQLkqmkgA7NxUFX\/jb1b4OAdjwN1yllPYOcxlQPgpJGYHc0XKeMJMjUEwg7xhNMCsHIPPwk3+HKmdtnp6Hs6uZO5XQ\/Sh7XBe4wAXSe97znmaYowDRfv3rXzeymuYWxX\/+85\/Gb\/xR8BQKKJcCp2jArkJwayv8CCf\/6i26Fkty3pp5jP8+3i73NrcavaSVdr0hJSQzSmlRJ8+bshuqkLk\/5UP2ygGUzyzK6eiXI3r2NvWihrRQa4zLPObpYu5yb3Or0YfSxDlvtCqhZXOXFS94wQsmQ8a99tor7b333s2mtlMk5h\/T3qKwjVEuHqg4MFbZ0vJfVQIU0pA13\/bIGadVyDyMeSsnhYxhrekJxYSacubp2NHNrUr4l7\/8pbkhoQXM9\/s8O8Bu6GEhxjK5favJZMt2xJBbFITmWJiwmReB2hh\/TDxj\/Pfxdrm3udXoJa20t+UvV0jDyXn0kF1x9ynnkP1N9ct8E0rl1CmEcjrVZHokPWX+0WpuNfpQWhnHPOytSmje9oIXvKA5JJxH5F2Pk046KVkVpYAWWcbcooiwHIR1LlLmFwHxOEjgWwu\/j8bfUP99vF3ubW41ekkr7fLkBJOjhMw1UBB7oEYdzpqWR7FqPWQtnFrcNb6cpjGwYGYU5LCBAxEugtvfZJYecAhE+CUoJlhHCOXMh7ahnNyj96yVoXBLeh9NXVXf8c0brUo4mUyaK0om\/hGpYeiTn\/zkpLe79rWvnQiEuwPKwTP0a5GAIE888cS0xHxkoDzM1b2FOUSmpzvd6ZqL2B5CMpe0+JaX8ZnRIgAAEABJREFUXyikyu0srco9JNyxPKY+zhI7OA8aCKeVvAznRohTQdCmnNIs79KnTkmv3vOmN71puvOd75wOPvjg5nVxj\/eay45NH37hUnhxzRutSphHFCugMvXzn\/+8ec7i4he\/eM4y2vysZz2rOfGvRVrifGkeMlCRnWLS240Jz6q3ubhTThbdDFfLqYJ5vNsbr33ta5Nn\/r797W\/PJc1d6fQCgjmiXhO8tqfnfN3rXpeAshpeS6s81yqhw+zS6kADUGyLQpQbKJftMg3XZDJpzZN4LHbV4piV1iihB169wxLwiG8EbEzt+YqnP\/3pSe+nAK5xjWs0ztPeouDZvTnHsaxKLQLi0IL5ThM+f0P99\/F2ube51eglrbQboejdpslv+DGqsaCj51Hp2hTSdEKP42CAbSzDzgij71umu4u\/xmu1HjQc+65umR100EHJkFYvFyvqlOb6179+09MLowTlBKvFbqQ4bmm1Vkfjy\/7617++eabF0FZdLYfuZZjT2hslpFwEGXjc4x7XhGcM7M6YG\/JaHkMSytM4rv7ZUW5RrCZ1+X8KCZjD9SlkDFlNL6BrH3KKJIz2okeknAcccEDSmegt9Z6U09YK5bQw1De0pXhupbjmRiH1yPJnDWR0ono8NEqo9fQ4TuAsZzlLMk73lCH\/MqD3m0y2rICigYwYTqynWxTSBVrXXW2fUL4XhXkq5Jiy6ePtcs\/dKKdhK+W8xz3u0cwRo+cM5aSgmzZtSnhrcjTvXJgS1iLUVX\/iE59ofp\/QSqjnxnOYI5h\/bK9bFLU0L2lrI4F5KuTapLg9FgpH8SgnUEidTiionpRy6l0N1Q2720ObzqXpCWterbIZahjzW9IuYbzMn4RbiVrULQpxTAPCMp\/1XbR\/cXTF1eXe5lajl7TSPk0+p\/UTcW\/YsCFt3ry5eULEHFKFNY\/Mw1WPzL0M58AahIeDhZHz1cx4todspUVjY7Rn3kkZvUODPm+0KqETMl\/60peaZ72931jCapXE6CXncYtCWPOEyrEcjs5TotuGVZOvSrtx48ZEKZ3UaVNIp60s8GngzSHtwaWWf7V4ctYu9za3Gn0oLY97XuZWJZxXBLtQOMusFhIYopB6SNsEesg+hSyC32msSyXcaYpyfWckV0jD1rYh666okKOU0GqppVoLNFHksZHvR1bsM9qbMam1uho82+PbN5foS9MY\/328Xe5tbjV6SSvtfXmap\/sscRv62d4yzxqikO985zuT5zxq6e9KR5tbjT6UVkvDrLTBSugOmMWX\/\/73v9vEOc1Vpm0CWFp2aQmYR8Ycsk0hndSxoR5DVnt4O5PQBimhA8HejbF\/mGd+2qtMeRiLMmttlwszi5JuSrPIt81vTSHRIhexyur4WSikHrKtnNviqdGH0k5Jy1w\/g5TQSpYzo1ZB89hnucrk2JNVMcOAJf5efWJ\/Grn03aKYJszt4YdS2BbzWgA4MuayQNS\/XCEPPfTQZC5pYWdRaVVXnSCL+Of57VXC73znO82NeuN3m5V55BLlBME0V5m0ZATnfOYiQGgen\/KdJnz+hvrv4+1yb3Or0UtaaXeiw\/6uw8jT5HmMnzLuRfkVz3e\/+93mpwLc9gA3PnKFVCfxWWl1ntVdQzcq0GplWKP30dTV7XKLwqLL85\/\/\/HSd61wnXf3qV5fXbaDQCaNUzm2YWiyLvkVhNc5ika+jdWPB31D\/fbxd7m1uNXpJK+3T3qIYKxv8ZdxoQzHGb8kbNz7c9gCrrHjyaqYRinnk5z\/\/+UTB8rThL8u2j2bP05w1j2de5s6e0Lsyhpz3u9\/9kh5vXpEKx0FwGTfsWGJDM8eaVQ7zuEUxaxrW0r\/G36JOKEhNIR2vNPXRQzoc4JLCNGlUVw2J1d15o1FCx4hsLwScPndUyK0Jv5+3++67V+Od5SpTNcAlsZDA0jpUAhZw+hQy5pHmkKZD5pBDw18kX6OEtatMekCKqMsP5XStyfMWJswU1V6PhQCZyxNpxcrQyOHYnL6WZhN06fedJl7+hvrv4+1yb3Or0UtaaZ8mn9P6mSXuMX77eGvuoZCeyjCH9C6rnizPqzprDhkKqSMqz7PWws7DmJe5UcLaVaZSMXXjhx12WNIr+rEVdw4dbjXWXo9XmeYloGU4O7YErFl4lzUfsnpkLM8VhSzPs6LlPIs0N0pYi6BUTHcN7RP6zUFjceb1fJXJuL9t\/6iW35I2xn8fb5d7m1uNXtJKe5mHRdpniXuM3z7eLvfSLXpIz3hYZDGH3LRp0zZionx6SMNVc8gf\/ehHzfbRNkxztrQq4dB41utVpqHp35n4rFZ7A8Z3Z8rXIvISCtn1jEeukJTSFE3POu\/0bFHCgaF6X1QroVcML9NeZbJiZYi7KHzyk59MxvuOO00Txxj\/fbxd7m1uNXpJK+2untnPcqJkmjyP8VPGvSi\/ffF0ube5lXRrGFb\/HYfzJCPoRaOO+1JIP\/m3iHWOUUooMbPCAz2WerUs++23X1oU7nKXuzSnKLwPMk0cY\/z38Xa5t7nV6CWttMdm8qJlS55l3GhDMcZvH2+Xe5tbjZ7T1BlDUQ2al9gop3pvu+Mc5zhHUofZ54XtooQ26j2xv8RRaSmD9S2Dww8\/PDkt5j1UOwXq7g6vhFoPmbDNscTVmt9yXMphx5DDxo0b594L0oc17wlFusR2lMAy6nUngaUSrrsiWSZoV5PAUgl3tRJf5nfdSWCphOuuSJYJ2tUksFTCXa3El\/lddxJYicPZ5deej32RaVNc8+eArAuZ4nJgtsYzlOaxKceOhFVDmX4HzvGV9KHxbU8+P+kl7TnWKh8RN1mT+VA5hLylueZXWOjcxTE03OCbZ12KMOOr3pOvtPmJtqiz7DXMWpdbe0InIG5+85snworEreXX6Q+HxKeNc3unf9p05\/6iMvg5r5zOLH+Xvexl05gKILxHPvKRyWGJK17xikm4Lm4Lb56gIB\/5yEe2BunmzXHHHbfVvt4Nbs8cf\/zxaY899kjlbzbW0u52EVl6qZts\/W6Llwn7ZBsN1Yo9KgLKX9j2qprICM\/7MsxrBb+B8dSnPjXZGP3rX\/86KFrXVfL0+905HrdH+sU7L1A0EJ4yiTw6luYuJ\/qTnvSkwQ3l+973Pl6SY1vu0nlB79Of\/nRDa\/vjpXXxlscV2\/jR3Uj405\/+xLgVnpvYalnnBidlpP+Od7xj80O5kdy8DMiE3tAf7n4WwpUp5aV83CzyLAe3PlR7QncBo5DLAAwdyi651ho\/5SlPSVe5ylVS8Bp6eHYgwnvIQx7SuHmn1G\/LRZfPjwy5fhK8Y7+EEel33q\/0r\/JFfNJn6KGXyPmileIeqOWzJg+0PCxmfiMcX\/LoG2VExVXQIBxwlOqCF7wgY3KmMeSq5fWDJlpvcQQif5558Pt7zvuSj\/tyfosv+KQ78h1+0LgPSa8EkaMKyOzKEDB766Uvv9zFIz7xRlrYgQyFVUMfr945L3PhRR7z8Jw3JnfyUY9yN3L3LAa\/6q08udqH54xnPGNyqmYymSR3bP2c4C1ucYumjuOXL\/nD68seHVxVCfOW7KIXvSh\/DWRUt9tYsj+6Y25B+uIXv5g8tqNXC5peCZ8WBs0taL8bJ7Na86BzUzkk0Atv7POElorw8\/jQpE0FAu7iL+PFo3IEXZ5r8kDjlvPxG3Zf8rjhDW+YVA72LhgaGSLh8SU3dzm1xt5S8Yu23CigpynLh5flT4W62c1ulhQ+Xj97rpyYA9Jdy3e4t31zuvRJL5rpDDDLr56DeQhqaSHDXP4RDnqZbrRQWl+3JfIy55dcpI9SsEs72RqBaTxchUMPvPvd705+2xCPYadnX\/xyGXe8Zz3rWZuz0O7iOhSOHpD\/tvJekRBzC9oaIACeDevcnGCWkcgougoAhoLcuVEmLfbtb3\/79J\/\/\/Ac5RRcuHu\/KNMTVP7e85S3TP\/\/5z+YHZ1atzXEgL7vlYSq0EBCeoWhrRMJ\/Lf3SBwoiKlGNTytPUSlPzHsij3natZLSXpObfJGTSvG0pz0tCS\/Sln9vcpObNFZ8KpHy0QKLp3HI\/ihkw6jJZNLMZeRFPi5\/+csnd0CFIS6vsWntLTjwLh3SI0z5RZsFIXuNK8UHZmHqYXyHgB\/DOumSF\/Mz\/vxsGbkyB7jhwcsPv9zkkWwj3hofuTmsTQ577713ilHFgQcemOLaUjRqRhoaOaOJN73pTU2PR56OYR5xxBHJCJK\/yWTL73je+ta3buo3+Qo\/yuAMZzhDMrwP3an2hDIAkWEZkSE0ge2\/\/\/6MDRSczLHI0EEHHbR1HG3IFErs+pMeBh9MJpMmw8I+7WlP22QohOsWtKskWiQZwN8FDYAKGohGRLoio+G\/pEVFD3e9it5FgZoPBT2+nnmUrrD75q2u1wf4JWR5juFwHq\/CVVj8UhSKz1yC7Mi3pE8mkxR5puTcvXbgkWbmxz72sUncHn7yswUKHV3Doezkj11ldWNAeti5KV\/maaAsNVL8Rk9y4QtfODGjRcPE3Ae9hrLAJy\/mZ8zqWFknuOHhnsfHDmWZoOWYTCaJzA4++OC0srKSyEvHFDzRoYS9\/P70pz9N6sA3v\/nNFOXt0rtXJ\/CSb1d59y7MqNAqnconQGNggTKDBEcPpxCsDCl8bgrZN\/Dvf\/+7+QXgsEeC9YhaFPNAiqTVNyTFFzzMY6AyWYiIwgm\/0irNYdd6lemUDw2GtARU+vDjy5+LocygEII3H4pG+lUeaQoe\/PxpHaP1ZS+hIaDUKh7\/pbtwKOI3vvGNxknepK2xrP5xN04LvmpMf\/nLX5InA1VwdunPeZWr8uU2DTQmGhV+PZMpPIgwyUA+uPehbBzzaVHpN3fL48v5yChk76uOkT0eL0UYlk4mk6Z+suf1JnpCiqosAq6MUVphyLc5Y5T3H\/\/4x\/SiF71o65xQOeETZ1ne1Z5QYQNPWi8KwjwEerM\/\/OEPVVaT1clkS1ddZZiSqLcLwcTXFSEFMjZI6VcghjeU0\/BGmGWPpJAoecgpj4fCmnsJK6fPYpYXeVKJxQkRnuGWwmWPSsFcgzmMV\/S4aVillXkeiKGosDTeKjvkcUgr97WEeWQoQdQV5Wt0EunQ8Eo\/+VnYCrpv\/P6K3o09oLMximPXW77jHe9I73\/\/+1lHoaqEZQhWfvQg6BZLJJgZyl5y48aNyQSVW1QMZijtaKDlEUdUeJU+oCfAk1Jak48Ko8VWQOZ8MSSKFi5PRChGpFUBh7swKEzYKQ178OZfw87giy8ZR2\/syx5uvl49l0ZmcNnUF1\/Z0kYl0qhYeX7AAx6ANZG5OVtjWf3Dr\/JdNY7+r8ExfenzqFHH28dXyjvs8pD33n3hWByMdGlIDU35ISMry8xAKaWNTJQr2lgYFlv84m9MeVeVUIJAYJZkKVaMadEVJDfQ4qlwzIYQeggbwew\/\/vGPt24mE7y9KfSACkCoBKUlsYDATculBbWkbB6DttZQQApKvNJAIZkD+fCGGV0Ba1C6KKwAABAASURBVEjkiR3IxJfcgBkMWeWxrcdUEWIYxx\/wF\/AAUcjdcGyvvfba+kCzBTLyxovPkjmzuZk5U8hdo2ixhvJxV65lPOhDoIGJ9KjseSPDHA0UHrx9Yb74xS\/eunJM\/uz8lENotKEIRcZ\/5JFHJvlnhuihhW8LBy0wmWwZvRnOB83XHDyG+sqcXKcp7+rqaHTdArZIIkKtdQiS4qlAoOfgzg0Ps5esopsWFj4tw0knncR5K\/Qy973vfRu7OWDsqwgf0dwFD\/NagSDlWwGZN0i7L3ueBhP36Ikijzmv\/AKZkA2\/OV\/ITeup4eJeQmUu4xAvRTEHwS8OCyq2LMjcEElFR5ce+7WTyaRZ6YtFGDIlW\/6FJUy8IXf0sYhKTHZkWPqPyolukc8IirkN5E3u0uXLjte8rE1e3EsYZelI0MlceMCMBhohvaCGL0Zx6AFDVOYnPOEJW+d4wlDPdR7cyJNcpynvak8oUIVojCxgdtDSqxjMOdC4Bc1TiJe+9KWbVaagCc9EdTLZ0qrEZFcFwuuhneD1teyfh4m2FpDfZz\/72dtEJS2AqIIrQBWhbU5I6czfFCo\/8hH+2UFl1Wt2DbfFccwxxyTy5aeEMCMeSmip3IO3objBb4ilJ5e3oElTGS67tAfP0K9eVyXGH70tcw6KHunSgOihc\/fSXKYl5KWSl7x9dsqj\/gUfs8bHF+0Nb3hDUq62KKLM0AMxQgt7+bXFQZ5BZ1Y2YfeN9OflrYNDXzFUqCEKVwA5BFLyo+U8zFplrV\/wCo\/d2UXbDyeccEIz3NA6e6JPxQ5e3z5hRwXFK9Pi7AIevNKRC1rFtGTPLeL0ZQ+wQ9gjv8IRXtDjK64yLbl\/fOIUd8lXs4uPHzCUU3koizCDX8N329veNtm\/0rBRcAtMegJzoto8Kg9X2PyVc8Lg0RiQecSXf9G5C4M8yCV3Z8555N0wPPyIA0+GxkiOwgR+cnkxo3HL5cBj+Iu0SA8zXmCWHl\/2L3\/5y81+ngMM\/OcQD5mrp+qtby5bG\/h6wdwPszQJOyCtwuIWYEdv7QmDcd7fAw44ID34wQ9uNvH32Wef5C1HG6B6w3nHtauFd8BA2ZrDGk6BuWnISe8A7LHFwLxESkNlO42sFqKE0fJokcpEmfT6sVHDFwpoSVfLXvIt7XUJzEO25A1iMAKhjGDOimbYqKdl3pUwD9lOI6+FKOE0CVn6WTsJRGWLoVL5NUw0XFu7FG2JSZzilp62IeoWzp3r73ZRQo+pWhU0LAW\/HQcOfQestgFecNjYUGmJz6alDLafDBxRm3cTsOZKKBNObFiMoVxA2cDeTYBSAiUFr0ubFAMzoIPfULTVAYZU9jS9qGyTuxuLewF8Ge\/OKVv1Th2epyJuFyW09eFNf5gmM7YzwGoVGF7ZZAUnR6wEOuHj9xN9wca\/+17gRWXXfqyOtcEmtiVkP7DSxhP0Pt4u9za3Gr2klXb7VuTplehI26K+Zdxj4hnjt4+3y73NrUYfQiNfv6GywyuhSmJjXoYsnX\/sYx9LwBygIEBZgDKALQ7YtGlTGqrAlBWcgHHHCyzjH3HEEUmv6hCueQg6HgsWYINYb3qlK12p95XsPt4u9za3Gr2k1ezk5MSSPCwSZdxj4hrjt4+3y73NrUYfQnOHUP2dN9a8J2zLAKUKbFpVMqBwYHkYKCRQUApLeYEZ0LmriMCvcNriRDcsjqGw4a+rP+arFDSUE18XNmzYkBwH863xobe5t7nV6CWttJOfhsO3lo550sq4x4Q9xm8fb5d7m1uNPpQ2Jp9DedeNEg5NcI1PpQMKR\/EorEd3XC42zKCoEIpKQQF\/LTyKaa5qfmrOGYpp0Qi99KNnd43Ht3RjR29zb3Or0UtaaRfXWmGWuMf47ePtct\/W7f8lU6MPpf1\/KPMz7RRKOFQcoaiUFPScoZwUlGJCTTkpZk0ph8a95FtKoE0CMyuhU+Sed3NI1oav5xdU7Dgb2hbxoum14UVbnJQTKCbkytmnlHrJu93tbs1zBeKsxYG+FsPRWtyLonXlqS\/OMX77eLvc29xq9KG0vrxN4z6zEr7lLW9JKm3+AI7nCj2rN02C1pOfUEz507BEb1n2lNFLXu9610vmk+aY6ykfy7SsbwnMpIS\/+93vkhPo5l5WO53kd9XEs4Vvfetbk+cstlf2a2P8MWmp+c+VMhTSHDQPl0Ja4KGM5pDstbDCT5tbjV7SSnuEuRbfWeIe47ePt8u9za1GH0pbhGxnUkJnPz2R4MT4ZDJp0uc+m2X9Y489dvCjtI3HHexPKKTVWO+mWuJueshT8kH5zCEpo+GqvdFTnJafpQS2kcBMSkgB7cF5aiEP1eNCHrrxpkxOz802PU844YSkBVoExBWvXU0T\/hj\/FNJZRyuxFNKdPv4DFPKVr3xloox6xzw9eGrprNFLWmkXrlv0bnwzLxK1uIfGN8ZvH2+Xe5tbjd5HU1fVd3zzxkxKqHI5reLO2piEqbTOgjq+Zv4UMI8E97sCnhI\/8cQT044CC1JO5bg9fve73z3lt8zJS+\/o3Up31wzZ55kv4XuUy7Mc8wx3GdaJSbk5sjamng\/lnUkJh0ZS8lFc76L4utQYMGSDD3\/4wyngqo2jY8AMnpYDvem3v\/3tBCqeXgD0LLvttlvzlunZzna2xD4WY\/y38d7udrdLj3nMY5LVY8PVXA7yqXd0g9ziVqQ70lkLs6SVdsf1XO7VyEU4i\/qWcY+JZ4zfPt4u9za3Gr2PZpXcukdehvMyz6SEruYb+tSeODRM7XsWYGwmvAUCFA4oH0UESvnmN785gYURF4U9P\/G2t70tcYubB3oLwyZL0l0wtz3d6U6XunjCrY\/XsxOU0PPpCpOSRN49cmUk4PC54aojdcKthVnS+uzCWRTKuMfEM8ZvH2+Xe5tbjd5H27hxY\/NrVlFuzXdOf2ZSQgekteDOXObpcQ5Tq5xXttzdq1eGbFqWgMoJKit4\/iBgwYMQQIuVh9VlprAO2zrl4ggaGFY4L3rooYcmX\/ajjz464THuj\/BUqra9veCJbx9v7m4f0soqyG+E4auBkB5bHRRSenPZ5uHgL+1oa4VZ4h7jt4+3y73NrUYfSluEfGdSQlsShiGePjcXkkAV389t2aYwFERrA4UKUDCgcLB58+a0+RRQShUWKO3jH\/\/4BMyAjieU1ldY0BY3ugpO8VR274ZQgFBOigl48M4bGigKaf\/RCmttq0N6rK6CBR2YdzqW4W1\/CcykhOYfHhcyt3nFK16x9eEmPZ350GSyZdtiUdnMFbhUXCuU3klRwSkqUFYKChSU\/1raKB7FBL0lUNI2pTS8bTsbKvwud24aM+mL3rFNISmlXpJSGnKTuSGuMMSzlhBnV5670jLGbx9vl3ubW40+lNaVr2ndZlJCkWrNHXL2xNt6fbiJsgHFi96VQqr40aNGT4pHvnJQSsPVXCkppF4055vVHL2jhsNWh0UbJ5HKcA1bzSMdlPBWqNVWihmNBTfpLf0t7etTAjMr4Xp9uKk2xm8rAgoaPSnlLBWTe+6XUlJIPZOKb9FnMpk0izg5X5i70tLmpjGgXPe4xz2SIWv0ktIX4ebfUEw9tjRpGKPXZDaUhXkpaFu68zS1mcf47ePtcm9zq9GH0tryNAt9ZiWcJfL17JfihWLqMSF6yzzdpULqIdFynnmYo5c08gildKaVUkpnWxyUU6+owQDDWEpJQUEPyo5OSSEUlb+2cJf0+UmgUULPD2p1vaRcBq2V9yMXfqnGK8pupNuWCL71eouiNsaPNA\/5lv5zpYye0twSPcKjfHpIPRFQSG5lWGiBNrcaPadRSieTpMFJHYppCGt4esghh6RQzi4FlYZQUopHSYFCUkygqEBZAQ3wqAvmpfwCpQVhCrsNeT7aeILex9vl3uZWow+lRbrm+V2hUPbWar8N4Jdz9QB+mOSd73xnevSjH50UtDdMYjXURrMW2dzFIoEnAHaWWxRdgqZ85pfkc+973zt5wybnzxXSKSCrxrn7IswU0+klZ3n1mMoFKKjhLLP5JgUFCgpD0kKxgJIBpTP0NS+lkEA5gbJSXGAOcMOngeLXD9BEzys84YJ4hqRpZ+FZ8XPKTqHUMqTgbDNoaT3Z7ba6VtbvGth\/W8+3KGpj\/Foe22hj\/Kv8FqWih8wrNmV0OoaM\/WZB9I4Rb1s8NXpJK+0RZu0rjdJl5ZWCAqUESgrKG9ByZeWHXxBOLfw2GoUKUDDKBpSQAkfPSzkpKVBaCgxGaBp\/+6bcAC9QYIcbjD7IVfgBcbbJp0YfSmvL5yz0FT9+ogKllLYJxykYGbr61a+ebEWEoxaf29e\/\/vXmCXuHWrW8k8mW7QgnD4bconDKxeqiYcDOBIXpIILe0agg5OZLIVUYPYFK47TMvPPu8ITRzTTh6t3BMFcvr9EFvb2GGIyEjHh8A+h4wNYQGCaD7RfQQ5PBNKBQoD4CJQYKHKCUFDSQKzJzgDteoMQgLOGCzqUmO3VVXZ8m\/X1+VvxoyMUvfvFT8VE0c0RHrnJHm\/N6R7+qI1GOp01zi0JFJMBFHQ4mNHNd32ni4G+o\/xovRVD5PLxExuQWcgxldIAdDOmFkaeTvYy\/pJV2FXWtDnCrqH7JyNfpKI0zaIDAcBf0qGCu6lA7+K3BhzzkIcnvKNqGAYfdweJXwOF3Z4ytFJPltIpMLgGKRulA\/QMKSTnhzne+c9L7AjPl9a6tn5hz6F59j3Kc17dZmKkFRgnNYxxNq7mjyZhD2NMIx7xSIamci4CKoQc3fJom\/DH++3gtajk4oJLpHcguQMY2vZ1zdRbWmVjprYVZ0vrswlkUyrjHxMPvxS52seRHgAw5weEOcCUs4PA75aXET3\/609PrXve6pBcGZnA4nhKrT\/jUqYCnViiyYTSoCyH3IV8jFQ2mwydglLCmSjgkkbPweJBXC2f4tgjorQ2rCG6a8Mf47+MNd6MKwzxzR8qoYoQMKaMhusPm5o5uluhl8vRHOEEr7aYCQw+dTyOT3E8Zd+7WZx7jt42XLEFPqdcyBTJ3NdcNUGK9lzkumO+a+wIzoEOuwMJRNlAq7iJei2jtCQlSgWqZo6LkX5v0a32LIo9\/RzdTRsMu8ygKSbEiT1pfc0eLF\/lZVsPP4Jnxu8t7p1xA0YDihfJSSIoJFJXSwsEHH7yQJ1taldBz8oaZ5il5ibHbzjBGN1S1EKDS5Dx9tyhy3kWZ9SKGeb7TxMHfUP99vF3uGjtytJBTU0hpJ19Kaf5iIc1ZXQs7hkhD0yiceaIrT33xjPHbx9vl3uZWow+hGUb35W0a91YlNAxwE8Ly+kknnbQ17M985jOJglJCMBeY9hbF1kCXhkYCekM9JGWklBY6DNkbx1P+GLZawaOUlvhddjZ8paD2I737s+wxTxHWDvJpVcLJZJJMlBW4F9S+9rWvNTfErWy5OWHRA5i1zE5O4PF8vBaa38lky7bF9pCFHmbofcBa+sb47+Ptcm9zM1QWCmZVAAAHU0lEQVSydWSRgVL6GraWSintekqKp8EEhy9iGEs59ZqAB\/iZFW3pHhLuGL99vF3ubW41+lDakPyN5WlVQgFZvXr+85\/f\/J63CuGmxAMe8IBk7MwdmC3tcsOjJXarnV\/uS8wuAT3kxo0bk16SMlrYoZiUErilyr9QTr0mUEgIBY1tInNPSgqUFPitBLkkLUACjRJaElZIfim1jMOv7fhJa8pl38pPXVuUCT5mNG548PKzxX37\/a2N8cekZoz\/Pt4u9za3Gj2nUUxyNp+0OU4xDWEtyQPFhLY8UzKgcPbOlD9QUqCgpbKih8J+9KMfTeBssTBAeG3x5fQ8Hzm9Zu7j7XJvc6vRh9JqaZyVthKHs+3bOB1hop8HSsjBsyMd4M7zsKuYKaY9yWtd61rNAe6812S2GqvntBpIQfH3yYZiASWDUFjDXrClQjkhFLdNeUOBzV1twQhLmCAO6EvPzui+Yq\/lPe95TzK5JwSHr526kNkd+QB3bYwvT0Mxxn8fb5d7m1uNXtJKe1veKBulo3yGtJSRUhrS6kF9AY0bRQX8\/IEw2sKv0dUloGBA4UBvS3kpYanANSVWLy38medSYjBsDliJn0wmycER8UGkp00+NfpQWoQ9z++KIzt77bVX2nvvvZOjORZiCCmt\/rNHYpXU2cAd7QD3avKX\/wdKgIIBZaN4FBUoJMUESporLDs6Hgob4F84IEwYmIxt2ChTgBIDJQaKHKCUemGgxKAnBmbgBnghFFhYwgVxbZOANbSsULKIb4899kjsWhXH1iRykQe4DXUXBUMe168IfJo4xvjv4+1yb3Or0Utaafegsi0LFW2aPA\/xo+cBB\/jVD5VXL7Jhw4bmZQF7abauwAF2cJYUzGHhile8YsJnH9oqcO7f3AzUQbAlA1FHx3ylDSgZSC+0KTDFBYoLFNd1K480q0fWPMbEP5S3WZgJZgdy7QlabKGEizjAbfirYGRyv\/32S4uCg9MOCR944IFTxTHGfx9vl3ubW41e0mp2Fcc20aLkGuGWcQe96+ttVTjooIOSM6EOHhiJGXIGDDvBUBW8GwvyBcwB7kZtQLkCtsgocGCsElNcoLgU7\/jjj29++k64en51OHRmHt+tSmgY6pyd84fXvva1EyWUeKtvbRHJ5NgD3DLgsO1RRx2VlljKYGwdsBUWOPzww9MTn\/jEBo6aBaxrGCoH7GXriYEZwo1SxVDaN4bTbcNoh\/DV4TadmIa+Es9TOAT785\/\/vPmtwdrVpmkCb\/MjE4YlS1wtLWWwtjKwfw3mrEDpzH8DlJKCmvOaAwMzoPPbVq+npa\/4bUHXRPR+bn9f4xrXaMIyTl8e4G5Esfyzi0tArwiUdhGiWPHzZe5luVzqelFE4nyoibMD20HzZd+uB7glYomlBHYiCazYhtD7TSbbnvO0Sro8wL0TlfQyK+tWAitWQq2C5rAgM5lMdugD3OtW4suELSVQSGCltjBgbwSfSejyADdJLLGUwOIksPKDH\/yguSWRfx3ojigpqUPZ9ksc0nZYW+8Z7sxo3PDg5Sfcl9+lBKaWwC7ices+4S6S32U2lxJYdxJYt0r4pS99KT3ucY9bdwLbkRNkrv\/IRz4yObHk6JhTK\/aJd+Q8rZe022Pfd999G9la6PQK3FDZrjsl9MzcU5\/61OTUg62Q9SLknSEdnlWUD2dOnYV0\/tMPuqItMZsEKJ0TOc7fOrvr5sd3v\/vdQYEuTAkPO+yw9NCHPvRUidA6SPCVr3zltOeeeyZvQ3rJKn7b4jSnOU3yfN2tb33rU\/ldErZIYFrZOgvpZJR5vJfyPAn5zW9+c0ugy7+NBKaV7W1uc5vktM1kMkkeP1OfybgJtOfPQpTQxWAPtNbi9tq0p+TafkDG\/uSNbnSjZLhU878I2o4U5iyydbbS+Uj5dVdU4+fYFvsSKc0iW1f9Tnva0zaXBTz07HqgGyJD5DpXJXzHO97RnIX02xQyVCZgPf+ATJnW9Wafl2w9z+8AtLeB3GYwP1xveV3r9MxLti4zOJBuPeO4445rbl4MyctcldC+opfZ3JLwMnKZAFsYfr+Ckk4mW07ouLVh+HnssccmBwZKP0v7FgnMQ7YWD1w1cmPG\/PCWt7xlmky2lMOWWHbNv7PK9sc\/\/nHzs4ExtDeas03n6tMQic5VCb1T48dPDCedOy0TQAG95T\/ND8iUYe1q9nnI1lTA+zMurqoou5oM2\/I7q2xd+zPCcO\/QXNCdXHcbrXu0xZnT56qEecA18zT3D2vhLGmnlkCfbN1WN9pwYda80LwFPCB86tB2Xso0OeuTrY7lYQ97WHILyUt3t7jFLZLR3hWucIVB0a2pEg5K0SlMMmGl6hTr8jOjBFxN8\/TF5z\/\/+WT5PGCBbMagl95XJbD77rs3l9Rt+bjpv\/\/++w8e6q+pElqy1W3rvlfTvc1\/rYntiW2IS8tgCSxlO1hUoxkXLds1VUJPZdhD8X5HLgkPB3n4Z+iSbu53ad4igaVst8hhEX8XLdv\/AwAA\/\/9zNeNpAAAABklEQVQDAOG8KTPvc7S6AAAAAElFTkSuQmCC","height":135,"width":225}}
%---
%[output:1eb52ed8]
%   data: {"dataType":"image","outputData":{"dataUri":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAOEAAACHCAYAAADgHj49AAAQAElEQVR4AezdC9yeY\/0A8N+zaoiQVkbUFsoh50M2lk2KNoSiqaZJKMIIS8QUNZlDMpTGf6HJcbaUw7CFFLExchzTKsc0MlaN\/fe9cr2f29vzPju93ud5n\/d+P5\/fe9\/X6b6v63fdv+d3uH7X7+o2v\/wrMVBioK4Y6BblX4mBEgN1xUBJhHVFf\/nyEgMRJRGWX0GJgTpjoCTCOk9AB76+fFWDYqAkwgadmLJbXQcDJRF2nbkuR9qgGCiJsEEnpuxW18FASYRdZ67LkTYoBt4CImzQkZbdKjHQoBgoibBBJ6bsVtfBQEmEXWeuy5E2KAZKImzQiSm71XUwUBJhA8719OnT42Mf+1j069cvPv7xj8fmm28egwcPjr\/97W+L3NvzzjsvJk2atEj11Vt33XXf9L7vfve78fLLL8ecOXPi29\/+djz44INVnlVmtQcGSiJsDyy+Bc\/YZJNN4je\/+U389re\/jTvvvDPWWmutlH4LXpUeudlmm6Xne99tt92W8kaOHBnLLLNMfP\/734\/11lsv5S3Jv\/nz58drr722JE27RJuSCDvBNP\/73\/+Ol156Kd73vvfFf\/7zn\/jhD3+YOCVu6V4eOOWUU2LLLbeMT37yk3HPPfekkSGAiy++OHHUbbfdNjKHS4Vt\/FtuueVi6NCh8cADD8Sjjz4aBx54YODO\/\/znP+OII46IrbfeOrbaaqsYNWpU6o\/8Qw89NOV96Utfiv333z\/Vx40POuig2GWXXeKOO+6IW265JfWjb9++sfPOO8f9998fzz77bHz2s5+NE044IfQPx\/\/5z38e22+\/fXrezTff3EYvmye7JMIGncvf\/\/73sdFGG8WHPvSh2GCDDeK5555LH\/B1110Xs2bNCtwKvPDCC3HVVVeF\/L\/85S+Jc0ojWkNThyh50003xa233hrLL798XHPNNYpqwiqrrBI9evQIBJYr\/uEPf4i11147EZT3Pfzww\/HUU0\/FmDFjEqdUjns+\/\/zzuUno37hx49JYbrjhhvCD8Lvf\/S4RuWeo+OKLL8YWW2yR+rf66quH5954441x6qmnpr7OmzdPtaaFkggbdGpxm\/vuuy8ef\/zxxI1wieOPPz5uv\/32GDhwYLzjHe9IsMMOO8Rdd90VU6ZMSfm42Lve9a7EVQwNYSCCj3zkI0mkHT16dEydOlXRYsOAAQOS3njZZZclERVxP\/PMM\/HII48E7lapVOL9739\/bLjhhi3P7t+\/f+jPiiuuGEcffXSqe8YZZ8Qll1wSTz\/9dKqHw+PqlUolunXrlvr+tre9LfwQzJ07N0A08V\/nIMImnoBFGZoPcrvttksf46uvvpqIL7cjhiLInG59ZVjx8SNmgHBGjBjRutr\/pHEwXBA3zIUXXHBB\/OQnPwkEffjhhycOTdyl7yEe9dwTn90XgVHp61\/\/euCSe+21VxxwwAHF4jfd1xrPmyo2SaIkwk4wkT50YuWyyy6bdEHWTMQHfv3rXycuRBd0L+8f\/\/hHED8Nje5G\/ENQCJjuRSxV1haod+6558b666+f9NBcj5g4aNCgYDRCVAga5yVC6p9+Pvnkk4GD5zb5+ve\/\/z1xRLogDpf7l8u78rUkwgad\/WnTpsWnP\/3ppAf26dMniaHDhw+PPffcM4lpxFOw5pprxk477RS77rpryicWfuUrX4nVVlstjYy4ikBdiYYIwH0qLPxjyMnv81zExQhTqJLefdJJJyVxkc5GZ7300kuTIQZhb73AYGM5Y9VVVy02S\/d0yXe\/+92Bo3\/hC19IBH7vvfcm8TRV6ML\/GpIIrU8xLrCaWScD7uUpa\/b5olPR5XzYlgwYaRg0cByiGvFSOXAvD9GceOKJST+8+uqr45xzzgnEpuyQQw4JdUGuX8Sheg899FAyjHjf3XffHfTPFVZYIQARVJ\/obXRSXA+xnX322XHyyScHTusHwvN\/9KMfJb2OGPu1r30tgHfpH0uuZ+ufHwqEjOB\/8YtftHBcFlf90cY7vVsfpJsVGooIiTM+vH322Scp7danrrjiigAmBwEygU+YMKFZ56NTjstCP6LcZpttgr5njjInXuwBdcEGDUWE9BZGiMsvvzysLzEAsJyB3r17B+K88sorW0StLjhfDTnkj370o3HttdcmkRknZUVtyI42aKcaigiZsYk8TN7WxRgIiCp+ZV2lESkdp0HxWXarxMBiY6ChiNCiLOvdl7\/85eRRQW\/gMcHCR984\/fTTg8i62KMsG5QYaGAMNBQRMq1zYyLaEEmtN3Gz2m233ZK7lcVd60wNjM+yayUGFhsDDUWEuByRlCXNmhjn4be\/\/e1pUMRQaXVSxlL+K5uXGGgUDDQUETYKUsp+lBjoSAw0HBFyrbLexRF4xowZ4cowI09ZRyKnfFeJgY7AQEMRIUdfC8s8Oz7xiU+kBWNX60\/ylKnTEYgp31FioKMw0FBE2L1797DmZAmiGihTp6OQU76nOTDQ6KNoKCLkuY\/bfe5zn0tLFNldjcuajapnnnlmCrfQ6Egt+1diYHEw0FBE+N73vjc4BF9\/\/fVpd7jwDtzYAL9RA+ML6VpCiYFmwUBDEWFGKvc13jGIMufxzJenLOeV1xIDzYCBhiTClVZaKf71r3+lDaT2rYGLLrooLN6Xhplm+OzKMRQx0JBEaFH+Bz\/4QXBjGzx4cNrHJn7K9773vbCQXxxAA92XXSkxsEQYaCgiJG5yTTMSnjP2qPHKt4fNvjWbQpXlOu5LKDHQ2THQUETIRW3ixIlpIyiHbfsHM4LdC2Zkk6g6Ob+8lhjo7BhoKCJk+RSz8jvf+U6Il2JfmpB\/4FOf+lTar8ahW53Ojviy\/yUGMgYaighzp4TN46YmlB9XNSCEAvc1G3xzvfJaYqBOGGjX1zYkEbbrCMuHlRhocAyURNjgE1R2r\/kxUBJh889xOcIGx0DDEqHDQsTTFKdSiAsRmy3aNzg+y+6VGFhsDDQkEVovFG9y2LBh6WwDx3I52UcIRGWLPcpO26DseFfAQEMSIf9QXjNCHpoEoS0sVwh5oUxeCSUGmgUDDUmE\/EMt3Dt2KyPauQeCPC2p25rYNM69E7lN1OexY8eWB1dm5JbXumKgIYkQoYni7PQgYdOdkfCNb3wjnASEQJcEY85aEHbdNilbpOiZ1iGX5FllmxID7YmBhiRCA7SLHsE44dVhkhbrN954Y0VLBAhOYGH+pwjZzv0\/\/vGPS\/SsslGJgfbEwH+JsD2fuBTPEnXbrgk76gHLqJijdtbTCZWpsySveOyxx2KNNdZoabrWWmvFzJkzU5qY69ivWuBQFlCsI52hmF\/tvlq9nOdarU0xTx1QLa91frFOvlcH5LSrdAbpWlCtXs5zrdVWmTrAfQbpDDmvrWu1ejnPta12OV8dkNOu0hmka0Gu51tJH007\/msoInRs149\/\/OO47LLL0lFf++23X9ppb7c98XTgwIHhtJ+FjR\/XFCCK\/qeN5Q5tcFV5dMLJkyenaN62SIns7cSgWuA4L1CsI52hmF\/tvlq9nOdarU0xTx1QLa91frFOvlcH5LSrdAbpWlCtXs5zrdVWmTrAfQbpDDmv2nXEqNHxuW\/9F9znOrmta85zKhTd\/7TTTgt5Z5xxRpx\/\/vlhG1yxnjLpDNK1INfzrfhmfE\/tBQ1FhKygdtO72q6EAzoODECCwycX9kskijdCHjVqVNx5553hdNizzjorHdfl14yISye0S2P55ZcPCB0\/fnx4vmPD2gJnYYBiuXSGYn61+2r1cp5rtTbFPHVAtbzW+cU6+V4dkNOu0hmka0G1ejnPtVZbZeoA905ucrYhYpEH5Bdh8FcPjb577B9PrrlLXP+u3aPHDgfFK5t9Jd3P33jPUFe7DNLAOY2+H0coSJvXddZZJ4YOHRrqyssgnSHntXVV77DDDgvfim+mvQjQcxqKCHUIiKiG2IiQ0uCZZ55JRy1DsHRbQFzt1atXQLw6dEunxDrGmcUVyPccp9q6nzt3buCWlkU++MEPRjVwOi0olkk7FmzllVdO5+sVy97x7vcHeO5tq8Y9L60UT7ytVwL3GXKea85r66oOKJZLZyjmu7\/zhXfG9TP+Hbc\/070u79eHIhT7+eyK60dlne3jkdffH1NeXDXB+Jnd46x7Xk9w5KRX4vOXvxBH3fRqPB3vicO26xm\/P3LTBO7Hz1wmlWtrDgBcj1\/wjNEzVo2zXx4QX5s0P6TtwGHo84OrXnGOpDPIF0KFFd0mAeki9OzZM6kzvhXfTHtCQxKh8BYOhXE8Wr9+\/QLsvffe6Wg0ImstBHz4wx8Ou\/IdLInIBIjCXREhhLO07rjjjkEsVZ6fRYyxbGFZZHEAx0b4fiTufnhWjBj\/YOwyemrses7U2GLkXel68LgHoy04+dpH2yxrq82i5B92+WMxYtLzceT4mW9+fo2+LMpz26NOsW+nXD8zLrrjLwmmPPx8PPK32bFK93kxYoceMfHLayTYZ6Nlw5y841\/\/CPfyd1p72dAWjuH8wIump\/TtM2anKf3zC3NTeu+xj6RQKa+88kp6hue0BcW5bF3Ht3HUUUelZ7f3v4YkQoNkiJkyZUoSIcSXEXFt++23V\/QmcIAMA45fvCOPPLKlzPFqgwYNCsgjRuCAQJyabt26xeuvv550wtzg1FNPDYS\/2mqrpfMPF\/WK6z46f4045Np\/xC5j\/xLXPTY3Prz6ynHsoHViwkGbxh+\/tWX87ft92oSFlddq21nLZnxnk\/jdAavF48dvmvACBxkmHrxp\/GTIhnHA9uvE5h9Zs+pcyB+x23oJt0P6rBE\/vXN23P3XuXkq33R94O+VuO+VVYJFfGFzai633HLLcG1d17fhO3rTw9sp0ZBEiLOwhDKufPGLX0wcUNxRecqKYyc6IFZ7DumBxAm6hh34iE35e97znrBhuJpOmJ9lDyPk88pZFHj2lYirp8+OPcc8mLjNc69GDN+xV0w7rk+M3nu92HvLnrHt2ivHh963QizK87pSHeIh0X9pxwy3w3fsHdustXKexqrX3zy1UlA\/luZ9vg1LXFVfsJSZDUOEL730UuBqAMdiXLniiisCsG7tvPPOAQnW+WqNmdI8YcKEoPhTyhGh+ibBc0FOF8VRhhpLFmT+WvD4sy8vEHOeaBEz58x5OX486N1xy8HrLtBdVotabTuybPbs2fHQQw8FQ1VHvndR3yWaHj\/gRa1fq14WQc1rNZg\/\/\/UUqa\/WM5TVwplv469\/\/Wu1xy91Xl2JkJ7mLEIcb4cddgiRtwG9DQFZYMfF+JAeccQRSYRErLVGzZhz7733xq9+9as48cQTA\/cjSvgYiSSbbrppAMYUoml+1sJ0wqzv0UHoMBuv+vb46R4945xd3xsf6P7PoBO21iPqma6l39SzX97d3n1bfcW352ls89oldcI2sfFGgcBN4sWwgo4fPz4sJ4isBhDO1VdfnThjlsNnzZoV1X6JcM6iTkg3ZMkSp8Z64dprrx0W5ufMmZO4FMKeOnVq+BX27je6hJrXcgAAEABJREFUE9V0wv8ss4DDzYo4afLsFn1v+AKRk65Hb9l5i95BTGlLj2itV3RkulH7BQeskIxl5kl6acGc5Hmsdu2x7OulTlgNMfSC4447LhlDcKhiHYTFqGKBVcAnhEU33GyzzaK1OErcLOqECA+x4oJ9+vQJnBFhv\/jii2mhX3vvY2WlM3rv6+\/sEZNnrxq\/fHh+fPPqJ4KeB7YeNTXpe5R+E03fG75AB6GLLI1+0dXbmotf\/vKXQfxrD1wM6bNmm3rhKt1fiy\/1ml3qhFHlj47GWMLQwuDCTS0DkZTudvDBBwf\/TkYXsUftKWTVrPK4lizrgltvvXWIzmZtCMFdcMEFYdmDSGorFCDWzp8\/v6XduLueilOv\/mP8csr9QT986tF7Y0jvF+PYzf8V5+1Qie1WeiaJtrh0EW677bYk9vqoivn1vm\/UfsELp\/yxY8fGNddcUxWn6iwumCdz1O2V5yOD9NhdlovKnOfTj\/HCnrkwnPlxb\/lg2vGmrjqhceBMDC7WAbmn\/exnPwviHQJBiN\/61reSWMrIYAnCwrt2GXDNojhKxOQDyOXtpptuCqKPzcCIEIHSN60TbrDBBsEFbo011og+G64VK94wvAVWuO2H8cKE78bEM46I0d85KHnT0FGrwT777JOWQY455pia9aq1fSvzGrVfxpzX2+jh0u0F9479dsscmk\/pIUOGhB\/hn\/70pwudn4XhTL99q76ZaMe\/uhMh7uQXBrK4p7lnMMEhER5x0pFo1goZb4iRxfG3FkcR1hZbbBF24yu7+OKL0xIBvWPNNdcMv3ZEVksS6kAofZBbUgm\/SOuyi4uHRq9\/zjnnBGiPfvpWfDPFb3Bp7+tOhHQC5mHWRYOxSM9ThtuZswrXX3\/9wMnA5z\/\/+cAd1WsLGCSYvx999NFUxWZgIiluySBDFAXuedCoBKlE2BK2jhIHtXHgW\/HNtCfUnQgRCEdtnLBv375pfc+OCYTCGEMXzLoi3RGHrIUAzyO2Mvpss802ce655waR1seFELM4itgZemo9qywrMdARGKg7ERpk\/\/7948ILL0zEwsBx5ZVXhl3weTmBdRPQGZm2takFdD\/rjwhYm969e0elUkmeN1kcReiVSqXWY8qyEgMdgoGGIELGGNzrvPPOC1bLYcOGpX2EuJjQ9xlOOeWUVN4hmClfUmKggzBQdyJ0Tj0PFzsfeLHgWojNBktlRMo3IO18sKzRQbgpX1NioEMwUHci5LrGOPPOd76zZcDWEK3xMRlbtM9Aj7PI31KxvCkx0AQYqDsRWlKg51m85UpmCxKxFFfMFtMmwHM5hBIDbWKg7kRYqVTi0EMPTf6d8+bNC\/6kFvD1mHXU5tvFsY5qV0KJgc6EgboRITHUcgOPF8sRO+20U4wZMyYsrjsElJcDrlh07GbpxDU7E4LLvi4RBrpUo7oRIaOLxXh+ovYK4nbWCwHPGNuPhg8fHtky6sop2w774j7ALjVb5WCbEgN1I0IcDWcT\/cyueRHQEBgYN25c2juIUO2EIJLaykRnnDhxYpx00klNORnloLomBupGhBndRFHEhShz3oorrpj2++F+dk7stttuwdmXT6kQhogz1y2vJQY6OwbqToR2N\/D1dBSa8weB4L9ETnFIMoLpkDYCM97kvPJaYqAZMFB3IkRoFuoRF9\/QPffcM3A621uGDh2aXNlwxH333TfsjiCuFndSaHfsscfG9OnTW+bjlltuCTomX1TPQdi2RgkARbQVgduSyGuvvdbSprwpMVAvDNSNCImgYo0YOPGTEYZ\/KH\/Pk08+OZzChGjEg+Exw4NG5GbiKeds7SZNmpT8QemV0gAB80NFZJ5F3xQ0qjyVCXZKaEQM1I0IbUliZBGa0E52omZGkHtLFXmjL2KyfIEzqpNd1wSBYl0VKVl+BuKt0AnStknZWcEZ3IZMa5DSNg7bta+OCG0L23Vdlv++3XbBd2Zc+lZ8M+0JdSNChGQ9UEAmcWQGDBgQYskA3AvR4Xx2xttbyI1N\/aIBB5cUxoLXTUYKUZVYa++hAE8srYjZ5mBh67I4ytr6xBNPpLMoDj9lTAy87NVFhp3\/b1YUYddzpsVuoybFHt+9NJyhQAQu4QsL3cneEThyJoVIffaotsf77K5vb0KsGxFmorHD3fofTiWWDBB7ZPPNN4+hC3RCSxS2JllTnDx5crCm5rbVrtoTYy15zJgxI+zOEBSYU4DzJoiuyuiQQmFA6N3Xjo1j+r0rBe0VuLcWDN+xVxy1+xYt8Nlt1o1P99s8thwwKOau+5l4eduj4pTRF9R9hzo921orXLTHjvL2fEaOoGeXens+t9qzRo4cmX4MjjnmmIXOycJwpt+kNt9MtW9vSfPqToTVOs5JmxjJd1SIiieffDJFyxK2kC5ZrU3OQ4S45wc+8IG0h5AxR1waImqPHj1StDbiKI6Zo61p22+1eSlq9t5b9qx5Hb5j7yjCj\/ZcJ5ybcPl+68ULpw+IHLnNYSXzeqxbt53qn\/nMZ5K+bPw2NDcS6JsfCD+0tfq1+oc3WWr8ZRWEGlLrXcr0y6aBtnDmWb6V9oaGJEJEwnPGfkKBf7mw9e\/fP518hHhqIUEcGe5wCFg9kb2IsKyw4tngpMC+RRZTdYBfOOIq4l8c0Fb8GlftRu3WK8bd9XQ4rMShMKsccUtsctIdCRwUAxb3UJVTrn9iwfMWD3405am47JEI1yVp3x5t2hrnqXe8Go+vPjB+cOs\/02E1cJIBruAM5HtX\/YHfxQVLXZa3rDEvrK05LM5lsb5vQ\/wjddobGpIIDZKOSIykIxJPp0yZEieccML\/xJixRPGnP\/0phbTTzqlMjC6IVuBfllS76HFUhEiPBHRShh1tAGcAFlURopcGBqwZcfchvdJpQiJ045JOEAKrdJ8XwMlD1cCpRNVAxO\/OCNXGYtwPzno+nnhuTjhSQNrHDi8AnuCsCPL8qIl+PmL8gyEa+qLOETWEFLQoEbhrPdO3QR\/0rbQ3NAQR4lziwOB+YsBsvPHGYVnCWh8QJp+owMCibkaCJQoKNxEVwcnH7RCl8BiCPQ0bNixE+EZ0xFK6pyBP7hl7tAH0EyKSX8LFgZVXXjlMMnGn2M7JQSJ0O13ICUJA1G4w8eBNoxrkk4na43rrYR+NKwa\/N24btmE6vag9ntkezzDuK\/f\/aDpCgAgvDeAFwBOcFUGedw954wQmp1+BA656On5+39wEoqUX8Z\/v\/dD68SVd5by2rm3Npfq+DTqhb6W9oe5EiJPZSc+SaXDEB8sXDDbEUAfCZLDeVxRHIXhRlyhsFPZc4D3S3uUeIF5LI22BOqBYLl2p\/DdODRE3lb38clS7qguKZdIZivnV7qvVy3murdvgLn6ccr\/UAcV60hmK+dXuq9XLea7V2hTz1AHyct+K6oD8WuC8icO2Wy0mfW3tuGCvNeLT6yzrcQvE7acTiJYOiN+4a36WdxBHgQY531U6g3TuV8aZvAzqvRWR1jy37kRocV1UbdzOL5b4oogPUeB8rJvTpk0L7m10O8Sj45D7wAMPpHCIroLvWnJApIL7Ik6EfcYZZwQDAAT7NSSKAr969ATPAn\/+85+Du9xZZ50V1SCLKsUyefqp306OKpa1vlcXFPOlMxTzq91Xq5fzXFu3oU87zyP3Sx1QrCedoZhf7b5avZznWq1NMU8dIC\/3jd4uD8ivBeqA8RefH\/f8+qJY7uGJiZtm0X\/35aZGz5cfXKA7z4z+Zz8YXxo1Ic2jb8l3kcXR4jueeuqploND5ed+ZZzJy5DF0aL05LtpD6g7EbKEIixIMiD3PGhwwuuuuy6FmLe464DQfv36pbVEoQvtM3Tykuhs0nRIUZaJoGeffXZ885vfTHqitSG7Lkw4QsziKC5hicI7gfVGrnFtAZEEFMulMxTzq91Xq5fzXKu1KeapA6rltc4v1sn36oCcdpXOIF0LqtXLea612ipTB7j340rt6NmzZ8shoPJrgbagWEcaEP2P++ruce6BA5I+PnzHXnHnv3vH2Dl9YqWP9A3GOj\/A6lZr3zq\/WCffZ3GUhd730p5QdyKEHATm3AmbeHE+XMxiO25FXM0D3mSTTQJXZKRhgMH9GFyUs3ZamuAF061bt6BfulqslY\/r1VqiYEVFqG2B94JiubT3+bGwjFIsa32vLijmS2co5le7r1Yv57m2bsOSJ4BW7pc6oFhPOkMxv9p9tXo5z7Vam2KeOkAeffyGG24Ia7bygPxaoA4o1pHOUMx3BsVPPlmJ9ywzL06+e5mYMWfZwA3VLdaTziC\/Nc7kZeBi2bTiKALyq4irER1xLrofjtW3b99wMpM1nJtvvjnk45LaMIQw4EyePDlNJq8b3AxRM5QcffTRKZAwItSGyEh0JO8DREukhVjrP6yj3r24YF2JR4b3LG7bt7J+o\/bLmPWNeOdHVPqtgOEHfyVmX3pYdP\/z7XHxzJXjmpt+lxbta71Lv2rNJeuob8U34xuMdvpXd05oHHY9WH7o3r17DFtgzbSk4FfJpl\/LFDig47Q4dVuyIH4yPWtLDKUDDh06NBh4cD\/E5RyLFVZYQZW0KwPR8rxB8OoXD4RhGa3mbVHm\/WKhXiaNjqPxR+4Ql36jX4w87pvtMhbfStMRIeKi1xFHuQOxeNIVRMpGjETTDHQ4i+rEUaKr3RYIzV5EG39xQIqz5Q0nMjn4xUcinCK5n27gufLpnA6EQaWQituWsPVSe6g0Ig63XXvlIDW1R998K76Z9oS6c0KEg5DobY40w83oC7gV657tTRlwRhZSCGDQYRVFmDgfnQ6CNtpoo7Rux0Cj3qIcCKNeCfXFgD2fDDas5Oa\/vr3p2LfXnQgtPTCaWAi94447olevXnHVVVeFPPpdW+hwmMvAgQNj1113DU7elhfI88ROxh2eMjgiszNHAL+CxNgsjhJjPaOt55f5HYsBxi3b2sw9aYXe3rE9qN\/b6k6EDCaWEPwK2rjLiAId4o\/idu6rQaVSCeIq0dIShv2HzjdUl+7XTAfCGFOzA08oRyD4UaZSMKI1+5jz+OpOhDqC2Mjs9EFredYDEaSJUV5Cc2PAMhSPFschGKk1Y7YC910B6k6EJgAnFLZCvNE99tgjxJlhnLFO2BUmoZnHSFc\/\/vjjW4bIVZDez8lerB\/+vxw0WMZ9CypSQ\/wgu+8KUHciJHZwXbNwy8uFDnfJJZcEjlip\/NcvsytMRLONkcHM6cqs3jhbHh\/djxWcGsHQ5lg8C+ncDRnTfAvqZ7Ukt2vma92JsIhcztU8FCwfmEQTUiwv7zsPBnA3m2N33333N3Xa8hKDml0t5pkezyrOGu4HmBTEiMZi\/qaGTZwoEmFdhsmVjOgptADF3C8jzxkma7piXTpVvnSpMcBKzYOJ83x+mB0JJB9zLq9SqSRfYK51CBJntL6rnfKuAnUnwkqlkmKLcmHiEiTCtl9Bngl0g64yEV1lnDgk\/a+rjHdRxll3ItRJW5mIJPQFv5acs2NV4BUAAAYlSURBVHnE2OmgvITmwIClBz+wpBwj4mRBHxTCRLqrQt2JEKFR3k8\/\/fQQXzSDrUosaV11Yppx3JVKJThJ0AvNLf9gNoAcFaEZx7woY6o7EfKM8OtIF2RNyyAid1eykC3KZLVjnbo9aqeddkoR7yxP2NGw3377pf1+detQA7y47kRI72OAKRfmG+BreAu6YO3XTpj8aFZRP7Ac8fkE44y5rKte60aE9vNZtLVfEAEK5HTggQe2HAqqTJ2uOjHluLsOBupGhJR0G2HtH+Qxw3MCQUoDZep0nakoR9pVMVA3ImSqto2JS5P9ggwzlUolBfgVssKWJXW66sSU4+46GHiLibBtRLKK4ny2ITkvgRGGUSb7D7bdsiwpMdBcGKgbEbKKEjcFZLKH8Ktf\/Wo67KXUA5vrAytHs3AM1I0IdU08GNcMHHdLTpixUV67CgbqSoRdBcnlOEsM1MJAXYlQWEMxYURQ4zlvh7yrtFAUOaJarQGUZY2CgbIfS4qBuhEhCyj3JecJVgNl6izpwMp2JQY6CwbqRoSdBUEd2U8BqrbaaqtwElUGYR07sg9vxbt4x1x44YXpoByuataEi+8x7vPOO6+Y1XLPwfvMM88MvqYtmU12UxJhg02oZRruXBmOPfbYlh7adSAWS0tGJ7ixK8bRdEu6R9AeU1ufqCqdYLhL1MWSCJcIbR3bCJdwDqM4PMJC3n\/\/\/cHNjxP04MGD0zkLeiSSuaMDcFHhH0eMGBH0atzHVR1cCOdB0CLUqes5otshGOWeKSS8\/Z37779\/WjrCiQTfkmejrl3wiOvwww+PbNHGsYD3ZBBjhn+wTbs5r60rrq8\/wMlZ+uAAFoG\/hELk3NFW286c3\/mIsDNjexH6fsABB6Td5oxTItBNnz49tRLqY9y4cWHvnVOnRo8eHeJzIgLeRo899liMGTMmHe9Gn\/bRI6rUuMo\/bQVGtpP91ltvDWu211xzTarJlxdHVgcXyofezJo1K5z9gVCJmIIxOSjFEWPWfR2uInhvesgb\/9Rff\/3130j991Ico3EiMCW4PgnAOK0d2+KmX8Zi\/LY9qddsUBJhg82o492yocqpShtuuGHqYf\/+\/QNHmTlzZvhQcQsfsHit9913X+COopj7YCuVSti9YItYalzlHyLysSNq5zgi6qlTp6aauJBo5nY8eD8RWGAmBGbHi9AVdDxc1wbsadOmhU3Y3td6byDilJ8e\/Ma\/4hiNVYS9N4qCJ9WJJ54YgjTTj+X7IRAOsVnDIJZEaJY7ERDJhAtEeD5gEcomTJgQPnQiZh6KCOZEyJxufSXmObnKMwCuSHxtXS+nPUug5pyePXt2IhjH2uG8RGEuiIg011ncq\/47JJbf8L777huVSteItlcS4eJ+KXWuz1DBtQ\/x+WhFGj\/ttNPSxljiot3q8nFLBCuCHY4mhKR8Opoh4DK4G06F+zgVi1iqrBogfMSGGIUsPOSQQ0LQJidm0Tfpqrhz67aCeNUSi4v1hTcxHmKoPucynFjfRefOec10LYmwk80mcdM5eYwrztoQocwZDsRCBhiiHUcHxIg7Eh2lhRJkoaQ7IkziKsJyJeqK++m+LXQMGjQocSZGkr322isdwkpkRRjZ4UK6dXvvoNciotZlxTTixgUdW84whKAHLzA60U\/pncaCQxbbNMt9SYQNNJN2oFcjBEQGclfpYgwqOJmj38TurFQqIcan2Dy4IHHOh1+pVMLeTDrgjTfeGOeff36MHDkycBrcTD4gmsrzfv3I7\/JeeYhAWEpLBd7rXZVKJVlGEYmDeSqV\/xUfWVJxTNzTM\/TX8\/LzXb1PX5TRS\/Uf+IFBeMYqVunSiLre06hQEmGjzkwn6BcxFDHirAL9VusywhsyZEjQGf0oVKtTK89iPcd+3LxWvc5c1q0zd77se9sYYNVkZWy7xtKXcCucOHFi4qy1uBRrqzW\/SuV\/OeXCekEHJnrj0gur21nLSyLsrDNX9rtpMFASYUQ0zWyWA+mUGCiJsFNOW9npZsJASYTNNJvlWDolBkoi7JTTVna6mTBQEmEzzWY5loVioBErlETYiLNS9qlLYaAkwi413eVgGxEDJRE24qyUfepSGPh\/AAAA\/\/+STPzrAAAABklEQVQDAHZHB\/KREQqcAAAAAElFTkSuQmCC","height":135,"width":225}}
%---
%[output:57f75010]
%   data: {"dataType":"image","outputData":{"dataUri":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAOEAAACHCAYAAADgHj49AAAQAElEQVR4AezdB5xdRfUH8PMANQYpQRQiRSJFQOlVQTRKVbq0AIIgVbogQfiDKFICKCCEKihdpAWCFOlNekelKh1BuoCICP\/9XjLr3Zf7tr7dbJl8cnbumznTzp3f1DPnTvVB6d8LL7zwwQorrPDBqFGjOkWlqPkxSyBLoJsSmCrq\/s0222xx6623xl\/\/+td2CU9d1PwzSyBLoBsSaAPC6aabLnbeeefgdpRWZ3g6SiOHZwlkCUS0AeE\/\/\/nPOO644+KMM86If\/zjH+3K5+Mf\/3i74TkwSyBLoHMSaANCo9saa6wRl156aSy\/\/PKx8sorx3nnnRfA2bnkMlc\/lkAuWj+VQBsQGt3WW2+9uPDCC+POO++MXXfdNS6++OJYcsklY\/311y\/A+eabb\/bTquRiZQkMTAm0AWG5CkbFb37zm3HaaafF\/fffHzvuuGOcdNJJ8a1vfStefPHFMmt+zhLIEuiBBBqCUJr\/\/e9\/49FHH40jjzwyxo4dG88\/\/3ysu+66ndq4EX9K0VVXXRWf+9zngtvsMkiznPYee+wRX\/3qV5vaMZltbLzxxoE8P\/DAA7HIIovE8ccf3+zqTJZeff0mY5jkoSzKpGyTvBo6XeFtmEhFANmQkffhPVSwVHqleOJ6rmTqA0+yazkSbLsxI1\/Au+eee2KfffaJZZddtmgI\/\/73v+Pss8+OW265JXbZZZcwbcXbX2nFFVcsjle4zS6jNB3fcJud9pROzwzngAMOiD333DMGQv3+9re\/xZ\/+9KdiYDj88MOntPi6nP9CCy1U4KvNSGhHdNVVV43NNtss3n333TjxxBOLM8P99tsvWg7wo1arRfqXeky9ENLbCXvxxReLkUEvY4QQxvWChaNy3HJY8l999dWLkUzc9no4eeJJlHhTOlz5ykMYUi69n15IT57i4sErDj9pl8vKv\/43ngsuuCCefvrpWGmllUKaeBKJIy0uP+HyFM9v\/sITJX9hiV566aViKWBz7NBDDw11EMZN8bh+80ee+clLT5vqJkzdyUA4Kudp2fHaa6\/Fcssth7UY3cXFhzwnGSmLMq211lrFjCPVDR+SNz91rOeVuHzxIeVRLv71JA1p4UPqhkc5LJGUwTtI\/sIS1cdN5U\/hzzzzTFFX6ZbDlEWZ+CdSXvG4ynPmmWcWsxP14y9\/vMLqZa6s0heOUhzxyLoNCD\/xiU\/E+PHj4+67747DDjssFltssZh66qnxtiGJbLPNNkWPaVTQcxK0AiZGPdQxxxwTF110UXixwoWV43rplANs+iiocDT\/\/PMXI5mp75VXXjlZ48YjHWnKO5XBy+AvvJ6EIf6pYX\/hC18o1rv1ZcTTGdpuu+2KXniOOeYI5dSzleMtvPDCIeyxxx4rvG+++ebCJXjl7EiGmGeeeeYgR2t0ddXji6suOkl1J6c77rijAE05TJlqtf91nBqXPJ999tmicxWfDNN7u\/zyy2PGGWeMWWaZJfDu2rIx5\/14T0k5A79RUlmUiezMmA4++OAoy1PZ1bee12\/5SUf+0lUe5ZKneImAaNNNNy06OPXEr94a\/Kc\/\/ek499xzC\/mqP7mkeFztCUjLZSq3Qzyvv\/56cRynDsKkzd8RnfbLX93V74YbbihkIhzw991339ZTg\/Zkrhzad5IjuamrONIi6zYgJAQvXIEwNCIv6zOf+UzRAPFoVF6Igr799tu8ihcyatSo0DCNEqmRiItXHKDXaxhJVLaI2PLHaNzixDzzzMOpJA07pYMBILwoL9nvegIGL\/yss84qhKeO8lYGZbzvvvui\/kXWp9HV3xrKUkstFeTiZXA1CnIhB2XSgKRLHuqD56233uLVkNRRXYFcD5sajwgpXWEpf\/4oTd+USRgeZZDnE088Ed6RxjJ8+PDwHoGDzGzGiX\/99ddXyogMyRVpwEZHDVWcetLG5Cdf+SuH8mj0ylfmB2K\/N998c07gF085ybPwbPDnhRdeKDr\/9t5xeheAoPPRpiSnLWkPnr0XMvBcJmDyDryL9mSuXWvfqRzS857FSem1AeEHH3wQCqJX23vvvaOK9EI33nhjUcGUSKqEl9ZRAxLHC\/KiDM16RH69Talx9XY+9enrSDQwL4N8vAw8zz33HKeVyjL817\/+1epf9WCEMO3RQ3vBiQdw6tOVfwpPLtCSfX38FM4FjjFjxngsptt4xUk9eBFQ+qNdCO\/s+1TulKbylJJqfdQWW3+0POgcvEcdKJC1ePXKf3VUF21UW63KJMlVp9IZmZNLozTbgBBCf\/jDH8Y3vvGNYq4MtfU0evToYn1Y3pwhEIIhoGmnnbZNmasKqTfTu+hJEulR2kTsxA8CkjfWJDiu352h9JL1qkYUDQkYyKEz8TvDQ3749Hxk5LeRw0yCfyL1EE6GZdmm8LJ76qmnFj9Nl8gvjaYaaX26qY5FhEl\/Ui8uLjKCiTspuNUxIgiXT5KJjRvy+pDpw786BVNf5ajn\/5Bj8r8AqGPCj4w8ZiRlztTQk59ORkdm1PKekn97bqq\/Mqd33B6\/9nrKKacU01xtVBmVtVGcqneZ8izHMZVWz0Rp1uW9twGhlw9kph\/t0VZbbRUvv\/xypB7MtAEg9PLpZer9TS+QZ1MOvauppl5Q5RRSwyccQvK7s6Qxaxgatzhc4DZl8bs9Mh00FUnTGmVRJmVL8ZIgpZv8uuOmvMhKnn5LR17y5O93WYb1HZnwMpUbJ7mpRwoXJl11qg+TtzKYDmpswGNEtUbzbrwjjVxjF9d78X6AQ\/k0Rp1EescpT4AAjPQbr\/aQfpddjVY70Sa0DeWwCYI8l3m9Y79Tp6NO6qacyiusEaW6ko26pLjk3igOf+Urd2TKqKzCGlF7MtcetcvUjgwSRkSu9NStDQh5doaMWpCdhliu3lXPmeLPMMMMYVFtSPeChAtLcS1OFUYPah3akVDFLZOGsf322xcdQVfTIegf\/ehHxZRaw1IW5VO29PKAQ7oPPfRQOdvJnr1UDcO6V6OuZ5CXRsef67dneXUkQ3wolYmcgcKIQ6Zkmxb9yqCheQfC1UmZLDGkgeQtT88ah\/h4xOGnLkZjvbP3YfMhyQE\/gB555JEhnQQQacjX1DXxOuLSQSawl3k1Pvl5d+LWp6scibxja0xtxLtQJ3VLo0jiq3KVsdE7ruIv+1mDkoO2YUk255xzFkchAFnmS8\/qo1zKR55lmZOjDSSdQapDamvay+233z75OWFKuCNXI0pDK1dBynFmn3320CMKu75lQa8wKbwctzwNSf5cvNIsh\/Mrk3DpozKf+Py48pW\/KZcXk+J7weLgQ9IShgcvP3TJJZcUO7XSEs7lzy3\/lpY0+dWTtMXhlsOkwT9RCk9lUA7PyDM+DTDVye9UN8\/Skz4ev5Vp6aWX5tVK5bTw4E2BGp2R0nvjJz08ieQlb2HqKn1h+JTdMzrhhBNCmDLLr55X\/DJ\/OV1hZSrHlXa5vMoibtmvvbjyFK5MyoY816dTznPixImB1Ie\/NJRDnaWVSBn446uXeUpfOJKGeNLTUXVrJJRApv4pAVNLPS7X9M6mQdUUsqr0GuSWW24ZRlwjVhVP9ptcAmTdXZlLrV0Qmn44lBw3blw89dRT4bdI7VFCfepl2uOtCnOAakHchm69tTjXyn4dy2HRRRcNsuc++OCDxf1Qd0Q9d0Z+gCg+tzP8Q41H+6xvt0a2NMKRG\/khz\/W8Vb8bgvCyyy6LddZZJ6677row5NMb3XrrrYs1WFVCzfBTQbuzFumZPtQdzXLoX3LQPrXTZrT3lEYlCGkS0BU1tz\/wwAMLLQqbA0bECRMmhPCUQDNdlbvtttsKbR09SaazilGtu3Kg5+v90H7qbho53ofvYNz4U+K1tU+OK0ZuE2f+6T\/E2jSqBCGFbbqjtp7LOfn93nvvhfCyf7OfrWFsEmRatlCi764c7D7a6VtiiSV6lE538x9M8ZZZZtlmN\/PW9CpBONNMM8XIkSOLmxNJA+Y\/\/\/lP\/O53v4sRI0aE44fWFPJDv5XArLPOWijjc\/ttIesL1k9\/P\/XKO71WskoQTjPNNOHmhM0YJi4svp1x3XTTTcUVp4997GO9VqCccJbAUJNAJQgJwYh31FFHRdpVc\/7x29\/+NsraBPgyZQkMNQnMOVNzjZxVgtDFXncLqfukTZikysRPGJ6hJvxc3yyB3pBAJQhfeeWVoILD4tqaa64ZjD+5aPulL30p\/GaRLaki9UahcppZAkNJApUgNBWde+654+c\/\/3lxSE61xtHBEUccEauttlqkteFAFlQue5ZAf5FAJQiNhNSdlllmmdZy1mq1Ypv74YcfDuHlsFamTjzYZXXgSdWnE+yZJUtg0EugEoQ04Knc0B9Maz+a4XZJ33\/\/\/bA7eu+993ZLOI45aOB0K3KOlCUwhSTw9Kv\/O6KYY8SwppaiEoTuFTqicJmTVv1XvvKVWHzxxYP2jOshji4OOeSQLhcEcE1rN9xww3bjPvnkk\/HOO+9kaoIMKFa4qZ\/l2bP29NcX\/9lum+1JYCUIJegq0jnnnBPuO51\/\/vnxhz\/8If74xz8WFqZcwbjmmmuwdZpc8nSBkfGdji6tusNHVzXT84Wt1+7K4e9\/\/3vxTRH3A7ubxmCI14w6XPfQS61tfZqXHmp9bsZDQxBK3FUYPahn09FHHnmkML\/niIJfZ0lclzONqPPNN1+H0ZjXoLGTaWShudRdOVAz\/NSnPhU0ZrqbRo43Mv7zsRFx17MfTkenevulDttvVxkagpCdDSYPy\/p\/blUMGzasy8Z\/qb4xDuVWuHtX7qshv6sKTGNHPpmGRU9kYFlh\/d6TNHLcYa0A1FY\/+tSHZis9N4sqQWj3k0kBH4ZBO+ywQ2EOn1b+AgssUJg36EoBbPLQxnfnCrnej9xG7ko6mTdLoK8lQGd0h7P\/UmRrFPzoU38snpv5pxKEbkrUarVwQdd0xtrCtJRWvjNCIG1mIXJaWQL9UQLjrvhbLPqzW1qL9pWR\/w1AbPVo0kMlCNMRhdHwIx\/5SGEsFxAt8F977bVIxxbdLYObyKi78ftpvFysQSABI9\/Zd\/w91hh\/T4y74onWGo1dZa5ArR5NfKgEobWEowjfKGQy3gjIBOIGG2wQPpfGNHsTy5CTyhKY4hIAPiPfmsfeE6afNz\/+WlGmOWcaVoBv7Cqjit+98acShDJyk56amjUgVTXm2dhfZOKiVqthyZQlMGAlAHRGPICb6QfXFtNOIx9\/lQK+MUvNGhd\/f7EWEPYeAOVVCUI3Jdg24WJCpqVGxY022qj48Ai\/TFkCA0ECgHXTY68F0JlmJtABIL9yHYBvbMvUE\/jGj1kg\/C6H98ZzGxACHavLjiWoqHEdKSRyq8JBe70F5t4oWE4zS6CrEiiDDcDKgKufZpbTBrQ06t37f18qRj5+ZZ6656b+nKqcmt1Qep1Uy1xd4jpSKNPJJ5\/c5SOKch75OUugJxIANGQEQ43AJiyt68r5ARcCOiPdK78YHYDnefl5Ziyz9tlz8zr1pQAAEABJREFUGxCmXB1L\/PKXvwxu8stulkBfSADAUJo+Ahkqj2qODfihRmBTVmBDCXCmmACHgI4\/vilNbUCYpqNp+lnlmq7im9IFz\/kPPAkAF0oAAyBAAjCU1mpAlqaPeFDVqJYkAGjLzT1jABVwlcFWBtyUGulSORu5bUCYpqPl6Wf9s+kqvkYJZv+hKQHgQglgtvs7ApjwBLD2QEaiZaDZOElgS9PJiTssFvwAEdjwizcQqA0I6wvsKzSOKXyZhjn8PALWS6i3f0\/59BOw6sEFQEYvo1bVCGa7vysAA5o0mpVBZiSrB9rYljO7BLYpL6Gel6AhCJnBd+\/PSCgbI6DzQv5+Zxq4EgAslIAFLECFAAsBFgIyU0MkPIFLHKOXdNqTBHChBDDgMWKh+mljGs3KIBO3vfQHQ1glCFlYO\/300+Poo48u6KCDDgrftTv22GMLg8DuBg6Gyg+WOgACAioEIGj3C\/8W+1\/1UqxzwgOFGhZAJWB5TsACLvwIsFBnZAMgZXCNbTlfS+ACsDSCGc0SwIQDIhpo08bOyKQ7PJUgdBtbYrRmuIn8ptztpnbyy27vSACo0E2TDpkBpH6dBUj1oKoH1sS\/vBm3PflmAJb0OiotYKH2wAVUCWBlcI0tTRMBrKO8cviHEqgEITP3I0aMKMzeM8yEldK2qSi9Ugre\/DJ1TgIaf6LOgKoeWEYqlKaCAIWk2ZkSABWqApaRyahVBpbn9sAlrc7km3k6J4EPQVjH6yLoPvvsEy7iMmXhRvyiiy5aTEX32muvLl\/qrUt+wP\/U+FEVoIDFmgrVj1R+l0eq7oKKAAEBVQELqNCteywWd+00V3AbAStPC0lzylIlCBWJufuyjRkbM0bCeeedV\/CgIoBCXQVVFaBMG41SSJqdFRRAoSpQ1Y9WaSrYCFimgkh6nc0\/8005CVSC0FEEUxY\/\/elP4+WXXy40Z3ypqVab\/PZEsh+z9NJLx5e\/\/OWwo+poo75K0nTQnxQAPPOr5+uN38CAAASVR6uOpn74AQpJozPl0\/gRQCGjDRo7aeOiq6ASN4OqM5IfmDyVIPzkJz8ZbMCYln7nO98J5u9Z4\/YRT6ArV\/Wxxx6LSy65JC6++OK4+eabY9111y12Uss8nt3AYMDJkQcysjY69O+pycO\/vvhmoTGfwGYaiPxGZWApW0f0memnCbTEbMNinYVmLGiXr84ah689V0G\/23L+QKZ9zx30pWL65\/nc7y0Q6OfrjAq0y1dHFnGlseTsw+LTw6PXzTraZLORxjJCpu6bPXziiSfi2Wef7aipdCu8EoRTTz11mHaOHTu2MHk\/ceLEYAJxyy23jLXXXrswo5dyc8HXBWCWvfgxfZGe\/U7Ef\/rpp08\/23W7a\/Lwroefjm1PfyCWPOSO4mJmAltVZkCFAGuNBT4RaP8VZw504rqzBpq4+ezFmoqL+P3f12YMtNnCw2L0HFHQ3NO+E+gj\/361RyYKm2Gar5wGawgs47GI0Or\/fM\/MKA7VdJjrZDm+qi311K8ShClRO6KPPvponHvuueH2BNMWpp12SBOPXdRFFlkkrr766vD9CqYNfdMwhSfX2SIwL7XUUuFKlM+sST+Fl10jZldM7TFJt80Ff481Tn0mbMmX00rTQlO6NA00Wt2511KBJu6wWJzwnYUK2ubr8wZafclRgZb4\/Bw9MjnYlTr0Bq\/OkBJ+Nnk4ssfvcfPNNw+Gzsptq1nPlSB84403wi7ooi07oi73mkqOHz8+brnlluIjoayn1RdgxRVXjMcffzyMnuPGjQs2S8s8TOftv\/\/+hTFhFtwmTJhQjLJlnvTcWZOHL74dcdT1z8eyh9\/Txiwd4Fl\/2SEsb14AorWVsgwF0llaUgyFuvZ2Heeaa67o7vdXUrtu5FaC0Agl0wsuuKD4KhOT+Kanpqn1CbG+xjw+\/1qtFksssURYh\/ieIb9Eo0ePDkcdtVqt2OhxYfgvf\/nQlFzi6Yprk8T6zjZ\/igdkCXhjWw6OAS6FZTdLoL9KoBKEppisoTUCXrkyelu2Z4yWNm3uuuuuYv1oNzXx0bLZbbfd4rzzzgs8r776atx9991hpE08XXETAG+uM8ZjupmB1xVJZt7+IIFKEHalYD4UwwKbj4faRfXVpR\/84AdhSunmBfJsUQuERkCW26wbuzu8U98qA9DoZ+TrSrkzb5ZAf5FAj0FYq9Vi0003LT4Wwy6NjRkH\/Sq4ySabBPLMz2YMkxk+LCNOrTb5uSPe9siOJ8Jj7QeAXL8zZQkMRAlUgtCa0JECt1wpv6v8yzy9+ZymofIAvGM26htrWPLLlCXQWxJoA0Igc67ka7zbbrttcGm1JGJ7lN1RWjS9VaD20rURk8JtwuT1X5JGdgeyBNqA0Ci30047xTbbbBP3339\/4a633nqRaOeddy60Z2zc9HWljYLldeDYlt3Pvi5Dzq9aAtm3ZxJoA0IHu9Ztl156aey+++7BveGGG6JMPmfGEHDPsu167PIoaBra9RRyjCyB\/imBNiA0HTUaOnagwE3XME1Fk2u6iq8vq1M\/CuZpaF9KP+fV2xJoA0IApNVCKdu0NE1Dyy5\/fL1dsHL6Z9\/xfOvPPAq2iiI\/DBIJtAGh6Sijvz4CY1panoamZ\/74+rL+7vnJz45oHgVJItNgkkAbEKaKmW6adqYpaNnlLzzx9rYLgJM2ZGK5uaeMmfLermNOf2hLoBKEppumneVpqJsNNGLsnArvK7Hd\/PirrVmNWWpk63N+yBIYLBKoBKHppmlnmoJyHVmccsopQe2sL48ojISEnaeipJBpMEqgEoRVFa3VasUNCdPRvhoJn3rlncJUn\/LkqSgpZBqMEqgEoTUfsJXXgp4vv\/zy4gOhjjD6QhjlXdE8Fe0LifebPIZUQSpBaKSrXxNaH7oFwb+v7I6mqag3kndFSSHTYJRAJQir1oTWhdaJzFP0lSDSrqj1YF\/lmfPJEuhrCVSCUCGYLRwzZkywiuY3QzdMXpim+t1Veu6552KjjTYqTAQwjXjSSSdFsu5dlZb1YPIfs9Ss6TG7WQKDTgKVIGQi7+CDDy7siDJXodYu7X70ox8NH4dxU55fVwjoVllllcJcxkUXXVToozIi1SiNNAoKX27uEZxMWQKDUgKVIGQZjaEmhnyTUSfHEkxeMHlnzdhVabBHutZaa0WtVits0DBz0Whtye7odQ\/9ozWL3rPP2X07lPRqBwKx96NTHQhl7c9l7HO7o8OHDw83JdiLaUVCy4OCGA27szvqmxbist62wgorxIILLhhM8bUkO9l\/dkcZ8BXANmh\/s+epIxoIlO2ONs\/GquUYEy3aZLOpciQ0+rET85Of\/CRYSfPMjoz7hN\/97nej0QjWUeGke9ZZZwVwO\/xP6836ePMtvlyrCcNRn\/pEj21G9oZNz4GQZrY72nN7o+k997nd0Wj5x6AvkFgbUlljZfvaa6+Nr3\/96y2hXfv\/1ltvxd577x3JxKGpLc0btzWqUnrujfdavR1NDBs2LDJ1XQZmLNnuaNflVtXWmADtrmGy1sbc4KFyJDTVsjPKjCGwsI7GZmh3R0ANwbqEaURrQSYP77333ujMcUfelGnw5rJ3FyXQf9krQWitttJKKxXm723S9LT4yeQhY8LLLbdcrL766sFiN3OJVWmXD+mrwrNflsBgkkAlCJ0FWoi6W2hamj5nxu3uJ82YPLQeZO7Q15vaM3mYjicc0puODiaB57pkCdRLoBKEPllmPegTZvXEX3h9Qs38\/f7wTzYzuZxWlkC\/lkAbEFLcdgZIk8VoSGm7nvjj661avT985kDSn2PEME6mLIFBLYE2IATA\/fffP+xaUtSmtF1P\/PH1llTKo+CAnIr2lmByuoNWAm1ASHHbOrC\/2JjJO6ODtt3lipUk0AaEJf9otgJ3Oe32nt+b+fPtBeewLIFBJ4FKEDrTc0jvtkOzFLg7K7n3Zp6\/lTVPR1tFkR8GsQQqQehssNkK3F2VoeOJrsbJ\/FkCfSqBJmVWCcLeUODubHnTxkzeGe2sxDLfQJdAJQgpWlPabrYCd0fCcjSBOuLL4VkCg0kClSBUQZoyDuatDXuqwC29rlJeD3ZVYpl\/oEqgIQhViOJ1MxS4pdUZKo+Cc8708c5EyTxZAgNeAu2CsK9r9\/Sr77RmmdeEraKI\/DS4JdCvQPjUK\/8a3NLOtcsSqJBAPwPh\/0bCvCaseFvZa1BKoCEIn3322Tj88MOLG\/FuxScaN25cvPHGG70ijGTmcM6ZsuJ2rwg4J9ovJVAJQof1jiiefvrp8CUmF3ETLb300oURqHJt3BG0gyqMLZoHH3ywHFw8u43hLqI7icgzvyJw0p\/ymnCSV3ayBAa9BMogbK0stbVarRZjx46NNdZYI5i3SMTwE9sliZmpiqOPProYNW+\/\/fbYfvvtgxK4NBIPl6kMQE33Ex1\/1N9LTCPhyOmmif5s\/m4glS2bPGyOWUuWBs0OteVmUyUIZ5ppphg1alTIuKMM3S9kBGfeeectWL\/4xS\/Gyy+\/HEbTwmPSn1deeSWmn376Sb8mdxIAhbAzys5NpuejJzLIJg97Jr+y7Fma6FOTh2+\/\/XawEbrDDjuEj4Km9SC3fk0433zzhQN9WjYuA7Mj40rUDDPMAE+tBJQTJ04sjDstv\/zy4bsWjS4HD3\/\/rWAAONOTPZLDM888E5deemncdtttPUonv4cnY\/75549vf\/vbre25mQ9TVSXG8O\/Xvva1+NnPfhasZqf1INe6T3h9vEceeSQ22GCDePjhh+OAAw4IB\/1lHmbkXBg2Zb3wwgtjwoQJcdNNN5VZWj+HPfHsk2PLLbfM1EMZ6EDPOeecoH6Y5dmz9sTk5\/nnn198S2X22Wdv0257+mOqqgSs+az90jqw7PIXnuIxYXjaaaeFUdNmznHHHRdGwhSeXPGYTazVakU4TZxkhxSPHdGJOywW9\/9g3jjvkB2CUahMZ\/WWHHK6Z3VPtocddlj0CQiBwlUmU093Cu1k2kg54ogjgr\/wRKY8ppknnnhiANnUU0+dglpdH5DZbbfdwvcNgdZmzt133x2LLrpoK096UEEAzbRsZBn0Pxlon6mtNsutHAmB5pBDDgkAO+qoowoz9DZqrOsOPPDAEJ4KwB6NI4nNNtssfGMC+QSaDZszzzwzULI7CoQalpF15ZVXLob2lE52swSGqgQqQWikevLJJ8M8+LOf\/WxMNdVUhRn6rbbaqgCm8CQw00zTyhtvvLH43Fn6mKgp6SabbBIIL7ujNmNsEjhXbM\/uKP5MWQJDRQKVIDSlNNoZ+cqCcOZUq9VCeOR\/WQJZAk2RQCUInRMyg\/\/973+\/WMA7aPdhzx133DEcL4wYMaKTmWe2LIEsgY4kUAlCkbbYYotCC4aGCw0Rput33333+N73vhe1Wg1LpiyBLIEmSKAhCGu1WrF76WzPhgpVNJ9Fy1PRJkg9J5ElUJJAQxDa8fTlJEcU6667bjikX2eddQp7pKX4TXmkaeM4xD78RsMAAAlESURBVKfSTHevuuqqcJTRlMQHeSLk5JzW+yE76lVVmkhkSnE+0R577DHIJdP86vm47X777df0hCtB6CzQoaSpp28K0mx54IEHggI2LZp65eyeluryyy8vdl3tmtpB\/dWvftUrYO9pOftjfOetV155ZVxxxRVx2WWXxTXXXBN33HHHZEW12+0s1\/ICuaY2GVOPPAZvZHsiBx10UKGQQqWz2TWtBKGMjE5GwjT9pKpGLQ0A63dNe1ooigCuQMljttlmC8cZ1N96mu5QiA9wyyyzTNgsm2666Qrd3DvvvHOyqmtI9fq8kzFlj0oJwMCSSy4ZZoKVDD30rASh3VEKq870THdSHoZjABGe\/HrqGnWdO84888xFUrVaLUyZ9NyFR\/7TrgQoS5S1OOaee+7Jbr94h0BoKrXQQgvF+uuvH5Yb7SacA1sloIOjXJKs0bcGNOmhEoRAcc8994TdUJd6acFYb+y6666F0rUNGn5NKkNx7ujWRrPSG2rp1CvL19f\/3XffDeA76aSTwrJi5513LpS6aTXV8+bffS+BShC6luRF0RXdd999i8u9tGd+8YtfRPrtwm8zijvttNOG\/J577rkiOb22j9F8\/vOfL37nP+1LYK655orHH3+8lcmzr2q1erQ8ACm1wjRi0tklc\/cNW4Lz\/yksgUoQuiUxevTo4kY9pWy7ltaHdD7L1Iyy12q1kJd1oXWo28svvPBCzDPPPNXJZ982EjBTMWuxTkeegazMxEyJKSiA8n\/ooYcKywUJlPwyTTkJVIJQcYxMG264YXFWSOl6wQUXDBo0vTGFWXXVVYuNBVPejTfeuFAImGOOORQjUwcSWHzxxcMtl9VWWy1WWWWVokPjJxrleUSW3t3mm29e3Mxw9rvPPvsUMseXacpKoBKEdETdljAK2qW0pX3fffeFRb+tWnqlzSy2XVHTWxtBFMCNjM1MfzCnVavVwlTTMZIjnrJiPOV5pP5kiufWW2+N3\/\/+98EMCf9MnZeA2WBvHO1UgvD1118v7MQ4pAcQxbSGGDNmTGHzhL0YfpmyBLIEei6BShBayNuttDYrZ8GAk40T9wPL\/vk5S6BXJDBEEq0EoUNdo962224b1g5uzlMro0Fj3dHMc8IhIudczSyBhhKoBCFuC31Gghyi33LLLYUu58knnxxbbLGF4EFPxx9\/fKCOKurcTWdF6aAj3s6GW9stvPDC0RX9TrqhXeHvbFm6w6csFC5sGNUbeO5OevVxUvo28Zop9\/p8+up3QxAqAJMWbMPYjNlrr72KA99aLV9jIpvepPvvvz9oaPTGJkCjcltmVCl+N+LvyN+Oug2gegPPHcXrTLgNEvdbqel1hr+\/87QLwv5e+J6WT8Mz1dZg7PyyjeNoRk976KGHBjIa4jvjjDPC6ISPniu1L728i84UqJkX1Cs7wjFtZwxZutdee21lMZ2J0mCRJl6W6pzzpbzZb60a2aS\/0047hTjS19BTBjbUKFkoo\/NcSg\/C5KUuVBHFs4OqnsLkAex2wpUVL4vqeB0Z\/fjHP24dkcmBuUrnxtJJZZZOIyITM4UjjzyyOB6RrrLIpz6OupdHt\/rf9fyD5feQBiGNEeA6\/fTTg91UjQ4w9LR77rlnoO222y7oZ+p5ET4g\/M1vfhN6+WOOOSZYIXBDgaKvNfRiiy0Wf\/7zn2P8+PEFkMWpbzAa2NVXX13cfDDy2QyjoeSminwRcJTjORpyi4X9HnGA5dhjjw2H8fjuvffewkCtYyU2Yl1x4u\/ox7TZskK8WWedNS6++GJBBVH41hmptxstlMLxApzjqYKp5Y8jDksSyxTppDIDZ0tww\/86F3rHbnmot+m2fBpGGGIBQxqEGjXFZgaJ3Q4xqun569sA1TAg4+KbccYZ61mK30YeIxVLzY52HJpTIQPIgmHSH\/kawYy8bo3QUPLsWpLyTGKbzDHyPvXUU2HTTBxg33\/\/\/Qu1P8xuUwCf3Wv3CzV+\/kYuHQJFZCOQjTf+ieQtDJiMho6m\/AZ2I1PiY8179dVXLxTs5S\/eo48+2uFXuhgKoyggTVo6tHdoSKV0h7o7pEFIk4Sx4uuuuy5cXjbCOcyubxTMe7AqrmEDAIWCeh6\/ramMHIBgY8K0cMKECWHEFZ5Ies5anb0mPw3UyAIIya\/edUQEwAlEwAZg4uJl5Zyf5zKJZ7oMpDbWjJTl8FSOt956qyhr+o1HZ8JFAGwqqW7I1R6dAuUO4Y2IfvAss8zSGlx+bvUcwg9DGoQ++GG0MMrRuWTS8YQTTgiNsdwmTN00QNMo0zaNrxyenk1HjXymd8CITBE1\/MTD1bCHDx\/expCyM1kjBiDiqSIg4w\/EXKPyr3\/96+JCtN+NyBQbWHUwTLlbS1bxpnKpawq3pkvPwnVG6oWAWSdjxEw8Va7yWq+mMNP7qk0V9ZNH4hsq7pAGoQbGyLFGkV44EKTRxKjDXyPS2\/tt\/XXqqafG+++\/H2nU8oxvzjnnLL7BYb1jVDQNpTZWvyaUx+jRo4uP4pi+KgeLAkaqNMpJr55M5UaOHFmonSmL9ZUOQnr1vOXfqfzKZEPJWk\/8Mo9n6bii5vMDrrMx\/mwNKAwJ0wlRstcBsDtkZJSu8EYE1NaRPi5ryq7MvnVSz+\/8WVmlLQ5rAfU8Pf3dH+MPaRC6qeGDN9ZwdvuMiNaFGiPdSqOi3VE8GsUiiywSdgR9XMWocsopp4RNDkAy3fOC6dxqZL5WhW+XXXap1NNkpcCa0a6kW9sAbVdVGo3IOmz\/ljXg9ddfH656WefRue1oJFI21vKM0upkd9WGjvVffV7Wg8Bu6r3RRhsVyuGJx7GJKbszZLu6pqI2kFKnlfiqXFNS91DXXHPN4oa66T8+8rXu1BF5B2QiD0ohptlpxLSxpBPgijeYaEiDsFarhe16O32mV0Yw4POC7ZR64XZHKSyY9hnRzj333OIMz9QUaADAlMzoYS2lARvVXBsCVDuOtdrkZ6umXRqwa0XIXc3U4OSJlKOeWDZI6StvmlrKp7ybWv49atSoYvS0iWJHde211y52b43G4uBN+RjV7fDitRuqo1JW4abblMXJS7hPJACKsI5IHqbpZLr11lu3fu1ZPZPs5KNTsTvLVo5P8ek0yNWlZGtxbkd5DbTwIQ3Cgfay+qK8AGG0NSU0wjuvTKNWX+Q\/FPP4fwAAAP\/\/RCVnuwAAAAZJREFUAwBZMG4eJX21nAAAAABJRU5ErkJggg==","height":135,"width":225}}
%---
%[output:70ab00ce]
%   data: {"dataType":"image","outputData":{"dataUri":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAOEAAACHCAYAAADgHj49AAAQAElEQVR4AezdB5xdRfUH8PMANQYpQRQiRSJFQOlVQTRKVbq0AIIgVbogQfiDKFICKCCEKihdpAWCFOlNekelKh1BuoCICP\/9XjLr3Zf7tr7dbJl8cnbumznTzp3f1DPnTvVB6d8LL7zwwQorrPDBqFGjOkWlqPkxSyBLoJsSmCrq\/s0222xx6623xl\/\/+td2CU9d1PwzSyBLoBsSaAPC6aabLnbeeefgdpRWZ3g6SiOHZwlkCUS0AeE\/\/\/nPOO644+KMM86If\/zjH+3K5+Mf\/3i74TkwSyBLoHMSaANCo9saa6wRl156aSy\/\/PKx8sorx3nnnRfA2bnkMlc\/lkAuWj+VQBsQGt3WW2+9uPDCC+POO++MXXfdNS6++OJYcsklY\/311y\/A+eabb\/bTquRiZQkMTAm0AWG5CkbFb37zm3HaaafF\/fffHzvuuGOcdNJJ8a1vfStefPHFMmt+zhLIEuiBBBqCUJr\/\/e9\/49FHH40jjzwyxo4dG88\/\/3ysu+66ndq4EX9K0VVXXRWf+9zngtvsMkiznPYee+wRX\/3qV5vaMZltbLzxxoE8P\/DAA7HIIovE8ccf3+zqTJZeff0mY5jkoSzKpGyTvBo6XeFtmEhFANmQkffhPVSwVHqleOJ6rmTqA0+yazkSbLsxI1\/Au+eee2KfffaJZZddtmgI\/\/73v+Pss8+OW265JXbZZZcwbcXbX2nFFVcsjle4zS6jNB3fcJud9pROzwzngAMOiD333DMGQv3+9re\/xZ\/+9KdiYDj88MOntPi6nP9CCy1U4KvNSGhHdNVVV43NNtss3n333TjxxBOLM8P99tsvWg7wo1arRfqXeky9ENLbCXvxxReLkUEvY4QQxvWChaNy3HJY8l999dWLkUzc9no4eeJJlHhTOlz5ykMYUi69n15IT57i4sErDj9pl8vKv\/43ngsuuCCefvrpWGmllUKaeBKJIy0uP+HyFM9v\/sITJX9hiV566aViKWBz7NBDDw11EMZN8bh+80ee+clLT5vqJkzdyUA4Kudp2fHaa6\/Fcssth7UY3cXFhzwnGSmLMq211lrFjCPVDR+SNz91rOeVuHzxIeVRLv71JA1p4UPqhkc5LJGUwTtI\/sIS1cdN5U\/hzzzzTFFX6ZbDlEWZ+CdSXvG4ynPmmWcWsxP14y9\/vMLqZa6s0heOUhzxyLoNCD\/xiU\/E+PHj4+67747DDjssFltssZh66qnxtiGJbLPNNkWPaVTQcxK0AiZGPdQxxxwTF110UXixwoWV43rplANs+iiocDT\/\/PMXI5mp75VXXjlZ48YjHWnKO5XBy+AvvJ6EIf6pYX\/hC18o1rv1ZcTTGdpuu+2KXniOOeYI5dSzleMtvPDCIeyxxx4rvG+++ebCJXjl7EiGmGeeeeYgR2t0ddXji6suOkl1J6c77rijAE05TJlqtf91nBqXPJ999tmicxWfDNN7u\/zyy2PGGWeMWWaZJfDu2rIx5\/14T0k5A79RUlmUiezMmA4++OAoy1PZ1bee12\/5SUf+0lUe5ZKneImAaNNNNy06OPXEr94a\/Kc\/\/ek499xzC\/mqP7mkeFztCUjLZSq3Qzyvv\/56cRynDsKkzd8RnfbLX93V74YbbihkIhzw991339ZTg\/Zkrhzad5IjuamrONIi6zYgJAQvXIEwNCIv6zOf+UzRAPFoVF6Igr799tu8ihcyatSo0DCNEqmRiItXHKDXaxhJVLaI2PLHaNzixDzzzMOpJA07pYMBILwoL9nvegIGL\/yss84qhKeO8lYGZbzvvvui\/kXWp9HV3xrKUkstFeTiZXA1CnIhB2XSgKRLHuqD56233uLVkNRRXYFcD5sajwgpXWEpf\/4oTd+USRgeZZDnE088Ed6RxjJ8+PDwHoGDzGzGiX\/99ddXyogMyRVpwEZHDVWcetLG5Cdf+SuH8mj0ylfmB2K\/N998c07gF085ybPwbPDnhRdeKDr\/9t5xeheAoPPRpiSnLWkPnr0XMvBcJmDyDryL9mSuXWvfqRzS857FSem1AeEHH3wQCqJX23vvvaOK9EI33nhjUcGUSKqEl9ZRAxLHC\/KiDM16RH69Talx9XY+9enrSDQwL4N8vAw8zz33HKeVyjL817\/+1epf9WCEMO3RQ3vBiQdw6tOVfwpPLtCSfX38FM4FjjFjxngsptt4xUk9eBFQ+qNdCO\/s+1TulKbylJJqfdQWW3+0POgcvEcdKJC1ePXKf3VUF21UW63KJMlVp9IZmZNLozTbgBBCf\/jDH8Y3vvGNYq4MtfU0evToYn1Y3pwhEIIhoGmnnbZNmasKqTfTu+hJEulR2kTsxA8CkjfWJDiu352h9JL1qkYUDQkYyKEz8TvDQ3749Hxk5LeRw0yCfyL1EE6GZdmm8LJ76qmnFj9Nl8gvjaYaaX26qY5FhEl\/Ui8uLjKCiTspuNUxIgiXT5KJjRvy+pDpw786BVNf5ajn\/5Bj8r8AqGPCj4w8ZiRlztTQk59ORkdm1PKekn97bqq\/Mqd33B6\/9nrKKacU01xtVBmVtVGcqneZ8izHMZVWz0Rp1uW9twGhlw9kph\/t0VZbbRUvv\/xypB7MtAEg9PLpZer9TS+QZ1MOvauppl5Q5RRSwyccQvK7s6Qxaxgatzhc4DZl8bs9Mh00FUnTGmVRJmVL8ZIgpZv8uuOmvMhKnn5LR17y5O93WYb1HZnwMpUbJ7mpRwoXJl11qg+TtzKYDmpswGNEtUbzbrwjjVxjF9d78X6AQ\/k0Rp1EescpT4AAjPQbr\/aQfpddjVY70Sa0DeWwCYI8l3m9Y79Tp6NO6qacyiusEaW6ko26pLjk3igOf+Urd2TKqKzCGlF7MtcetcvUjgwSRkSu9NStDQh5doaMWpCdhliu3lXPmeLPMMMMYVFtSPeChAtLcS1OFUYPah3akVDFLZOGsf322xcdQVfTIegf\/ehHxZRaw1IW5VO29PKAQ7oPPfRQOdvJnr1UDcO6V6OuZ5CXRsef67dneXUkQ3wolYmcgcKIQ6Zkmxb9yqCheQfC1UmZLDGkgeQtT88ah\/h4xOGnLkZjvbP3YfMhyQE\/gB555JEhnQQQacjX1DXxOuLSQSawl3k1Pvl5d+LWp6scibxja0xtxLtQJ3VLo0jiq3KVsdE7ruIv+1mDkoO2YUk255xzFkchAFnmS8\/qo1zKR55lmZOjDSSdQapDamvay+233z75OWFKuCNXI0pDK1dBynFmn3320CMKu75lQa8wKbwctzwNSf5cvNIsh\/Mrk3DpozKf+Py48pW\/KZcXk+J7weLgQ9IShgcvP3TJJZcUO7XSEs7lzy3\/lpY0+dWTtMXhlsOkwT9RCk9lUA7PyDM+DTDVye9UN8\/Skz4ev5Vp6aWX5tVK5bTw4E2BGp2R0nvjJz08ieQlb2HqKn1h+JTdMzrhhBNCmDLLr55X\/DJ\/OV1hZSrHlXa5vMoibtmvvbjyFK5MyoY816dTznPixImB1Ie\/NJRDnaWVSBn446uXeUpfOJKGeNLTUXVrJJRApv4pAVNLPS7X9M6mQdUUsqr0GuSWW24ZRlwjVhVP9ptcAmTdXZlLrV0Qmn44lBw3blw89dRT4bdI7VFCfepl2uOtCnOAakHchm69tTjXyn4dy2HRRRcNsuc++OCDxf1Qd0Q9d0Z+gCg+tzP8Q41H+6xvt0a2NMKRG\/khz\/W8Vb8bgvCyyy6LddZZJ6677row5NMb3XrrrYs1WFVCzfBTQbuzFumZPtQdzXLoX3LQPrXTZrT3lEYlCGkS0BU1tz\/wwAMLLQqbA0bECRMmhPCUQDNdlbvtttsKbR09SaazilGtu3Kg5+v90H7qbho53ofvYNz4U+K1tU+OK0ZuE2f+6T\/E2jSqBCGFbbqjtp7LOfn93nvvhfCyf7OfrWFsEmRatlCi764c7D7a6VtiiSV6lE538x9M8ZZZZtlmN\/PW9CpBONNMM8XIkSOLmxNJA+Y\/\/\/lP\/O53v4sRI0aE44fWFPJDv5XArLPOWijjc\/ttIesL1k9\/P\/XKO71WskoQTjPNNOHmhM0YJi4svp1x3XTTTcUVp4997GO9VqCccJbAUJNAJQgJwYh31FFHRdpVc\/7x29\/+NsraBPgyZQkMNQnMOVNzjZxVgtDFXncLqfukTZikysRPGJ6hJvxc3yyB3pBAJQhfeeWVoILD4tqaa64ZjD+5aPulL30p\/GaRLaki9UahcppZAkNJApUgNBWde+654+c\/\/3lxSE61xtHBEUccEauttlqkteFAFlQue5ZAf5FAJQiNhNSdlllmmdZy1mq1Ypv74YcfDuHlsFamTjzYZXXgSdWnE+yZJUtg0EugEoQ04Knc0B9Maz+a4XZJ33\/\/\/bA7eu+993ZLOI45aOB0K3KOlCUwhSTw9Kv\/O6KYY8SwppaiEoTuFTqicJmTVv1XvvKVWHzxxYP2jOshji4OOeSQLhcEcE1rN9xww3bjPvnkk\/HOO+9kaoIMKFa4qZ\/l2bP29NcX\/9lum+1JYCUIJegq0jnnnBPuO51\/\/vnxhz\/8If74xz8WFqZcwbjmmmuwdZpc8nSBkfGdji6tusNHVzXT84Wt1+7K4e9\/\/3vxTRH3A7ubxmCI14w6XPfQS61tfZqXHmp9bsZDQxBK3FUYPahn09FHHnmkML\/niIJfZ0lclzONqPPNN1+H0ZjXoLGTaWShudRdOVAz\/NSnPhU0ZrqbRo43Mv7zsRFx17MfTkenevulDttvVxkagpCdDSYPy\/p\/blUMGzasy8Z\/qb4xDuVWuHtX7qshv6sKTGNHPpmGRU9kYFlh\/d6TNHLcYa0A1FY\/+tSHZis9N4sqQWj3k0kBH4ZBO+ywQ2EOn1b+AgssUJg36EoBbPLQxnfnCrnej9xG7ko6mTdLoK8lQGd0h7P\/UmRrFPzoU38snpv5pxKEbkrUarVwQdd0xtrCtJRWvjNCIG1mIXJaWQL9UQLjrvhbLPqzW1qL9pWR\/w1AbPVo0kMlCNMRhdHwIx\/5SGEsFxAt8F977bVIxxbdLYObyKi78ftpvFysQSABI9\/Zd\/w91hh\/T4y74onWGo1dZa5ArR5NfKgEobWEowjfKGQy3gjIBOIGG2wQPpfGNHsTy5CTyhKY4hIAPiPfmsfeE6afNz\/+WlGmOWcaVoBv7Cqjit+98acShDJyk56amjUgVTXm2dhfZOKiVqthyZQlMGAlAHRGPICb6QfXFtNOIx9\/lQK+MUvNGhd\/f7EWEPYeAOVVCUI3Jdg24WJCpqVGxY022qj48Ai\/TFkCA0ECgHXTY68F0JlmJtABIL9yHYBvbMvUE\/jGj1kg\/C6H98ZzGxACHavLjiWoqHEdKSRyq8JBe70F5t4oWE4zS6CrEiiDDcDKgKufZpbTBrQ06t37f18qRj5+ZZ6656b+nKqcmt1Qep1Uy1xd4jpSKNPJJ5\/c5SOKch75OUugJxIANGQEQ43AJiyt68r5ARcCOiPdK78YHYDnefl5Ziyz9tlz8zr1pQAAEABJREFUGxCmXB1L\/PKXvwxu8stulkBfSADAUJo+Ahkqj2qODfihRmBTVmBDCXCmmACHgI4\/vilNbUCYpqNp+lnlmq7im9IFz\/kPPAkAF0oAAyBAAjCU1mpAlqaPeFDVqJYkAGjLzT1jABVwlcFWBtyUGulSORu5bUCYpqPl6Wf9s+kqvkYJZv+hKQHgQglgtvs7ApjwBLD2QEaiZaDZOElgS9PJiTssFvwAEdjwizcQqA0I6wvsKzSOKXyZhjn8PALWS6i3f0\/59BOw6sEFQEYvo1bVCGa7vysAA5o0mpVBZiSrB9rYljO7BLYpL6Gel6AhCJnBd+\/PSCgbI6DzQv5+Zxq4EgAslIAFLECFAAsBFgIyU0MkPIFLHKOXdNqTBHChBDDgMWKh+mljGs3KIBO3vfQHQ1glCFlYO\/300+Poo48u6KCDDgrftTv22GMLg8DuBg6Gyg+WOgACAioEIGj3C\/8W+1\/1UqxzwgOFGhZAJWB5TsACLvwIsFBnZAMgZXCNbTlfS+ACsDSCGc0SwIQDIhpo08bOyKQ7PJUgdBtbYrRmuIn8ptztpnbyy27vSACo0E2TDpkBpH6dBUj1oKoH1sS\/vBm3PflmAJb0OiotYKH2wAVUCWBlcI0tTRMBrKO8cviHEqgEITP3I0aMKMzeM8yEldK2qSi9Ugre\/DJ1TgIaf6LOgKoeWEYqlKaCAIWk2ZkSABWqApaRyahVBpbn9sAlrc7km3k6J4EPQVjH6yLoPvvsEy7iMmXhRvyiiy5aTEX32muvLl\/qrUt+wP\/U+FEVoIDFmgrVj1R+l0eq7oKKAAEBVQELqNCteywWd+00V3AbAStPC0lzylIlCBWJufuyjRkbM0bCeeedV\/CgIoBCXQVVFaBMG41SSJqdFRRAoSpQ1Y9WaSrYCFimgkh6nc0\/8005CVSC0FEEUxY\/\/elP4+WXXy40Z3ypqVab\/PZEsh+z9NJLx5e\/\/OWwo+poo75K0nTQnxQAPPOr5+uN38CAAASVR6uOpn74AQpJozPl0\/gRQCGjDRo7aeOiq6ASN4OqM5IfmDyVIPzkJz8ZbMCYln7nO98J5u9Z4\/YRT6ArV\/Wxxx6LSy65JC6++OK4+eabY9111y12Uss8nt3AYMDJkQcysjY69O+pycO\/vvhmoTGfwGYaiPxGZWApW0f0memnCbTEbMNinYVmLGiXr84ah689V0G\/23L+QKZ9zx30pWL65\/nc7y0Q6OfrjAq0y1dHFnGlseTsw+LTw6PXzTraZLORxjJCpu6bPXziiSfi2Wef7aipdCu8EoRTTz11mHaOHTu2MHk\/ceLEYAJxyy23jLXXXrswo5dyc8HXBWCWvfgxfZGe\/U7Ef\/rpp08\/23W7a\/Lwroefjm1PfyCWPOSO4mJmAltVZkCFAGuNBT4RaP8VZw504rqzBpq4+ezFmoqL+P3f12YMtNnCw2L0HFHQ3NO+E+gj\/361RyYKm2Gar5wGawgs47GI0Or\/fM\/MKA7VdJjrZDm+qi311K8ShClRO6KPPvponHvuueH2BNMWpp12SBOPXdRFFlkkrr766vD9CqYNfdMwhSfX2SIwL7XUUuFKlM+sST+Fl10jZldM7TFJt80Ff481Tn0mbMmX00rTQlO6NA00Wt2511KBJu6wWJzwnYUK2ubr8wZafclRgZb4\/Bw9MjnYlTr0Bq\/OkBJ+Nnk4ssfvcfPNNw+Gzsptq1nPlSB84403wi7ooi07oi73mkqOHz8+brnlluIjoayn1RdgxRVXjMcffzyMnuPGjQs2S8s8TOftv\/\/+hTFhFtwmTJhQjLJlnvTcWZOHL74dcdT1z8eyh9\/Txiwd4Fl\/2SEsb14AorWVsgwF0llaUgyFuvZ2Heeaa67o7vdXUrtu5FaC0Agl0wsuuKD4KhOT+Kanpqn1CbG+xjw+\/1qtFksssURYh\/ieIb9Eo0ePDkcdtVqt2OhxYfgvf\/nQlFzi6Yprk8T6zjZ\/igdkCXhjWw6OAS6FZTdLoL9KoBKEppisoTUCXrkyelu2Z4yWNm3uuuuuYv1oNzXx0bLZbbfd4rzzzgs8r776atx9991hpE08XXETAG+uM8ZjupmB1xVJZt7+IIFKEHalYD4UwwKbj4faRfXVpR\/84AdhSunmBfJsUQuERkCW26wbuzu8U98qA9DoZ+TrSrkzb5ZAf5FAj0FYq9Vi0003LT4Wwy6NjRkH\/Sq4ySabBPLMz2YMkxk+LCNOrTb5uSPe9siOJ8Jj7QeAXL8zZQkMRAlUgtCa0JECt1wpv6v8yzy9+ZymofIAvGM26htrWPLLlCXQWxJoA0Igc67ka7zbbrttcGm1JGJ7lN1RWjS9VaD20rURk8JtwuT1X5JGdgeyBNqA0Ci30047xTbbbBP3339\/4a633nqRaOeddy60Z2zc9HWljYLldeDYlt3Pvi5Dzq9aAtm3ZxJoA0IHu9Ztl156aey+++7BveGGG6JMPmfGEHDPsu167PIoaBra9RRyjCyB\/imBNiA0HTUaOnagwE3XME1Fk2u6iq8vq1M\/CuZpaF9KP+fV2xJoA0IApNVCKdu0NE1Dyy5\/fL1dsHL6Z9\/xfOvPPAq2iiI\/DBIJtAGh6Sijvz4CY1panoamZ\/74+rL+7vnJz45oHgVJItNgkkAbEKaKmW6adqYpaNnlLzzx9rYLgJM2ZGK5uaeMmfLermNOf2hLoBKEppumneVpqJsNNGLsnArvK7Hd\/PirrVmNWWpk63N+yBIYLBKoBKHppmlnmoJyHVmccsopQe2sL48ojISEnaeipJBpMEqgEoRVFa3VasUNCdPRvhoJn3rlncJUn\/LkqSgpZBqMEqgEoTUfsJXXgp4vv\/zy4gOhjjD6QhjlXdE8Fe0LifebPIZUQSpBaKSrXxNaH7oFwb+v7I6mqag3kndFSSHTYJRAJQir1oTWhdaJzFP0lSDSrqj1YF\/lmfPJEuhrCVSCUCGYLRwzZkywiuY3QzdMXpim+t1Veu6552KjjTYqTAQwjXjSSSdFsu5dlZb1YPIfs9Ss6TG7WQKDTgKVIGQi7+CDDy7siDJXodYu7X70ox8NH4dxU55fVwjoVllllcJcxkUXXVToozIi1SiNNAoKX27uEZxMWQKDUgKVIGQZjaEmhnyTUSfHEkxeMHlnzdhVabBHutZaa0WtVits0DBz0Whtye7odQ\/9ozWL3rPP2X07lPRqBwKx96NTHQhl7c9l7HO7o8OHDw83JdiLaUVCy4OCGA27szvqmxbist62wgorxIILLhhM8bUkO9l\/dkcZ8BXANmh\/s+epIxoIlO2ONs\/GquUYEy3aZLOpciQ0+rET85Of\/CRYSfPMjoz7hN\/97nej0QjWUeGke9ZZZwVwO\/xP6836ePMtvlyrCcNRn\/pEj21G9oZNz4GQZrY72nN7o+k997nd0Wj5x6AvkFgbUlljZfvaa6+Nr3\/96y2hXfv\/1ltvxd577x3JxKGpLc0btzWqUnrujfdavR1NDBs2LDJ1XQZmLNnuaNflVtXWmADtrmGy1sbc4KFyJDTVsjPKjCGwsI7GZmh3R0ANwbqEaURrQSYP77333ujMcUfelGnw5rJ3FyXQf9krQWitttJKKxXm723S9LT4yeQhY8LLLbdcrL766sFiN3OJVWmXD+mrwrNflsBgkkAlCJ0FWoi6W2hamj5nxu3uJ82YPLQeZO7Q15vaM3mYjicc0puODiaB57pkCdRLoBKEPllmPegTZvXEX3h9Qs38\/f7wTzYzuZxWlkC\/lkAbEFLcdgZIk8VoSGm7nvjj661avT985kDSn2PEME6mLIFBLYE2IATA\/fffP+xaUtSmtF1P\/PH1llTKo+CAnIr2lmByuoNWAm1ASHHbOrC\/2JjJO6ODtt3lipUk0AaEJf9otgJ3Oe32nt+b+fPtBeewLIFBJ4FKEDrTc0jvtkOzFLg7K7n3Zp6\/lTVPR1tFkR8GsQQqQehssNkK3F2VoeOJrsbJ\/FkCfSqBJmVWCcLeUODubHnTxkzeGe2sxDLfQJdAJQgpWlPabrYCd0fCcjSBOuLL4VkCg0kClSBUQZoyDuatDXuqwC29rlJeD3ZVYpl\/oEqgIQhViOJ1MxS4pdUZKo+Cc8708c5EyTxZAgNeAu2CsK9r9\/Sr77RmmdeEraKI\/DS4JdCvQPjUK\/8a3NLOtcsSqJBAPwPh\/0bCvCaseFvZa1BKoCEIn3322Tj88MOLG\/FuxScaN25cvPHGG70ijGTmcM6ZsuJ2rwg4J9ovJVAJQof1jiiefvrp8CUmF3ETLb300oURqHJt3BG0gyqMLZoHH3ywHFw8u43hLqI7icgzvyJw0p\/ymnCSV3ayBAa9BMogbK0stbVarRZjx46NNdZYI5i3SMTwE9sliZmpiqOPProYNW+\/\/fbYfvvtgxK4NBIPl6kMQE33Ex1\/1N9LTCPhyOmmif5s\/m4glS2bPGyOWUuWBs0OteVmUyUIZ5ppphg1alTIuKMM3S9kBGfeeectWL\/4xS\/Gyy+\/HEbTwmPSn1deeSWmn376Sb8mdxIAhbAzys5NpuejJzLIJg97Jr+y7Fma6FOTh2+\/\/XawEbrDDjuEj4Km9SC3fk0433zzhQN9WjYuA7Mj40rUDDPMAE+tBJQTJ04sjDstv\/zy4bsWjS4HD3\/\/rWAAONOTPZLDM888E5deemncdtttPUonv4cnY\/75549vf\/vbre25mQ9TVSXG8O\/Xvva1+NnPfhasZqf1INe6T3h9vEceeSQ22GCDePjhh+OAAw4IB\/1lHmbkXBg2Zb3wwgtjwoQJcdNNN5VZWj+HPfHsk2PLLbfM1EMZ6EDPOeecoH6Y5dmz9sTk5\/nnn198S2X22Wdv0257+mOqqgSs+az90jqw7PIXnuIxYXjaaaeFUdNmznHHHRdGwhSeXPGYTazVakU4TZxkhxSPHdGJOywW9\/9g3jjvkB2CUahMZ\/WWHHK6Z3VPtocddlj0CQiBwlUmU093Cu1k2kg54ogjgr\/wRKY8ppknnnhiANnUU0+dglpdH5DZbbfdwvcNgdZmzt133x2LLrpoK096UEEAzbRsZBn0Pxlon6mtNsutHAmB5pBDDgkAO+qoowoz9DZqrOsOPPDAEJ4KwB6NI4nNNtssfGMC+QSaDZszzzwzULI7CoQalpF15ZVXLob2lE52swSGqgQqQWikevLJJ8M8+LOf\/WxMNdVUhRn6rbbaqgCm8CQw00zTyhtvvLH43Fn6mKgp6SabbBIIL7ujNmNsEjhXbM\/uKP5MWQJDRQKVIDSlNNoZ+cqCcOZUq9VCeOR\/WQJZAk2RQCUInRMyg\/\/973+\/WMA7aPdhzx133DEcL4wYMaKTmWe2LIEsgY4kUAlCkbbYYotCC4aGCw0Rput33333+N73vhe1Wg1LpiyBLIEmSKAhCGu1WrF76WzPhgpVNJ9Fy1PRJkg9J5ElUJJAQxDa8fTlJEcU6667bjikX2eddQp7pKX4TXmkaeM4xD78RsMAAAlESURBVKfSTHevuuqqcJTRlMQHeSLk5JzW+yE76lVVmkhkSnE+0R577DHIJdP86vm47X777df0hCtB6CzQoaSpp28K0mx54IEHggI2LZp65eyeluryyy8vdl3tmtpB\/dWvftUrYO9pOftjfOetV155ZVxxxRVx2WWXxTXXXBN33HHHZEW12+0s1\/ICuaY2GVOPPAZvZHsiBx10UKGQQqWz2TWtBKGMjE5GwjT9pKpGLQ0A63dNe1ooigCuQMljttlmC8cZ1N96mu5QiA9wyyyzTNgsm2666Qrd3DvvvHOyqmtI9fq8kzFlj0oJwMCSSy4ZZoKVDD30rASh3VEKq870THdSHoZjABGe\/HrqGnWdO84888xFUrVaLUyZ9NyFR\/7TrgQoS5S1OOaee+7Jbr94h0BoKrXQQgvF+uuvH5Yb7SacA1sloIOjXJKs0bcGNOmhEoRAcc8994TdUJd6acFYb+y6666F0rUNGn5NKkNx7ujWRrPSG2rp1CvL19f\/3XffDeA76aSTwrJi5513LpS6aTXV8+bffS+BShC6luRF0RXdd999i8u9tGd+8YtfRPrtwm8zijvttNOG\/J577rkiOb22j9F8\/vOfL37nP+1LYK655orHH3+8lcmzr2q1erQ8ACm1wjRi0tklc\/cNW4Lz\/yksgUoQuiUxevTo4kY9pWy7ltaHdD7L1Iyy12q1kJd1oXWo28svvPBCzDPPPNXJZ982EjBTMWuxTkeegazMxEyJKSiA8n\/ooYcKywUJlPwyTTkJVIJQcYxMG264YXFWSOl6wQUXDBo0vTGFWXXVVYuNBVPejTfeuFAImGOOORQjUwcSWHzxxcMtl9VWWy1WWWWVokPjJxrleUSW3t3mm29e3Mxw9rvPPvsUMseXacpKoBKEdETdljAK2qW0pX3fffeFRb+tWnqlzSy2XVHTWxtBFMCNjM1MfzCnVavVwlTTMZIjnrJiPOV5pP5kiufWW2+N3\/\/+98EMCf9MnZeA2WBvHO1UgvD1118v7MQ4pAcQxbSGGDNmTGHzhL0YfpmyBLIEei6BShBayNuttDYrZ8GAk40T9wPL\/vk5S6BXJDBEEq0EoUNdo962224b1g5uzlMro0Fj3dHMc8IhIudczSyBhhKoBCFuC31Gghyi33LLLYUu58knnxxbbLGF4EFPxx9\/fKCOKurcTWdF6aAj3s6GW9stvPDC0RX9TrqhXeHvbFm6w6csFC5sGNUbeO5OevVxUvo28Zop9\/p8+up3QxAqAJMWbMPYjNlrr72KA99aLV9jIpvepPvvvz9oaPTGJkCjcltmVCl+N+LvyN+Oug2gegPPHcXrTLgNEvdbqel1hr+\/87QLwv5e+J6WT8Mz1dZg7PyyjeNoRk976KGHBjIa4jvjjDPC6ISPniu1L728i84UqJkX1Cs7wjFtZwxZutdee21lMZ2J0mCRJl6W6pzzpbzZb60a2aS\/0047hTjS19BTBjbUKFkoo\/NcSg\/C5KUuVBHFs4OqnsLkAex2wpUVL4vqeB0Z\/fjHP24dkcmBuUrnxtJJZZZOIyITM4UjjzyyOB6RrrLIpz6OupdHt\/rf9fyD5feQBiGNEeA6\/fTTg91UjQ4w9LR77rlnoO222y7oZ+p5ET4g\/M1vfhN6+WOOOSZYIXBDgaKvNfRiiy0Wf\/7zn2P8+PEFkMWpbzAa2NVXX13cfDDy2QyjoeSminwRcJTjORpyi4X9HnGA5dhjjw2H8fjuvffewkCtYyU2Yl1x4u\/ox7TZskK8WWedNS6++GJBBVH41hmptxstlMLxApzjqYKp5Y8jDksSyxTppDIDZ0tww\/86F3rHbnmot+m2fBpGGGIBQxqEGjXFZgaJ3Q4xqun569sA1TAg4+KbccYZ61mK30YeIxVLzY52HJpTIQPIgmHSH\/kawYy8bo3QUPLsWpLyTGKbzDHyPvXUU2HTTBxg33\/\/\/Qu1P8xuUwCf3Wv3CzV+\/kYuHQJFZCOQjTf+ieQtDJiMho6m\/AZ2I1PiY8179dVXLxTs5S\/eo48+2uFXuhgKoyggTVo6tHdoSKV0h7o7pEFIk4Sx4uuuuy5cXjbCOcyubxTMe7AqrmEDAIWCeh6\/ramMHIBgY8K0cMKECWHEFZ5Ies5anb0mPw3UyAIIya\/edUQEwAlEwAZg4uJl5Zyf5zKJZ7oMpDbWjJTl8FSOt956qyhr+o1HZ8JFAGwqqW7I1R6dAuUO4Y2IfvAss8zSGlx+bvUcwg9DGoQ++GG0MMrRuWTS8YQTTgiNsdwmTN00QNMo0zaNrxyenk1HjXymd8CITBE1\/MTD1bCHDx\/expCyM1kjBiDiqSIg4w\/EXKPyr3\/96+JCtN+NyBQbWHUwTLlbS1bxpnKpawq3pkvPwnVG6oWAWSdjxEw8Va7yWq+mMNP7qk0V9ZNH4hsq7pAGoQbGyLFGkV44EKTRxKjDXyPS2\/tt\/XXqqafG+++\/H2nU8oxvzjnnLL7BYb1jVDQNpTZWvyaUx+jRo4uP4pi+KgeLAkaqNMpJr55M5UaOHFmonSmL9ZUOQnr1vOXfqfzKZEPJWk\/8Mo9n6bii5vMDrrMx\/mwNKAwJ0wlRstcBsDtkZJSu8EYE1NaRPi5ryq7MvnVSz+\/8WVmlLQ5rAfU8Pf3dH+MPaRC6qeGDN9ZwdvuMiNaFGiPdSqOi3VE8GsUiiywSdgR9XMWocsopp4RNDkAy3fOC6dxqZL5WhW+XXXap1NNkpcCa0a6kW9sAbVdVGo3IOmz\/ljXg9ddfH656WefRue1oJFI21vKM0upkd9WGjvVffV7Wg8Bu6r3RRhsVyuGJx7GJKbszZLu6pqI2kFKnlfiqXFNS91DXXHPN4oa66T8+8rXu1BF5B2QiD0ohptlpxLSxpBPgijeYaEiDsFarhe16O32mV0Yw4POC7ZR64XZHKSyY9hnRzj333OIMz9QUaADAlMzoYS2lARvVXBsCVDuOtdrkZ6umXRqwa0XIXc3U4OSJlKOeWDZI6StvmlrKp7ybWv49atSoYvS0iWJHde211y52b43G4uBN+RjV7fDitRuqo1JW4abblMXJS7hPJACKsI5IHqbpZLr11lu3fu1ZPZPs5KNTsTvLVo5P8ek0yNWlZGtxbkd5DbTwIQ3Cgfay+qK8AGG0NSU0wjuvTKNWX+Q\/FPP4fwAAAP\/\/RCVnuwAAAAZJREFUAwBZMG4eJX21nAAAAABJRU5ErkJggg==","height":135,"width":225}}
%---
