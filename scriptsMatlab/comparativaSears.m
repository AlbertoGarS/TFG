%% Sears
clear; close all; clc;

%---------------- Puntos corregidos a superponer ----------------%
%  k       |S|           fase [rad]
pts = [ 0.2   0.616125163   -0.1128;
        0.3   0.576513771   -0.0041;
        0.4   0.545815056    0.0580;
        0.5   0.52998596    0.0700;
        0.6   0.475413549    0.1400 ];

k_pts   = pts(:,1);
mag_pts = pts(:,2);
phs_pts = pts(:,3); % rad

%---------------- Cálculo de S(k) con Bessel/Hankel --------------%
% Nota: evitamos exactamente k=0 para no evaluar Hn(0).
kvec = linspace(0, 1, 400);
kvec(1) = max(kvec(1), eps);

% Implementación vectorizada equivalente a tu snippet:
H0 = besselh(0, 2, kvec);
H1 = besselh(1, 2, kvec);
Ck = H1 ./ (H1 + 1i*H0);
J0 = besselj(0, kvec);
J1 = besselj(1, kvec);
Svals = (J0 - 1i.*J1).*Ck + 1i.*J1;

gain  = abs(Svals);
phase = unwrap(angle(Svals));   % fase continua (rad)

%---------------- Gráfica: |S(k)| --------------------------------%
figure;
plot(kvec, gain, 'LineWidth', 1.8); grid on; hold on;
plot(k_pts, mag_pts, 'o', 'MarkerSize', 7, 'LineWidth', 1.5);
xlabel('k'); ylabel('|S(k)|'); title('Módulo de S(k)');
legend({'S(k)','Puntos medidos'}, 'Location','northeast');

%---------------- Gráfica: fase(S(k)) ----------------------------%
figure;
plot(kvec, phase, 'LineWidth', 1.8); grid on; hold on;
plot(k_pts, phs_pts, 's', 'MarkerSize', 7, 'LineWidth', 1.5);
xlabel('k'); ylabel('\angle S(k) [rad]'); title('Fase de S(k)');
legend({'\angle S(k)','Puntos medidos'}, 'Location','best');

