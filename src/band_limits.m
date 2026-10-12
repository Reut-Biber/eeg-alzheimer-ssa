function [fmin, fmax] = band_limits(band)
%BAND_LIMITS  Frequency limits [Hz] of the standard EEG bands.
    switch lower(band)
        case 'delta',      fmin = 0.5; fmax = 4;
        case 'theta',      fmin = 4;   fmax = 8;
        case 'alpha',      fmin = 8;   fmax = 13;
        case 'beta',       fmin = 13;  fmax = 30;
        case 'gamma low',  fmin = 30;  fmax = 44;
        case 'gamma mid',  fmin = 44;  fmax = 60;
        case 'gamma high', fmin = 60;  fmax = 100;
        otherwise
            error('Unknown band "%s".', band);
    end
end
