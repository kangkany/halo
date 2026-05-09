function [pdd] = wake_rhs(p, pd, q, qd, cfg, meshData)
% Simplified Van der Pol wake oscillator at each node
pdd = zeros(meshData.nn,1);
for i = 1:meshData.nn
    dofY = 2*i-1;
    ydot = qd(dofY);
    Vr = cfg.U0 - ydot;
    omega = 2*pi*cfg.lambda*max(abs(Vr),1e-3)/cfg.D;
    forcing = cfg.Ay/cfg.D * (q(dofY));
    pdd(i) = -cfg.eps*omega*(p(i)^2 - 1)*pd(i) - omega^2*p(i) + forcing;
end
end
