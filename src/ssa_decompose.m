function [RC, eig_pct, C] = ssa_decompose(x, M, N)
%SSA_DECOMPOSE  Singular Spectrum Analysis (SSA) of a 1-D signal.
%   [RC, eig_pct, C] = ssa_decompose(x, M, N)
%     x       - signal (column vector, N samples)
%     M       - window length (embedding dimension)
%     RC      - [N x M] reconstructed components, strongest first
%     eig_pct - percentage of the variance captured by each component
%     C       - [M x M] lag-covariance matrix of the trajectory matrix

    K = N - M + 1;

    % trajectory (embedding) matrix: each column is the signal shifted by one sample
    Y = zeros(K, M);
    for m = 1:M
        Y(:, m) = x((1:K) + m - 1);
    end
    C = (Y' * Y) / K;

    % eigen-decomposition, sorted by descending eigenvalue
    [V, D] = eig(C);
    [lambda, idx] = sort(diag(D), 'descend');
    V = V(:, idx);
    eig_pct = 100 * lambda / sum(lambda);

    % principal components, then reconstruction by anti-diagonal averaging
    PC = Y * V;
    RC = zeros(N, M);
    for m = 1:M
        buf = flipud(PC(:, m) * V(:, m)');
        for n = 1:N
            RC(n, m) = mean(diag(buf, n - K));
        end
    end
end
