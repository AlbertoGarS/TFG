%% Sears
clear; close all; clc;

A = 30*cos(deg2rad(2));                 % Amplitud (constante)
k=   0.4;
trans = k*30;
f    = trans/pi;         % Frecuencia [Hz]
omega= 2*pi*f;       % Frecuencia angular [rad/s]
w = omega;
nPeriods = 33*k;  % Nº de periodos a listar/plotear
T  = 2*pi/w;               % Periodo
N0 = 2*nPeriods;           % nº de cruces por cero en nPeriods

% Tiempos teóricos (primeros nPeriods)
t_zero = (0:N0).' * (pi/w);                     % wt = n*pi
t_max  = ((pi/2) + (0:nPeriods-1).'*2*pi) / w;  % wt = pi/2 + 2*pi*n
t_min  = ((3*pi/2) + (0:nPeriods-1).'*2*pi) / w;% wt = 3*pi/2 + 2*pi*n

% ---- Salida en Command Window ----
fprintf('\n============================\n');
fprintf('w = %.6g rad/s  (T = %.6g s)\n', w, T);
fprintf('A = 30*cos(2) = %.6f\n', A);

fprintf('\nCruces por cero (primeros %d*2):\n', nPeriods);
disp(t_zero.');

fprintf('Máximos (sin(w t)=+1):\n');
disp(t_max.');

fprintf('Mínimos (sin(w t)=-1):\n');
disp(t_min.');


