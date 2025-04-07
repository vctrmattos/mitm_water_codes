%% Main script for running simulations with attacks and detection (gamma vs noise_power)
addpath('utils'); 
addpath('plots'); 

% Load simulation parameters
params = params();
num_gamma = length(params.gamma_values);
noise_powers = params.noise_power_values;
num_noise = length(noise_powers);

% === Train PASAD using gamma_ref_value = 0 ===
params.gamma_ref_value = 0;
params.noise_power = 1e-9; % Nominal value for training

fprintf('Training PASAD with gamma_ref_value = 0...\n');
[~, sensor_train, ~] = run_simulation(params);

% Apply moving average filter
sensor_train_filtered = filter(ones(1, params.window_size_filter) / params.window_size_filter, 1, sensor_train);
[U, utc, nev] = train_pasad(sensor_train_filtered, params);
fprintf('PASAD training completed.\n');

% === Simulations ===
results_struct = struct();

for j = 1:num_noise
    params.noise_power = noise_powers(j);
    noise_key = matlab.lang.makeValidName(sprintf('noise_%.0e', params.noise_power));

    local_results(num_gamma) = struct(...
        'gamma', [], ...
        'pasad', [], ...
        'sensor', [], ...
        'time', [], ...
        'cusum_pos', [], ...
        'cusum_neg', [], ...
        'sensor_unfiltered', [], ...
        'y_m', [], ...
        'noise_power', []);

    for i = 1:num_gamma
        params.gamma_ref_value = params.gamma_values(i);
        fprintf('Simulation %d/%d | noise_power = %.2e | gamma = %.2f\n', ...
                i, num_gamma, params.noise_power, params.gamma_ref_value);

        [time, sensor, y_m] = run_simulation(params);
        sensor_filtered = filter(ones(1, params.window_size_filter) / params.window_size_filter, 1, sensor);

        local_results(i).gamma = params.gamma_ref_value;
        local_results(i).pasad = detect_pasad(sensor_filtered, params, U, utc, nev);
        [local_results(i).cusum_pos, local_results(i).cusum_neg] = detect_cusum(sensor_filtered, params);
        local_results(i).sensor = sensor_filtered;
        local_results(i).sensor_unfiltered = sensor;
        local_results(i).time = time;
        local_results(i).y_m = y_m;
        local_results(i).noise_power = params.noise_power;
    end

    results_struct.(noise_key) = local_results;
end

% Save results if needed
save('results_noise.mat', 'results_struct');

%% Visualization
addpath('utils'); 
addpath('plots'); 

load("results_noise.mat")
params();
plot_heatmap(results_struct, noise_powers, "pasad", "noise_power", params);
plot_heatmap(results_struct, noise_powers, "cusum", "noise_power", params);

plot_confusion_metrics(results_struct, noise_powers, 'pasad', 'noise_power');
plot_confusion_metrics(results_struct, noise_powers, 'cusum', 'noise_power');
