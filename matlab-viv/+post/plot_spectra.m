function plot_spectra(time, signal, ttl)
fs = 1/mean(diff(time));
N = numel(signal);
sig = signal(:) - mean(signal);
Y = fft(sig);
f = (0:floor(N/2))*fs/N;
A = abs(Y(1:floor(N/2)+1))/N*2;

figure('Color','w');
plot(f, A, 'k-', 'LineWidth', 1.2); grid on;
xlabel('Frequency (Hz)'); ylabel('Amplitude'); title(ttl);
xlim([0, 0.5]);
end
