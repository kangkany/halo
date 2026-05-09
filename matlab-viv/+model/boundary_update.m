function bc = boundary_update(cfg, meshData, t)
% top node displacement boundary y(1)=As*sin(2*pi*t/Ts)
yTop  = cfg.As*sin(2*pi*t/cfg.Ts);
vyTop = cfg.As*(2*pi/cfg.Ts)*cos(2*pi*t/cfg.Ts);
ayTop = -cfg.As*(2*pi/cfg.Ts)^2*sin(2*pi*t/cfg.Ts);

bc.fixedDof = [1,2];  % y and theta at top node
bc.qFix = [yTop; 0];
bc.qdFix = [vyTop; 0];
bc.qddFix = [ayTop; 0];

bc.freeDof = setdiff(1:meshData.ndof, bc.fixedDof);
end
