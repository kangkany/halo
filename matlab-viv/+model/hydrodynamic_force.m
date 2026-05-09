function F = hydrodynamic_force(p, q, qd, cfg, meshData, ~)
F = zeros(meshData.ndof,1);
le = meshData.le;

for i = 1:meshData.nn
    dofY = 2*i - 1;
    Vr = cfg.U0 - qd(dofY);
    qdyn = 0.5*cfg.rho*Vr*abs(Vr);
    lift = qdyn*cfg.D*cfg.Cl0*p(i); % nodal lift per length
    % lump to translation dof
    w = 1.0;
    if i==1 || i==meshData.nn, w=0.5; end
    F(dofY) = F(dofY) + lift*le*w;
end
end
