function rmsProf = calc_rms(qHist, idxRange)
if nargin < 2, idxRange = 1:size(qHist,2); end
nn = size(qHist,1)/2;
rmsProf = zeros(nn,1);
for i = 1:nn
    y = qHist(2*i-1, idxRange);
    rmsProf(i) = sqrt(mean(y.^2));
end
end
