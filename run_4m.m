% RUN_4M  Analysis of the 4-month recordings (5xFAD vs. wild-type).
% Saves the SSA reconstructed components to results_4m.mat.

config;
addpath('src');

data_dir = DATA_ROOT;   % 4-month recordings are stored in per-mouse sub-folders

lab_files = {               % 5xFAD mice
    'mouse12/mouse 12.csv'
    'mouse13/mouse_13.csv'
    'mouse14/mouse 14.csv'
    'mouse15/mouse 15.csv'
    'mouse16/mouse16.csv'
    'mouse17/mouse17.csv'
    'mouse18/mouse18.csv'
};

wild_files = {              % wild-type mice
    'pere 1/pere1.csv'
    'pere 2/pere2.csv'
    'pere 6/pere6.csv'
    'pere 7/pere7.csv'
    'pere 9/pere9.csv'
    'pere 10/pere10.csv'
    'pere 11/pere11.csv'
};

[lab_sig, wild_sig] = prepare_average_data(FS, SEGMENT_SEC, data_dir, ...
    lab_files, wild_files, DO_NORMALIZE, '4m', 'averaged_data_4m.mat');

[rc_lab_4m, rc_wild_4m] = analyze_band(lab_sig, wild_sig, BAND, FS, ...
    SSA_WINDOW, FIR_ORDER, SSA_ELEMENTS, CHANNEL);

save('results_4m.mat', 'rc_lab_4m', 'rc_wild_4m', 'BAND');
