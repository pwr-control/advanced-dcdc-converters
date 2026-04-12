clear
clc

Lr1 = 4.0744e-06;   % Primäre Streuinduktivität
Lr2 = 4.0744e-06;   % Sekundäre Streuinduktivität (reflektiert)
Lm  = 1.6297e-05;   % Hauptinduktivität
Cr1 = 6.2170e-07;  % Primärer Resonanzkondensator
Cr2 = 6.2170e-07;  % Sekundärer Resonanzkondensator (reflektiert)
R1  = 0.1;     % Primärer Wicklungswiderstand
R2  = 0.1;     % Sekundärer Wicklungswiderstand (reflektiert)

fs  = 90e3;          % Schaltfrequenz (Hz)
ws  = 2 * pi * fs;    % Kreisfrequenz (rad/s)

Delta = Lr1*Lr2 + Lr1*Lm + Lr2*Lm;

A1 = zeros(4,4);

A1(1,1) = -R1*(Lr2 + Lm)/Delta;
A1(1,2) = -R2*Lm/Delta;
A1(1,3) = -(Lr2 + Lm)/Delta;
A1(1,4) = -Lm/Delta;

A1(2,1) = -R1*Lm/Delta;
A1(2,2) = -R2*(Lr1 + Lm)/Delta;
A1(2,3) = -Lm/Delta;
A1(2,4) = -(Lr1 + Lm)/Delta;

A1(3,1) = 1/Cr1;
A1(3,2) = 0;
A1(3,3) = 0;
A1(3,4) = 0;

A1(4,1) = 0;
A1(4,2) = 1/Cr2;
A1(4,3) = 0;
A1(4,4) = 0;

B1 = zeros(4,2);

B1(1,1) = (Lr2 + Lm)/Delta;
B1(1,2) = -Lm/Delta;

B1(2,1) = Lm/Delta;
B1(2,2) = -(Lr1 + Lm)/Delta;

B1(3,1) = 0;
B1(3,2) = 0;

B1(4,1) = 0;
B1(4,2) = 0;

Vdc1 = 800;
Vdc2_ref = 800;
phi = pi/6;

eigenvalues = eig(A1);
isStable = all(real(eigenvalues) < 0);

Ts = 1/(10*fs); % Oder ein Vielfaches davon, z.B. 10*Ts für langsamere Regelung
sys_continuous = ss(A1, B1, eye(4), 0);
sys_discrete = c2d(sys_continuous, Ts, 'zoh');
Phi = sys_discrete.A;
Gamma = sys_discrete.B;

t = linspace(0, 20*Ts, 2000); % Simulate 5 switching cycles
% Primary voltage (Square wave -1 to 1 scaled by Vdc1)
u1 = Vdc1 * square(2*pi*fs*t);
% Secondary voltage (Shifted by phi)
u2 = Vdc2_ref * square(2*pi*fs*t - phi);
u = [u1; u2];

x0 = [0, 0, 0, 0];
[y, t_out] = lsim(sys_continuous, u, t, x0);

figure;
subplot(2,1,1);
plot(t_out*1e6, y(:,1), 'b', t_out*1e6, y(:,2), 'r');
grid on; ylabel('Current (A)'); legend('iL1', 'iL2');
title('Continuous-Time Resonant Currents');

subplot(2,1,2);
plot(t_out*1e6, y(:,3), 'b', t_out*1e6, y(:,4), 'r');
grid on; ylabel('Voltage (V)'); xlabel('Time (\mus)'); legend('vCr1', 'vCr2');
title('Resonant Capacitor Voltages');



ws = 2*pi*fs;

%% First Harmonic Approximation (FHA)
Zr1 = R1 + j*(ws*Lr1 - 1/(ws*Cr1));
Zr2 = R2 + j*(ws*Lr2 - 1/(ws*Cr2));
Zm = j*ws*Lm;

phi = pi/6;


Z1total = Zr1 + (Zr2*Zm)/(Zr2 + Zm);

Z2total =  Zr2 + (Zr1*Zm)/(Zr1 + Zm);

U1 = 4*Vdc1/pi;
U2 = 4*Vdc2_ref/pi * exp(-j*phi);

% Ir2 = (U1 - U2)/Z1tot;

% Ir2 = (U1 * (Zm)/(Zr1 + Zm) - U2)/(Z2total);


X = inv(j*ws*eye(4) - A1) * B1 * [U1; U2];

%%

alpha1 = linspace(pi/2,pi,3);
alpha2 = linspace(pi/2,pi,3);
for z = 1:length(alpha1)
phi_rad = linspace(0,pi,1000);
for k = 1:length(phi_rad)
    U_vector = [4*Vdc1/pi*sin(alpha1(z)/2); (4*Vdc2_ref/pi*sin(alpha2(z)/2)) * exp(-1j * phi_rad(k))];
    
    X = inv(1j*ws*eye(4) - A1) * (B1 * U_vector);
    
    Ir2_peak = abs(X(2));
    Idc_out(z,k) = (2/pi) * Ir2_peak;

    U2_phasor = (4*Vdc2_ref/pi) * exp(-1j * phi_rad(k));
    Ir2_phasor = X(2);
    
    theta_rel = angle(Ir2_phasor) - angle(U2_phasor);
    
    I_active(z,k) = (2/pi) * abs(Ir2_phasor) * cos(theta_rel);
    
    I_reactive(z,k) = (2/pi) * abs(Ir2_phasor) * sin(theta_rel);

end
end

figure;
plot(phi_rad, Idc_out, 'LineWidth', 2);
grid on;
xlabel('Phase Shift in rad');
ylabel('Output DC Current I_{o,dc} [A]');
legend({['\alpha = ', num2str(alpha1(1))], ...
        ['\alpha = ', num2str(alpha1(2))], ...
        ['\alpha = ', num2str(alpha1(3))]});

figure;
hold on;
for k = 1:length(alpha1)
    plot(phi_rad, I_active(k,:), 'LineWidth', 2);
end
grid on;
xlabel('Phase Shift in rad');
ylabel('Output DC Current I_{act,2} [A]');
legend({['\alpha = ', num2str(alpha1(1))], ...
        ['\alpha = ', num2str(alpha1(2))], ...
        ['\alpha = ', num2str(alpha1(3))]});

figure;
hold on;
for k = 1:length(alpha1)
    plot(phi_rad, I_active(k,:), 'LineWidth', 2);
end
grid on;
xlabel('Phase Shift in rad');
ylabel('Output DC Current I_{reac,2} [A]');
legend({['\alpha = ', num2str(alpha1(1))], ...
        ['\alpha = ', num2str(alpha1(2))], ...
        ['\alpha = ', num2str(alpha1(3))]});