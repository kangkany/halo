function Fs = soil_py_force(q, cfg, meshData)
% Bilinear p-y like equivalent nodal force near bottom
Fs = zeros(meshData.ndof,1);
yieldDisp = 0.15;
for i = 1:meshData.nn
    if abs(meshData.zNode(i)) >= (meshData.L - cfg.soilLen)
        dofY = 2*i-1;
        y = q(dofY);
        k = cfg.ksSoil;
        py = k*y;
        py = max(min(py, k*yieldDisp), -k*yieldDisp);
        Fs(dofY) = Fs(dofY) - py;
    end
end
end
