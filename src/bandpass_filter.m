function y = bandpass_filter(x, fmin, fmax, fs, order)
%BANDPASS_FILTER  FIR band-pass filter designed with a Hamming window.
%   y = bandpass_filter(x, fmin, fmax, fs, order) keeps frequencies between
%   fmin and fmax [Hz]. The filter is causal (filter), so the output is
%   delayed by order/2 samples.
    b = fir1(order, [fmin fmax] / (fs / 2), 'bandpass', hamming(order + 1));
    y = filter(b, 1, x);
end
