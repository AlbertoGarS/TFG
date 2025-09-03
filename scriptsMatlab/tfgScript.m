%% Sears
clear; close all; clc;

%================= LECTURA DE forceCoeffsxx.dat =%
raw = readmatrix('forceCoeffs05.dat','NumHeaderLines',40);
t_raw  = raw(:,1);
Cd_raw = raw(:,3); 
Cl_raw = raw(:,4);

%----------------- Variables -----------------%
Uinf = 30;           % Velocidad libre [m/s]
c    = 1.0;          % Cuerda [m]
b    = c/2;          % Semicuerda [m]
f    = 15/pi;         % Frecuencia [Hz]
omega= 2*pi*f;       % Frecuencia angular [rad/s]
alpha0_deg = 2;      % Ángulo de ataque base [deg]
alpha0 = deg2rad(alpha0_deg);   % Ángulo de ataque base [rad]
wHat = 1.05; % 1.05 m/s ~ Uinf*deg2rad(2), Ráfagas vertical de 2 grados 
CL0 = 0.2074589;   % Cl base simulacion en simulación estacionaria AoA=2 grados
k = omega*b/Uinf;    % Frecuencia reducida
T    = 1/f;                % Período

%----------------- THEODORSEN & SEARS ----------------%
H0 = besselh(0, 2, k);
H1 = besselh(1, 2, k);
Ck = H1 ./ (H1 + 1i*H0);
J0 = besselj(0, k);
J1 = besselj(1, k);
S  = (J0 - 1i*J1).*Ck + 1i*J1;

gain  = abs(S);
phase = angle(S);

% Curvas S(k) + punto en k
kvec  = linspace(0,2,400);
Svals = arrayfun(@(kk) (besselj(0,kk)-1i*besselj(1,kk)) .* ...
                    (besselh(1,2,kk)./(besselh(1,2,kk)+1i*besselh(0,2,kk))) + 1i*besselj(1,kk), kvec);

figure; 
plot(kvec, abs(Svals),'LineWidth',1.5); grid on; hold on
plot(k, abs(S),'o','MarkerSize',8,'DisplayName','k actual');
xlabel('k'); ylabel('|S(k)|'); title('Módulo de S(k)');
legend('S(k)','k actual','Location','best');

figure; 
plot(kvec, rad2deg(angle(Svals)),'LineWidth',1.5); grid on; hold on
plot(k, rad2deg(angle(S)),'o','MarkerSize',8,'DisplayName','k actual');
xlabel('k'); ylabel('Fase [deg]'); title('Fase de S(k)');
legend('Fase S(k)','k actual','Location','best');

%----------------- Señales temporales (sobre t_raw) -----------------%
phase_shift = -pi/2;
% Respuesta Sears en el MISMO eje temporal que los datos (t_raw)
deltaCL_rawT = 2*pi*(wHat/Uinf) * real( S .* exp(1i*(omega*t_raw + phase_shift)));
CL_sears     = CL0 + deltaCL_rawT;

% Seno de referencia (misma amplitud teórica y t_raw, con phi=0)
A = 2*pi*(wHat/Uinf)*abs(S);
CL_sine_ref = CL0 + A*sin(omega*t_raw);

% w(t) en t_raw
w_t_raw = wHat*sin(omega*t_raw);
figure; 
plot(t_raw, w_t_raw, 'DisplayName','w(t)'); grid on
xlabel('t [s]'); ylabel('w [m/s]');
title('Componente vertical de la ráfaga');
legend show

%================= AJUSTE SENOIDAL =================%
% Modelo: y = A*sin(omega*t) + B*cos(omega*t) + C
fit_sine = @(t,y,om) ([sin(om*t), cos(om*t), ones(size(t))] \ y);

% Ventana de ajuste: últimas 3 ondas
t_final = t_raw(end);
idx = t_raw >= (t_final - 3*T);

% Ajuste sobre RAW (Cl_raw)
p_raw = fit_sine(t_raw(idx), Cl_raw(idx), omega);
A_raw = p_raw(1); B_raw = p_raw(2); C_raw = p_raw(3);
R_raw = hypot(A_raw,B_raw);
phi_raw = atan2(B_raw,A_raw);

