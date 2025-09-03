%% Plano complejo de la función de Sears + puntos medidos (|S|, fase)
clear; clc;

%----------- Puntos (k, |S|, fase[rad]) a superponer ----------------%
pts = [ 0.2   0.616125163   -0.1128;
        0.3   0.576513771   -0.0041;
        0.4   0.545815056    0.0580;
        0.5   0.52998596    0.0700;
        0.6   0.475413549    0.1400 ];

k_pts   = pts(:,1);
mag_pts = pts(:,2);
phs_pts = pts(:,3);                     % rad
z_pts   = mag_pts .* exp(1i*phs_pts);   % complejos medidos

%----------- Curva S(k) (Bessel/Hankel) -----------------------------%
kvec = linspace(0, 10, 2000); % hasta k=10 con buena resolución
kvec(1) = max(kvec(1), eps); % evita k=0 exacto

H0 = besselh(0, 2, kvec);
H1 = besselh(1, 2, kvec);
Ck = H1 ./ (H1 + 1i*H0);
J0 = besselj(0, kvec);
J1 = besselj(1, kvec);
Svals = (J0 - 1i.*J1).*Ck + 1i.*J1; % S(k) complejo (continuo)

% Valores teóricos para las k medidas:
H0p = besselh(0, 2, k_pts);
H1p = besselh(1, 2, k_pts);
Ckp = H1p ./ (H1p + 1i*H0p);
J0p = besselj(0, k_pts);
J1p = besselj(1, k_pts);
z_theo = (J0p - 1i.*J1p).*Ckp + 1i.*J1p;

%----------- Gráfica en el plano complejo ---------------------------%
figure('Name','Sears en el plano complejo','Color','w');
plot(real(Svals), imag(Svals), 'k-', 'LineWidth',1.8); hold on; grid on;
axis equal;
xlabel('Real part'); ylabel('Imaginary part');
title('S(k) en el plano complejo (0 \leq k \leq 10)');

% Limites del gráfico
xlim([-0.25 1.0]);
ylim([-0.4 0.3]);

% Puntos medidos (rojo)
plot(real(z_pts), imag(z_pts), 'ro', 'MarkerSize',7, 'LineWidth',1.5);

% Puntos teóricos (azul)
plot(real(z_theo), imag(z_theo), 'bs', 'MarkerSize',7, 'LineWidth',1.5);

legend({'S(k) teórico (0\leq k\leq10)', ...
        'Datos medidos', ...
        'S(k) teórico en k_{pts}'}, 'Location','best');

