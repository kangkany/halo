function plot_profiles(zNode, rmsProf, envProf)
figure('Color','w');
subplot(1,2,1);
plot(rmsProf, zNode, 'r-', 'LineWidth', 1.5); grid on;
xlabel('RMS y (m)'); ylabel('z (m)'); title('RMS profile (CF)');
subplot(1,2,2);
plot(envProf, zNode, 'b-', 'LineWidth', 1.5); grid on;
xlabel('Envelope |y| (m)'); ylabel('z (m)'); title('Displacement envelope');
end
