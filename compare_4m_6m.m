% COMPARE_4M_6M  How similar is each group's signal at 4 vs. 6 months?
% Cross-correlates the leading SSA component (RC 1) of the 6-month signal
% with that of the 4-month signal, separately for each group.
% Run run_4m.m and run_6m.m first.

r4 = load('results_4m.mat');
r6 = load('results_6m.mat');
if ~strcmp(r4.BAND, r6.BAND)
    warning('4m results use "%s" but 6m results use "%s" - rerun with the same BAND.', ...
        r4.BAND, r6.BAND);
end

lab_4m  = r4.rc_lab_4m(:, 1);   lab_6m  = r6.rc_lab_6m(:, 1);
wild_4m = r4.rc_wild_4m(:, 1);  wild_6m = r6.rc_wild_6m(:, 1);

% Raw cross-correlation and its mean squared value (score used in the project)
[c_lab,  lags_lab]  = xcorr(lab_6m,  lab_4m);
[c_wild, lags_wild] = xcorr(wild_6m, wild_4m);
score_lab  = mean(c_lab.^2);
score_wild = mean(c_wild.^2);

% Amplitude-independent check: peak of the normalized cross-correlation (0..1)
peak_lab  = max(abs(xcorr(lab_6m,  lab_4m,  'coeff')));
peak_wild = max(abs(xcorr(wild_6m, wild_4m, 'coeff')));

fprintf('Band: %s\n', r6.BAND);
fprintf('5xFAD:     mean |c|^2 = %.4g, normalized peak = %.3f\n', score_lab,  peak_lab);
fprintf('Wild-type: mean |c|^2 = %.4g, normalized peak = %.3f\n', score_wild, peak_wild);

figure('Name', 'Cross-correlation 4m vs. 6m');
subplot(2, 1, 1);
plot(lags_lab, c_lab);
title(sprintf('5xFAD mice: 6m vs. 4m, mean |c|^2 = %.4g', score_lab));
xlabel('lag (samples)');
subplot(2, 1, 2);
plot(lags_wild, c_wild);
title(sprintf('Wild-type mice: 6m vs. 4m, mean |c|^2 = %.4g', score_wild));
xlabel('lag (samples)');
