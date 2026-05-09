function [M,C,K] = assemble_MCK(cfg, meshData)
ndof = meshData.ndof;
M = zeros(ndof); K = zeros(ndof);

D = cfg.D; t = cfg.t;
Di = D - 2*t;
A = pi/4*(D^2 - Di^2);
I = pi/64*(D^4 - Di^4);

ms = cfg.rhoSteel*A;      % structural mass per length
ma = cfg.ca*cfg.rho*pi*D^2/4;
m  = ms + ma;

EI = cfg.E*I;
T  = cfg.Ttop;
le = meshData.le;

for e = 1:meshData.ne
    dof = [2*e-1,2*e,2*e+1,2*e+2];

    Me = m*le/420 * [156 22*le 54 -13*le;
                     22*le 4*le^2 13*le -3*le^2;
                     54 13*le 156 -22*le;
                     -13*le -3*le^2 -22*le 4*le^2];

    Ke_b = EI/le^3 * [12 6*le -12 6*le;
                      6*le 4*le^2 -6*le 2*le^2;
                      -12 -6*le 12 -6*le;
                      6*le 2*le^2 -6*le 4*le^2];

    Ke_g = T/(30*le)*[36 3*le -36 3*le;
                      3*le 4*le^2 -3*le -le^2;
                      -36 -3*le 36 -3*le;
                      3*le -le^2 -3*le 4*le^2];

    M(dof,dof) = M(dof,dof) + Me;
    K(dof,dof) = K(dof,dof) + Ke_b + Ke_g;
end

% Soil equivalent spring at bottom segment translational DOFs
for i = 1:meshData.nn
    if abs(meshData.zNode(i)) >= (meshData.L - cfg.soilLen)
        dofY = 2*i - 1;
        K(dofY,dofY) = K(dofY,dofY) + cfg.ksSoil;
    end
end

C = cfg.zeta*(M + K*1e-3);
end
