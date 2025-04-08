function pasad = detect_pasad(sensor, params, U, utc, nev)
% detectPASAD Executes the PASAD detection phase.

% Code adapted from https://github.com/mikeliturbe/pasad
%Wissam Aoudi, Mikel Iturbe, and Magnus Almgren. 2018. Truth Will Out: 
% Departure-Based Process-Level Detection of Stealthy Attacks on Control Systems. 
% In Proceedings of the 2018 ACM SIGSAC Conference on Computer and Communications Security (CCS '18). ACM, New York, NY, USA, 817-831. 
% DOI: https://doi.org/10.1145/3243734.3243781

% Syntax:
%   pasad = detectPASAD(sensor, params, L, U, utc, nev)
%
% Inputs:
%   sensor - Vector containing sensor measurements.
%   params - Structure with necessary parameters, including:
%       N : Number of samples used in the training phase.
%   U, utc, nev - Outputs obtained from the trainPASAD function.
%
% Output:
%   pasad - Vector containing PASAD anomaly scores.
    
% Total number of samples
T = length(sensor);
% Number of samples used in training
N = params.N;
L = params.L;

% Number of samples for detection
numDet = T - N;
pasad = zeros(numDet, 1);

% Initialize x with the last L training samples
x = sensor(N-L+1:N);

    % Detection loop
    for j = N+1:T
        % Update x: left shift and insert the new sample at the last position
        x = [x(2:end); sensor(j)];
        
        % Compute projection error
        y = utc - U' * x;
        % Normalize using nev (element-wise multiplication)
        y = nev .* y;
        % Store PASAD anomaly score (quadratic norm)
        pasad(j-N) = y' * y;
    end
end
