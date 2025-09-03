%% Sears
clear; close all; clc;

%----------------- Variables -----------------%
Uinf = 30;           % Velocidad libre [m/s]
c    = 1.0;          % Cuerda [m]
b    = c/2;          % Semicuerda [m]
f    = 15/pi;         % Frecuencia [Hz]
omega= 2*pi*f;       % Frecuencia angular [rad/s]
alpha0_deg = 2;      % Ángulo de ataque base [deg]
alpha0 = deg2rad(alpha0_deg);   % Ángulo de ataque base [rad]
wHat = Uinf*deg2rad(2); % Ráfagas vertical 2 grados ~ 1.05 m/s
CL0 = 0.2074589;   % Cl base simulacion en simulación estacionaria AoA=2 grados
k = omega*b/Uinf;    % Frecuencia reducida

%----------------- THEODORSEN & SEARS ----------------%
H0 = besselh(0, 2, k);
H1 = besselh(1, 2, k);
Ck = H1 ./ (H1 + 1i*H0);
J0 = besselj(0, k);
J1 = besselj(1, k);
S  = (J0 - 1i*J1).*Ck + 1i*J1;
gain  = abs(S); 
phase = angle(S);

kvec = linspace(0,2,400);
Svals = arrayfun(@(kk) (besselj(0,kk)-1i*besselj(1,kk)) .* ...
    (besselh(1,2,kk)./(besselh(1,2,kk)+1i*besselh(0,2,kk))) + 1i*besselj(1,kk), kvec);

figure; 
plot(kvec, abs(Svals),'LineWidth',1.5); grid on; hold on
xlabel('k'); ylabel('|S(k)|'); title('Módulo de S(k)');
legend('S(k)','k actual','Location','best');

figure; 
plot(kvec, rad2deg(angle(Svals)),'LineWidth',1.5); grid on; hold on
plot(k, rad2deg(angle(S)),'o','MarkerSize',8,'DisplayName','k actual');
xlabel('k'); ylabel('Fase [deg]'); title('Fase de S(k)');
legend('Fase S(k)','k actual','Location','best');

%----------------- w(t) -----------------%
T = 1/f;
t = linspace(0, 3.25, 2000);
w_t = wHat*sin(omega*t);   % componente vertical de ráfaga
deltaCL = 2*pi*(wHat/Uinf) * real( S * exp(1i*omega*t) );  % Sears
CL_sears = CL0 + deltaCL;

% Velocidad vertical
figure; 
plot(t, w_t, 'DisplayName','w(t)'); grid on
xlabel('t [s]'); ylabel('w [m/s]');
title('Componente vertical de la ráfaga');
legend show

% C_L estimado con Sears
figure;
plot(t, CL_sears, 'r','LineWidth',1.2,'DisplayName','C_L (Sears)'); grid on
xlabel('t [s]'); ylabel('C_L');
title('C_L(t) estimado con la función de Sears');
legend('Location','best');

%----------------- SALIDA NUMÉRICA -------------------%
fprintf('--- Parámetros ---\n');
fprintf('U=%.3f m/s, c=%.3f m, f=%.6f Hz, T=%.6f s, wHat=%.6f m/s\n', Uinf, c, f, T, wHat);
fprintf('k = %.6f\n', k);

fprintf('\n--- Sears S(k) ---\n');
fprintf('S_real = %.8f\n', real(S));
fprintf('S_imag = %.8f\n', imag(S));
fprintf('|S|    = %.8f\n', gain);
fprintf('arg(S) = %.8f rad (%.4f deg)\n', phase, rad2deg(phase));