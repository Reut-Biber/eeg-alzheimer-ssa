function [rc_lab, rc_wild] = analyze_band(lab_sig, wild_sig, band, fs, M, fir_order, n_rc, channel)
%ANALYZE_BAND  Band-pass filter one EEG channel and decompose it with SSA.
%   [rc_lab, rc_wild] = analyze_band(lab_sig, wild_sig, band, fs, M, fir_order, n_rc, channel)
%     lab_sig, wild_sig - [samples x 4] group-averaged signals (5xFAD, wild-type)
%     band              - EEG band name, see band_limits
%     M                 - SSA window length
%     n_rc              - number of RCs used in the partial reconstruction plot
%     channel           - channel to analyze (default 1)
%   Returns the SSA reconstructed components (RCs) of both groups and plots
%   spectra, lag-covariance matrices and reconstructions.

    if nargin < 8
        channel = 1;
    end

    [fmin, fmax] = band_limits(band);
    N = size(lab_sig, 1);
    t = (0:N - 1)' / fs;          % time axis [s]
    f = (0:N - 1)' * fs / N;      % frequency axis [Hz]

    x_lab  = lab_sig(:, channel);
    x_wild = wild_sig(:, channel);
    lab  = bandpass_filter(x_lab,  fmin, fmax, fs, fir_order);
    wild = bandpass_filter(x_wild, fmin, fmax, fs, fir_order);

    plot_spectra(t, f, x_lab, x_wild, lab, wild, fmin, fmax, band);

    [rc_lab,  pct_lab,  C_lab]  = ssa_decompose(lab,  M, N);
    [rc_wild, pct_wild, C_wild] = ssa_decompose(wild, M, N);
    fprintf('Variance captured by RC 1-4 (%s):\n', band);
    fprintf('  5xFAD:     %s %%\n', mat2str(pct_lab(1:4)',  4));
    fprintf('  wild-type: %s %%\n', mat2str(pct_wild(1:4)', 4));

    plot_covariance(C_lab, C_wild);
    plot_components(t, rc_lab, rc_wild, band);
    plot_reconstruction(t, lab, wild, rc_lab, rc_wild, n_rc, band);
    plot_zoom(t, rc_lab, rc_wild, fmin, fmax, channel);
end


function plot_spectra(t, f, x_lab, x_wild, lab, wild, fmin, fmax, band)
    figure('Name', ['Signals and spectra - ' band]);

    subplot(2, 2, 1); hold on;
    plot(t, x_lab, 'b'); plot(t, x_wild, 'r');
    title('original signal'); xlabel('time (s)'); legend('5xFAD', 'wild');

    subplot(2, 2, 2); hold on;
    plot(f, abs(fft(x_lab)), 'b'); plot(f, abs(fft(x_wild)), 'r');
    xline(fmin, 'k--'); xline(fmax, 'k--'); xlim([0 100]);
    title('FFT of original signal'); xlabel('frequency (Hz)'); legend('5xFAD', 'wild');

    subplot(2, 2, 3); hold on;
    plot(t, lab, 'b'); plot(t, wild, 'r');
    title(['filtered - ' band]); xlabel('time (s)'); legend('5xFAD', 'wild');

    subplot(2, 2, 4); hold on;
    plot(f, abs(fft(lab)), 'b'); plot(f, abs(fft(wild)), 'r');
    xline(fmin, 'k--'); xline(fmax, 'k--'); xlim([0 100]);
    title(['FFT filtered - ' band]); xlabel('frequency (Hz)'); legend('5xFAD', 'wild');
end


function plot_covariance(C_lab, C_wild)
    % Show both matrices on the color scale of the larger one, so they are comparable
    c = sum(C_lab(:) .* C_wild(:)) / sum(C_wild(:).^2);   % best c in C_lab ~ c * C_wild
    if c > 1
        ref = C_lab;
    else
        ref = C_wild;
    end
    lims = [min(ref(:)) max(ref(:))];

    figure('Name', 'Lag-covariance matrices');
    subplot(1, 2, 1); imagesc(C_lab, lims);  axis image off; colormap(jet); colorbar;
    title('5xFAD covariance matrix');
    subplot(1, 2, 2); imagesc(C_wild, lims); axis image off; colormap(jet); colorbar;
    title('wild covariance matrix');

    % Scale wild-type to the 5xFAD peak and show the difference
    C_wild_scaled = C_wild * (max(C_lab(:)) / max(C_wild(:)));
    figure('Name', 'Lag-covariance difference');
    subplot(1, 3, 1); imagesc(C_lab);                 axis image off; colorbar;
    title('5xFAD');
    subplot(1, 3, 2); imagesc(C_wild_scaled);         axis image off; colorbar;
    title('wild, scaled to 5xFAD');
    subplot(1, 3, 3); imagesc(C_lab - C_wild_scaled); axis image off; colorbar;
    title('difference');
    colormap(jet);
end


function plot_components(t, rc_lab, rc_wild, band)
    figure('Name', ['Four strongest SSA components - ' band]);
    for m = 1:4
        subplot(4, 1, m); hold on;
        plot(t, rc_lab(:, m), 'b-');
        plot(t, rc_wild(:, m), 'r-');
        ylabel(sprintf('RC %d', m));
        xlabel('time (s)');
        legend('5xFAD', 'wild');
        if m == 1
            title(['4 strongest SSA components - ' band]);
        end
    end
end


function plot_reconstruction(t, lab, wild, rc_lab, rc_wild, n_rc, band)
    figure('Name', ['Signal vs. SSA reconstruction - ' band]);
    rows = {lab,  rc_lab,  '5xFAD'
            wild, rc_wild, 'wild'};
    for g = 1:2
        [x, rc, name] = rows{g, :};

        subplot(4, 1, 2 * g - 1);
        plot(t, x, 'b-', t, sum(rc, 2), 'r-');
        legend(['original ' band ' ' name], 'full reconstruction');
        xlabel('time (s)'); xlim([0 t(end)]);

        subplot(4, 1, 2 * g);
        plot(t, x, 'b-', t, sum(rc(:, 1:n_rc), 2), 'r-');
        legend(['original ' name], sprintf('reconstruction with %d RCs', n_rc));
        xlabel('time (s)'); xlim([0 t(end)]);
    end
end


function plot_zoom(t, rc_lab, rc_wild, fmin, fmax, channel)
    % Full signal, and a zoom of +-10 periods of the band's centre frequency around t = 3 s
    period = 1 / ((fmin + fmax) / 2);
    figure('Name', sprintf('Reconstructed signal - channel %d', channel));
    for k = 1:2
        subplot(2, 1, k);
        plot(t, sum(rc_lab, 2), 'b-', t, sum(rc_wild, 2), 'r-');
        legend('5xFAD', 'wild');
        xlabel('time (s)');
        title(sprintf('channel %d', channel));
    end
    xlim([3.0 - 10 * period, 3.0 + 10 * period]);
end
