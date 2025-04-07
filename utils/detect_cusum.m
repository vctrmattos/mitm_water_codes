function [cusum_pos, cusum_neg] = detect_cusum(sensor, params)
% detectCUSUM Computes the positive and negative CUSUM statistics.
%
% Syntax:
%   [cusum_pos, cusum_neg] = detectCUSUM(sensor, params)
%
% Inputs:
%   sensor - Vector containing sensor measurements.
%   params - Structure with necessary parameters, including:
%       N : Number of initial samples used for baseline calculation.
%       k : Threshold parameter (default: 0.3 * std(baseline)).
%
% Outputs:
%   cusum_pos - Vector of positive CUSUM statistics.
%   cusum_neg - Vector of negative CUSUM statistics.

N = params.N; %Training duration
k_factor = params.cusum_threshold_factor;

% Compute initial parameters
baseline = sensor(1:N);
mu0 = mean(baseline);
sigma0 = std(baseline);
k = k_factor * sigma0;

% Extract sensor data after the baseline period
s_det = sensor(N+1:end);
nDet = length(s_det);

% Initialize output vectors
cusum_pos = zeros(nDet, 1);
cusum_neg = zeros(nDet, 1);

% Compute CUSUM statistics
for t = 1:nDet
    x_t = s_det(t);
    if t == 1
        cusum_pos(t) = max(0, (x_t - mu0 - k));
        cusum_neg(t) = min(0, (x_t - mu0 + k));
    else
        cusum_pos(t) = max(0, cusum_pos(t-1) + (x_t - mu0 - k));
        cusum_neg(t) = min(0, cusum_neg(t-1) + (x_t - mu0 + k));
    end
end

end
