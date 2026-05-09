function meshData = build_mesh(cfg)
L = cfg.L;
ne = cfg.ne;
nn = ne + 1;
le = L / ne;

zNode = linspace(0, -L, nn)';

% 2 dof/node in 2D EB beam: [y, theta]
ndof = 2 * nn;

midNode = floor((nn+1)/2);
meshData = struct('L',L,'ne',ne,'nn',nn,'le',le,'zNode',zNode,'ndof',ndof,...
    'midNode',midNode,'midDof',2*midNode-1);
end
