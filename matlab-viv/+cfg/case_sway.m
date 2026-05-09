function cfg = case_sway()
% Base case for sway-induced CF response
cfg.rho      = 1025;      % seawater density (kg/m^3)
cfg.Cd       = 1.2;
cfg.Cl0      = 0.3;
cfg.D        = 0.5334;    % outer diameter (m)
cfg.t        = 0.026;     % wall thickness (m)
cfg.E        = 210e9;     % Young's modulus (Pa)
cfg.rhoSteel = 7850;

cfg.L        = 576.2;     % riser length below sea level (m)
cfg.ne       = 40;        % number of beam elements
cfg.Ttop     = 3.7e6;     % top tension (N)

cfg.U0       = 0.75;      % uniform current (m/s)
cfg.ca       = 1.0;       % added mass coeff
cfg.zeta     = 0.01;      % structural modal-like damping

cfg.ksSoil   = 5e6;       % equivalent soil stiffness at touchdown/wellhead region (N/m)
cfg.soilLen  = 20;        % soil interaction length from bottom (m)

cfg.As       = 0.3;       % sway amplitude (m)
cfg.Ts       = 11.2;      % sway period (s)

cfg.beta     = 1/4;       % Newmark-beta
cfg.gamma    = 1/2;
cfg.dt       = 0.02;
cfg.T        = 300;

% Wake oscillator parameters (simplified)
cfg.eps      = 0.3;
cfg.Ay       = 12;
cfg.lambda   = 0.8;
