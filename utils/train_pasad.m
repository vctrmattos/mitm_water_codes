function [U, utc, nev] = train_pasad(sensor, params)
% trainPASAD Performs the training phase of the PASAD detector.

% Code adapted from https://github.com/mikeliturbe/pasad
%Wissam Aoudi, Mikel Iturbe, and Magnus Almgren. 2018. Truth Will Out: 
% Departure-Based Process-Level Detection of Stealthy Attacks on Control Systems. 
% In Proceedings of the 2018 ACM SIGSAC Conference on Computer and Communications Security (CCS '18). ACM, New York, NY, USA, 817-831. 
% DOI: https://doi.org/10.1145/3243734.3243781

% Syntax:
%   [U, utc, nev] = trainPASAD(sensor, params)
%
% Inputs:
%   sensor - Vector containing sensor measurements.
%   params - Structure with necessary parameters, including:
%       N : Number of samples used for constructing the Hankel matrix.
%   L - Number of rows in the Hankel matrix.
%   r - Number of eigenvectors to retain (statistical dimension).
%
% Outputs:
%   U   - Selected eigenvectors matrix (L x r).
%   utc - Projected mean vector: U' * c, where c is the mean of X columns.
%   nev - Normalization vector based on selected eigenvalues.

N = params.N;
L = params.L;
r = params.r;

% Construct Hankel matrix
X = hankel(sensor(1:L), sensor(L:N));

% Singular Value Decomposition (SVD)
[U_svd, S, ~] = svd(X, 'econ');
ev = diag(S);

% Select the first r eigenvectors
U = U_svd(:, 1:r);

% Compute column mean of X
c = mean(X, 2);

% Project the mean onto the subspace of eigenvectors
utc = U' * c;

% Normalization vector based on eigenvalue proportions
nev = sqrt(ev(1:r) ./ sum(ev(1:r)));

end
