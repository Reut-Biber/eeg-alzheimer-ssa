% RUN_6M  Analysis of the 6-month recordings (5xFAD vs. wild-type).
% Saves the SSA reconstructed components to results_6m.mat.

config;
addpath('src');

data_dir = fullfile(DATA_ROOT, '6_month');

lab_files = {               % 5xFAD mice (e15.csv excluded)
    'e12.csv'
    'e13.csv'
    'e14.csv'
};

wild_files = {              % wild-type mice (w6s.csv excluded)
    'w1s.csv'
    'w2s.csv'
    'w9s.csv'
    'w10s.csv'
    'w11s.csv'
};

[lab_sig, wild_sig] = prepare_average_data(FS, SEGMENT_SEC, data_dir, ...
    lab_files, wild_files, DO_NORMALIZE, '6m', 'averaged_data_6m.mat');

[rc_lab_6m, rc_wild_6m] = analyze_band(lab_sig, wild_sig, BAND, FS, ...
    SSA_WINDOW, FIR_ORDER, SSA_ELEMENTS, CHANNEL);

save('results_6m.mat', 'rc_lab_6m', 'rc_wild_6m', 'BAND');