% Reconstrucción para plot
yhat_raw = A_raw*sin(omega*t_raw(idx)) + B_raw*cos(omega*t_raw(idx)) + C_raw;

fprintf('\n=== Ajuste seno (últimas 3 ondas) — RAW ===\n');
fprintf('RAW: R = %.6f,  phi = %.4f rad (%.2f deg),  C = %.6f\n', ...
        R_raw, phi_raw, rad2deg(phi_raw), C_raw);

%================= FIGURA 1: CFD RAW vs Sears =====================
figure;
plot(t_raw, Cl_raw,   'b',   'DisplayName','C_L CFD'); hold on
plot(t_raw, CL_sears, 'r--', 'DisplayName','C_L Sears');
grid on; xlabel('t [s]'); ylabel('C_L');
title('Comparación CFD vs Sears');
legend('Location','best');

%================= FIGURA 2: CFD vs Sears + seno(A, phi=0) ======
figure;
plot(t_raw, Cl_raw,      'b',   'LineWidth',1.2, 'DisplayName','C_L CFD'); hold on
plot(t_raw, CL_sears,    'r--', 'LineWidth',1.2, 'DisplayName','C_L Sears');
plot(t_raw, CL_sine_ref, 'k-.', 'LineWidth',1.1, 'DisplayName','C_{L0}+A\cdot\sin(\omega t)');
grid on; xlabel('t [s]'); ylabel('C_L');
title('C_L vs Sears y seno de referencia (A=|ΔC_L|, \phi=0)');
legend('Location','best');

% ====== FIGURAS EXTRA: última 1 onda y últimas 3 ondas ======
t_end = t_raw(end);
mask1 = (t_raw >= (t_end - 1*T));   % última 1 onda completa
mask3 = (t_raw >= (t_end - 3*T));   % últimas 3 ondas completas

figure;
plot(t_raw(mask1), Cl_raw(mask1),      'b',   'LineWidth',1.2, 'DisplayName','C_L CFD'); hold on
plot(t_raw(mask1), CL_sears(mask1),    'r--', 'LineWidth',1.2, 'DisplayName','C_L Sears');
plot(t_raw(mask1), CL_sine_ref(mask1), 'k-.', 'LineWidth',1.1, 'DisplayName','C_{L0}+A\sin(\omega t)');
grid on; xlabel('t [s]'); ylabel('C_L');
title('C_L vs Sears y seno — última 1 onda');
legend('Orientation','horizontal','Location','southoutside');

figure;
plot(t_raw(mask3), Cl_raw(mask3),      'b',   'LineWidth',1.2, 'DisplayName','C_L CFD'); hold on
plot(t_raw(mask3), CL_sears(mask3),    'r--', 'LineWidth',1.2, 'DisplayName','C_L Sears');
plot(t_raw(mask3), CL_sine_ref(mask3), 'k-.', 'LineWidth',1.1, 'DisplayName','C_{L0}+A\sin(\omega t)');
grid on; xlabel('t [s]'); ylabel('C_L');
title('C_L vs Sears y seno — últimas 3 ondas');
legend('Orientation','horizontal','Location','southoutside');

%================= SALIDA NUMÉRICA ÚTIL =====================
fprintf('\n--- Parámetros ---\n');
fprintf('U=%.3f m/s, c=%.3f m, f=%.6f Hz, T=%.6f s, wHat=%.6f m/s\n', Uinf, c, f, T, wHat);
fprintf('k = %.6f\n', k);
fprintf('Sears: real = %.8f, imag = %.8f, |S| = %.8f, arg(S) = %.8f rad (%.4f deg)\n', ...
        real(S), imag(S), abs(S), angle(S), rad2deg(angle(S)));
fprintf('Amplitud teórica A = 2*pi*(wHat/Uinf)*|S| = %.6f\n', A);

%================= PLOT AJUSTE =======================
figure;
plot(t_raw(idx), Cl_raw(idx), 'b', 'DisplayName','C_L (datos)'); hold on
plot(t_raw(idx), yhat_raw,    'k--', 'DisplayName','Ajuste seno');
grid on; xlabel('t [s]'); ylabel('C_L');
title('Ajuste senoidal sobre las últimas 3 ondas');
legend('Orientation','horizontal','Location','southoutside');
