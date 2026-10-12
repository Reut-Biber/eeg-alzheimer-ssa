% CONFIG  Shared settings for the 4-month and 6-month analyses.
% Edit DATA_ROOT to point to your local copy of the recordings
% (the raw EEG data is not included in this repository).

DATA_ROOT    = 'path/to/mice_data';  % folder containing the CSV recordings
FS           = 1014;                 % sampling frequency [Hz]
SEGMENT_SEC  = 6.0;                  % segment length used for averaging [s]
DO_NORMALIZE = false;                % z-score each channel before averaging

BAND         = 'gamma low';          % 'delta','theta','alpha','beta',
                                     % 'gamma low','gamma mid','gamma high'
FIR_ORDER    = 500;                  % band-pass FIR filter order
SSA_WINDOW   = 30;                   % SSA window length M (embedding dimension)
SSA_ELEMENTS = 2;                    % number of RCs in the partial reconstruction
CHANNEL      = 1;                    % EEG channel to analyze (1-4)
