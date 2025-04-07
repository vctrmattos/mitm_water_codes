%% Main script for running simulations with attacks and detection
addpath('utils'); 
addpath('plots'); 

% Load simulation parameters
params = params();
num_sim = length(params.gamma_values);

% === Train PASAD using gamma_ref_value = 0 ===
params.gamma_ref_value = 0;

fprintf('Running training simulation with gamma_ref_value = 0...\n');
[~, sensor_train, ~] = run_simulation(params);

% Apply moving average filter
sensor_train_filtered = filter(ones(1, params.window_size_filter) / params.window_size_filter, 1, sensor_train);

% Train PASAD
[U, utc, nev] = train_pasad(sensor_train_filtered, params);
fprintf('PASAD training completed.\n');

% === Preallocate results struct ===
results(num_sim) = struct(...
    'gamma', [], ...
    'pasad', [], ...
    'sensor', [], ...
    'time', [], ...
    'cusum_pos', [], ...
    'cusum_neg', [], ...
    'sensor_unfiltered', [], ...
    'y_m', []);

% === Run simulations ===
for idx = 1:num_sim
    params.gamma_ref_value = params.gamma_values(idx);
    fprintf('Running simulation %d/%d, gamma_ref_value = %.2f\n', idx, num_sim, params.gamma_ref_value);

    % Run simulation
    [time, sensor, y_m] = run_simulation(params);

    % Apply filter
    sensor_filtered = filter(ones(1, params.window_size_filter) / params.window_size_filter, 1, sensor);

    % Run PASAD detection using trained parameters
    pasad_results = detect_pasad(sensor_filtered, params, U, utc, nev);

    % Run CUSUM detection
    [cusum_pos, cusum_neg] = detect_cusum(sensor_filtered, params);

    % Store results
    results(idx).gamma = params.gamma_ref_value;
    results(idx).pasad = pasad_results;
    results(idx).sensor = sensor_filtered;
    results(idx).sensor_unfiltered = sensor;
    results(idx).time = time;
    results(idx).cusum_pos = cusum_pos;
    results(idx).cusum_neg = cusum_neg;
    results(idx).y_m = y_m;
end

%% Detection threshold optimization
epsilon = 1e-9;
optimal_thresholds.pasad = calc_threshold(results, 'pasad', epsilon);
optimal_thresholds.cusum_pos = calc_threshold(results, 'cusum_pos', epsilon);
optimal_thresholds.cusum_neg = calc_threshold(results, 'cusum_neg', epsilon);
optimal_thresholds_cusum = [optimal_thresholds.cusum_pos optimal_thresholds.cusum_neg];
% === Performance evaluation ===
conf_matrix_pasad = compute_metrics(results, optimal_thresholds.pasad, 'pasad');
conf_matrix_cusum = compute_metrics(results, optimal_thresholds_cusum, 'cusum');

%% Visualization
figure;
confusionchart(conf_matrix_pasad, {'Ataque', 'Sem Ataque'}, 'Title', 'Matriz de Confusão - PASAD');
figure;
confusionchart(conf_matrix_cusum, {'Ataque', 'Sem Ataque'}, 'Title', 'Matriz de Confusão - CUSUM');

plot_max_detector(results, 'pasad', optimal_thresholds.pasad, params);
plot_max_detector(results, 'cusum_pos', optimal_thresholds.cusum_pos, params);
plot_max_detector(results, 'cusum_neg', optimal_thresholds.cusum_neg, params);
%         plot_gamma_and_error_results_2d(results, params);
