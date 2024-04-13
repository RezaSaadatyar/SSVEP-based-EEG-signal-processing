function ps = psda(data, f_stim, num_sample_neigh, fs, num_harmonic)
% ================================== (2023-2024) ======================================
% ======================== Presented by: Reza Saadatyar ===============================
% ====================== E-mail: Reza.Saadatyar@outlook.com ===========================

% PSDA_ALL_TRIAL calculates the Power Spectral Density Amplitude (PSDA) for all trials.
% Inputs:
%   - x: EEG data matrix with dimensions (number of samples, number of channels).
%   - f_stim: Array of frequencies of stimulation.
%   - num_sample_neigh: Number of samples in the frequency neighborhood for each 
% stimulation frequency.
%   - fs: Sampling frequency.
%   - num_harmonic: Number of harmonics for each stimulation frequency.
% Output:
%   - psda: Array containing the maximum PSDA values for each stimulation frequency.
% Number of frequency neighborhood for each stimulation frequency
%% ===================== Flowchart for the psda function ==============================
% Start
% 1. Calculate the step size for the frequency neighborhood.
% 2. Generate the frequency axis up to the Nyquist frequency.
% 3. Initialize an array to store PSDA values.
% 4. Loop over each stimulation frequency:
%     a. Initialize a matrix to store PSD values for each channel.
%     b. Loop over each channel:
%         i. Extract data for the current channel.
%         ii. Perform Fourier transform on the channel data.
%         iii. Take the one-sided spectrum of the Fourier transform.
%         iv. Compute the power spectral density.
%         v. Loop over each harmonic:
%             A. Find the indices around the stimulation frequency.
%             B. Find the indices for the frequency neighborhood.
%             C. Compute the PSDA.
%     c. Store the maximum PSDA value for the current stimulation frequency.
% 5. Return the array containing the maximum PSDA values for each stimulation frequency.
% End
%% ====================================================================================
step = fs * (num_sample_neigh / 2) / size(data, 1);
f = linspace(0, fs / 2, floor(size(data, 1) / 2) + 1); % Frequency axis

ps = zeros(size(f_stim, 2), 1); % Initialize array to store PSDA values

for i = 1:size(f_stim, 2) % Loop over each stimulation frequency
    ps2 = zeros(size(data, 2), num_harmonic); % Initialize matrix to store PSD values for
    % each channel
    
    for j = 1:size(data, 2) % Loop over each channel
        xi = data(:, j); % Extract data for the current channel
        x_fft = fft(xi, size(xi, 1)); % Perform Fourier transform
        x_fft = x_fft(1:floor(size(xi, 1) / 2) + 1); % Take one-sided spectrum
        psd = abs(x_fft).^2; % Compute power spectral density
        
        for q = 1:num_harmonic % Loop over each harmonic
            % Find indices around stimulation frequency
            ind_fk = find((f >= q * f_stim(i) - 0.2) & (f <= q * f_stim(i) + 0.2)); 
            % Find indices for frequency neighborhood
            ind_h = find((f >= q * f_stim(i) - step) & (f <= q * f_stim(i) + step)); 
            ps1(j, q) = 10 * log10((num_sample_neigh * max(psd(ind_fk))) / (sum(psd(ind_h)) ...
                - max(psd(ind_fk)))); % Compute PSDA
        end
    end
    % Store maximum PSDA value for the current stimulation frequency
    ps(i) = max(max(ps1, [], 2)); 
end
end