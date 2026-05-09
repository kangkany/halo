%% Top-tensioned riser VIV reproduction (MVP, CF direction)
% Run this script directly in MATLAB.
clear; clc; close all;

cfg = cfg.case_sway();
meshData = mesh.build_mesh(cfg);
[M,C,K] = model.assemble_MCK(cfg, meshData);

n  = meshData.ndof;
nt = floor(cfg.T/cfg.dt) + 1;
time = (0:nt-1)'*cfg.dt;

q   = zeros(n,1);
qd  = zeros(n,1);
qdd = zeros(n,1);

p    = zeros(meshData.nn,1);
pdot = zeros(meshData.nn,1);

qHist = zeros(n,nt);

for k = 1:nt
    t = time(k);

    bc = model.boundary_update(cfg, meshData, t);

    % Wake oscillator update (RK4)
    rhs = @(pp,ppd) model.wake_rhs(pp, ppd, q, qd, cfg, meshData);
    [p, pdot] = solver.step_rk4(rhs, p, pdot, cfg.dt);

    % External forces
    Fh = model.hydrodynamic_force(p, q, qd, cfg, meshData, t);
    Fs = model.soil_py_force(q, cfg, meshData);
    F  = Fh + Fs;

    [q, qd, qdd] = solver.step_newmark(M, C, K, F, q, qd, qdd, cfg.dt, cfg.beta, cfg.gamma, bc);

    qHist(:,k) = q;
end

rmsProf = post.calc_rms(qHist, round(0.5*nt):nt);
envProf = post.calc_envelope(qHist, round(0.5*nt):nt);

post.plot_profiles(meshData.zNode, rmsProf, envProf);
post.plot_spectra(time, qHist(meshData.midDof,:), 'Mid-point response spectrum');

fprintf('Done. Peak RMS = %.4f m\n', max(rmsProf));
