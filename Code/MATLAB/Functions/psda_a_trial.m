function [max_freq, label]=psda_a_trial(fs, xi, num_sample_neigh, f_stim, num_harmonic, ...
    channel, trial)
% ================================== (2023-2024) ======================================
% ======================== Presented by: Reza Saadatyar ===============================
% ====================== E-mail: Reza.Saadatyar@outlook.com ===========================

% PSDA_A_TRIAL calculates the Power Spectral Density Amplitude (PSDA) for a single trial.
%
% Inputs:
%   - fs: Sampling frequency of the signal.
%   - xi: EEG signal data for a single trial.
%   - num_sample_neigh: Number of samples in the neighborhood of each frequency stimulation.
%   - f_stim: Array of frequencies for stimulation.
%   - num_harmonic: Number of harmonic frequencies for each stimulation frequency.
%
% Outputs:
%   - max_freq: Maximum frequency found using PSDA.
%   - label: Index of the stimulation frequency with maximum PSDA.
%% ================== Flowchart for the psda_a_trial function =========================
% Start
% Inputs: Sampling frequency (fs), EEG signal data (xi), number of samples in neighborhood 
% (num_sample_neigh),
%      stimulation frequencies (f_stim), number of harmonic frequencies (num_harmonic),
%      channel index (channel), trial index (trial)
% 1. Calculate the frequency range (f) based on the sampling frequency (fs)
% 2. Extract EEG signal data for the specified channel and trial
% 3. Calculate the step size for the frequency neighborhood (step)
% 4. Initialize arrays for PSDA values (psda) and legend (legen)
% 5. Initialize index variable (k)
% 6. Perform FFT on the input EEG signal data (xi)
% 7. Plot the PSD of the signal
% 8. Loop over each stimulation frequency (f_stim):
%    a. Loop over each harmonic frequency (num_harmonic):
%       i. Find the index of the stimulation frequency (indxfk)
%       ii. Find the indices of frequencies around each stimulation frequency (ind)
%       iii. Calculate PSDA
%       iv. Plot frequencies around each stimulation frequency
%       v. Generate legend
% 9. Set x-axis limit
% 10. Find the maximum frequency and its corresponding label
% 11. Create legend
% 12. Set title and axis labels
% Outputs: Maximum frequency (max_freq), Label (label)
% End
%% ====================================================================================
% Calculate frequency range
f = linspace(0, fs/2, floor(size(xi,1)/2)+1);
xi = xi(:, channel, trial);
% Calculate step size for frequency neighborhood
step = fs * (num_sample_neigh / 2) / size(xi, 1);

% Initialize arrays for PSDA and legend
psda = zeros(size(f_stim, 2), num_harmonic);
legen = cell(1, num_harmonic * length(f_stim));

% Initialize index variable
k = 0;

% Perform FFT on the input signal
x_fft = fft(xi, size(xi, 1));
x_fft = x_fft(1:floor(size(xi, 1) / 2) + 1);
psd = abs(x_fft).^2;

% Plot the PSD of the signal
figure()
plot(f(2:end), psd(2:end), 'linewidth', 1.5);

% Loop through each stimulation frequency 
for i = 1:size(f_stim, 2)
    % Loop through each harmonic frequency
    for j = 1:num_harmonic
        k = k + 1;
        % Find the index of the stimulation frequency
        indxfk = find((f >= j * f_stim(i) - 0.2) & (f <= j * f_stim(i) + 0.2));
        % Find the indices of frequencies around each stimulation frequency
        ind = find((f >= j * f_stim(i) - step) & (f <= j * f_stim(i) + step));
        % Calculate PSDA
        psda(i, j) = 10 * log10((num_sample_neigh * max(psd(indxfk))) / (sum(psd(ind)) ...
            - max(psd(indxfk))));
        % Plot the frequencies around each stimulation frequency
        hold on
        plot(f(ind), psd(ind), 'linewidth', 2.5)
        % Generate legend
        legen{k} = ['F_{stim}_' num2str(i) '_._H_' num2str(j) ':' num2str(f_stim(i) * j)];
    end
end

% Set x-axis limit
xlim([2 f(end)])

% Find the maximum frequency and its corresponding label
[max_freq, label] = max(max(psda, [], 2));

% Create legend
legend(['PSD', legen], 'FontSize', 8, 'FontWeight', 'bold', 'NumColumns', 2);

% Set title and axis labels
title(['PSDA; Trial: ' num2str(trial) '; Channel: ' num2str(trial)], 'FontSize', 10, ...
    'FontWeight', 'bold')
xlabel('F(Hz)', 'FontSize', 10, 'FontWeight', 'bold')
ylabel('PSD', 'FontSize', 10, 'FontWeight', 'bold')
end