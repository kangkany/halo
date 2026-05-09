function [pNew, pdNew] = step_rk4(rhs, p, pd, dt)
% state x=[p;pd], xdot=[pd; rhs(p,pd)]
f = @(pp,ppd) [ppd; rhs(pp,ppd)];

x = [p; pd];
k1 = f(x(1:end/2), x(end/2+1:end));
xx = x + 0.5*dt*k1;
k2 = f(xx(1:end/2), xx(end/2+1:end));
xx = x + 0.5*dt*k2;
k3 = f(xx(1:end/2), xx(end/2+1:end));
xx = x + dt*k3;
k4 = f(xx(1:end/2), xx(end/2+1:end));

xNew = x + dt*(k1 + 2*k2 + 2*k3 + k4)/6;
pNew = xNew(1:end/2);
pdNew = xNew(end/2+1:end);
end
