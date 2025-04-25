%% Main script for simulations with gamma and model error variation
addpath('utils');
addpath('plots');
addpath('simulink');

t_start = tic;

% Load simulation parameters
params = params();
total_iterations = numel(params.model_error_values) * length(params.gamma_values);
iteration_counter = 0;

% External variation: model_error
model_errors = params.model_error_values;
num_model_errors = length(model_errors);
num_gamma = length(params.gamma_values);

% === Train PASAD using gamma_ref_value = 0 and multiplicative model_error = 1 ===
params.gamma_ref_value = 0;
params.model_error = 1;

fprintf('Training PASAD with gamma_ref_value = 0 and multiplicative model_error = 1...\n');
[~, sensor_train, ~] = run_simulation(params);

% Apply moving average filter
sensor_train_filtered = filter(ones(1, params.window_size_filter) / params.window_size_filter, 1, sensor_train);

% Train PASAD
[U, utc, nev] = train_pasad(sensor_train_filtered, params);
fprintf('PASAD training completed.\n');

% === Prepare results struct ===
results_struct = struct();

for j = 1:num_model_errors
    params.model_error = model_errors(j);
    params = update_attack_model(params);
    local_results(num_gamma) = struct(...
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
        
        iteration_counter = iteration_counter + 1;
        if mod(iteration_counter, 10) == 0 || iteration_counter == 1
            fprintf('Running simulation %d of %d (model_error = %.0f%%, gamma = %.2f)...\n', ...
                iteration_counter, total_iterations, ...
                (params.model_error - 1) * 100, params.gamma_ref_value);
            fprintf('Elapsed time: %.2f seconds\n', toc(t_start));
        end

        [time, sensor, y_m] = run_simulation(params);
        sensor_filtered = filter(ones(1, params.window_size_filter) / params.window_size_filter, 1, sensor);

        local_results(i).gamma = params.gamma_ref_value;
        local_results(i).pasad = detect_pasad(sensor_filtered, params, U, utc, nev);
        [local_results(i).cusum_pos, local_results(i).cusum_neg] = detect_cusum(sensor_filtered, params);
        local_results(i).sensor = sensor_filtered;
        local_results(i).sensor_unfiltered = sensor;
        local_results(i).time = time;
        local_results(i).y_m = y_m;
    end
    error_str = sprintf('%.4f', params.model_error_values(j));  % ou use round
    field_name = matlab.lang.makeValidName(['model_error_' error_str]);
    results_struct.(field_name) = local_results;
end

% Optional: Save results
save('results_model_error.mat', 'results_struct', 'model_errors', '-v7.3');
fprintf('Total elapsed time: %.2f seconds\n', toc(t_start));

%% Visualization
addpath('utils');
addpath('plots');
addpath('utils');
addpath('plots');
params = params();

load('results_model_error.mat');

plot_heatmap(results_struct, model_errors, "pasad", "model_error", params);
plot_heatmap(results_struct, model_errors, "cusum", "model_error", params);
