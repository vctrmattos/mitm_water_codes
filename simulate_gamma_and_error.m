%% Main script for simulations with gamma and model error variation
addpath('utils');
addpath('plots');

% Load simulation parameters
params = params();

% External variation: model_error
model_errors = params.model_error_values;
num_model_errors = length(model_errors);
num_gamma = length(params.gamma_values);

% === Train PASAD using gamma_ref_value = 0 and model_error = 0 ===
params.gamma_ref_value = 0;
params.model_error = 0;

fprintf('Training PASAD with gamma_ref_value = 0 and model_error = 0...\n');
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
        fprintf('Simulation %d/%d | model_error = %.2f | gamma = %.2f\n', ...
                i, num_gamma, (params.model_error - 1)*100, params.gamma_ref_value);

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
save('results_model_error.mat', 'results_struct', 'model_errors');

%% Visualization
params = params();
load('results_model_error.mat');
% plot_gamma_and_error_results_2d(results_struct, params);
% plot_heatmap_model_error(results_struct, model_errors, "pasad");
% plot_heatmap_model_error(results_struct, model_errors, "cusum");
plot_confusion_metrics(results_struct, model_errors, "pasad");
plot_confusion_metrics(results_struct, model_errors, "cusum");
