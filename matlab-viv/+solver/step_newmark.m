function [qNew, qdNew, qddNew] = step_newmark(M,C,K,F,q,qd,qdd,dt,beta,gamma,bc)
nd = length(q);
free = bc.freeDof;
fixd = bc.fixedDof;

a0 = 1/(beta*dt^2); a1 = gamma/(beta*dt);
a2 = 1/(beta*dt);   a3 = 1/(2*beta)-1;
a4 = gamma/beta-1;  a5 = dt*(gamma/(2*beta)-1);

Keff = K + a0*M + a1*C;

qPred  = q + dt*qd + dt^2*(0.5-beta)*qdd;
qdPred = qd + dt*(1-gamma)*qdd;

R = F + M*(a0*qPred) + C*(a1*qPred + qdPred);

% impose fixed dof via partition
qFix = bc.qFix;
Kff = Keff(free, free);
Kfc = Keff(free, fixd);
Rf  = R(free) - Kfc*qFix;

qNew = q;
qNew(fixd) = qFix;
qNew(free) = Kff \ Rf;

qddNew = a0*(qNew - qPred);
qdNew  = qdPred + gamma*dt*qddNew;

qddNew(fixd) = bc.qddFix;
qdNew(fixd)  = bc.qdFix;
end
