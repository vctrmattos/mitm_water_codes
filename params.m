function params = params()
    %% Parameter Struct

    % Seed for reproducibility
    params.seed = 42;

    % System Definition
    s = tf('s');
    params.s = s;

    % Plant Models
    params.nominal_plant = 0.93 / ((1.07 * s + 1) * (0.34 * s + 1)) * exp(-0.45 * s);
    params.plant_model_no_delay = (0.62 / 0.64) / (s / 0.64 + 1);

    % Attacker's Model
    params.model_error = 0.9;
    params.plant_model_attacker = 0.93 * params.model_error / ((1.07 * params.model_error * s + 1) * (0.34 * params.model_error * s + 1)) * exp(-0.45 * s);
    params.plant_model_no_delay_attacker = (0.62 / 0.64) * params.model_error / (s / 0.64 * params.model_error + 1);

    % Noise
    params.noise_power = 10^-9;

    % Controllers
    params.Kp = 1.69; 
    params.Ti = 1.41; 
    params.Td = 0.26; 
    params.N_ctr = 1000;
    params.covert_controller = pidstd(params.Kp, params.Ti, params.Td, params.N_ctr);
    params.nominal_controller = pidstd(params.Kp, params.Ti, params.Td, params.N_ctr);

    % Reference Signal
    params.Ts = 0.1;
    params.y_ref_start = 0;
    params.y_ref_value = 0.5;

    % Attacker Parameters
    params.gamma_ref_start = 200;
    params.transient_time = 10;

    % PASAD Parameters
    params.detection_start = 100;
    params.N = params.detection_start / params.Ts; 
    params.L = params.N / 2; % Lag
    params.r = 26; % Statistical dimension

    % CUSUM Parameters
    params.cusum_threshold_factor = 0.3;  % Multiplier for sigma0

    % Filtering
    params.window_size_filter = 10;

    % Gamma Values (Attack Magnitudes)
    % params.gamma_values = -0.5:0.1:0.5;
    params.gamma_values = linspace(-0.5, 0.5, 11);
    
    params.noise_power_values = logspace(log10(1e-9) - 2, log10(1e-9) + 2, 101);
    params.model_error_values = linspace(0.9, 1.1, 101);

    % Simulation Time
    params.sim_time = 610;
end
