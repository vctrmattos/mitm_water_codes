%% Main script for simulations with gamma variation
addpath('utils');
addpath('plots');
addpath('simulink');

t_start = tic;

% Load simulation parameters
params = params();
num_gamma = length(params.gamma_values);
total_iterations = num_gamma;

% Fix model_error
params.model_error = 1.1;

% === Train PASAD using gamma_ref_value = 0 ===
params.gamma_ref_value = 0;

fprintf('Training PASAD with gamma_ref_value = 0...\n');
[~, sensor_train, ~] = run_simulation(params);

% Apply moving average filter
sensor_train_filtered = filter(ones(1, params.window_size_filter) / params.window_size_filter, 1, sensor_train);

% Train PASAD
[U, utc, nev] = train_pasad(sensor_train_filtered, params);
fprintf('PASAD training completed.\n');

% === Prepare results struct ===
results(num_gamma) = struct( ...
    'gamma', [], ...
    'pasad', [], ...
    'sensor', [], ...
    'time', [], ...
    'cusum_pos', [], ...
    'cusum_neg', [], ...
    'sensor_unfiltered', [], ...
    'y_m', []);

for i = 1:num_gamma
    params.gamma_ref_value = params.gamma_values(i);

    if mod(i, 5) == 0 || i == 1
        fprintf('Running simulation %d of %d (gamma = %.2f)...\n', ...
            i, total_iterations, params.gamma_ref_value);
        fprintf('Elapsed time: %.2f seconds\n', toc(t_start));
    end

    [time, sensor, y_m] = run_simulation(params);
    sensor_filtered = filter(ones(1, params.window_size_filter) / params.window_size_filter, 1, sensor);
    
    % Run detection methods
    pasad_results = detect_pasad(sensor_filtered, params, U, utc, nev);
    [cusum_pos, cusum_neg] = detect_cusum(sensor_filtered, params);

    results(i).gamma = params.gamma_ref_value;
    results(i).pasad = pasad_results;
    results(i).sensor = sensor_filtered;
    results(i).sensor_unfiltered = sensor;
    results(i).time = time;
    results(i).cusum_pos = cusum_pos;
    results(i).cusum_neg = cusum_neg;
    results(i).y_m = y_m;
end

% Optional: Save results
save('results_gamma.mat', 'results_struct');

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