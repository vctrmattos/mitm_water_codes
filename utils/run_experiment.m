function results = run_experiment(params, vary_noise, vary_model_error)
    num_sim = length([params.gamma_values]);
    
    % Ajustar número total de simulações
    if vary_noise && vary_model_error
        num_sim = num_sim * length([params.noise_power_values]) * length([params.model_error_values]);
    elseif vary_noise
        num_sim = num_sim * length([params.noise_power_values]);
    elseif vary_model_error
        num_sim = num_sim * length([params.model_error_values]);
    end
    
    % Prealocar estrutura de resultados
    results(num_sim) = struct(... 
        'gamma', [], 'pasad', [], 'sensor', [], 'time', [], ...
        'cusum_pos', [], 'cusum_neg', [], 'sensor_unfiltered', [], 'y_m', []);
    
    sim_idx = 1; % Índice para armazenar os resultados
    
    for i = 1:length([params.gamma_values])
        params.gamma_ref_value = params.gamma_values(i);
        
        % Definir faixa de valores de noise_power e model_error
        noise_range = params.noise_power_values;
        model_error_range = params.model_error_values;
        
        if ~vary_noise
            noise_range = params.noise_power; % Mantém fixo
        end
        
        if ~vary_model_error
            model_error_range = params.model_error; % Mantém fixo
        end
        
        for j = 1:length(noise_range)
            params.noise_power = noise_range(j);
            
            for k = 1:length(model_error_range)
                params.model_error = model_error_range(k);
                
                fprintf('Running simulation %d/%d, gamma = %.2f, noise = %.2f, model_error = %.2f\n', ...
                    sim_idx, num_sim, params.gamma_ref_value, params.noise_power, params.model_error);
                
                % Rodar simulação
                [time, sensor, y_m] = run_simulation(params);
                
                % Aplicar filtro
                sensor_filtered = filter(ones(1, params.window_size_filter) / params.window_size_filter, 1, sensor);
                
                % Inicializar PASAD na primeira execução
                if sim_idx == 1
                    [U, utc, nev] = train_pasad(sensor_filtered, params);
                end
                
                % Executar detecção
                pasad_results = detect_pasad(sensor_filtered, params, U, utc, nev);
                [cusum_pos, cusum_neg] = detect_cusum(sensor_filtered, params);
                
                % Armazenar resultados
                results(sim_idx).gamma = params.gamma_ref_value;
                results(sim_idx).pasad = pasad_results;
                results(sim_idx).sensor = sensor_filtered;
                results(sim_idx).sensor_unfiltered = sensor;
                results(sim_idx).time = time;
                results(sim_idx).cusum_pos = cusum_pos;
                results(sim_idx).cusum_neg = cusum_neg;
                results(sim_idx).y_m = y_m;
                
                sim_idx = sim_idx + 1;
            end
        end
    end
end
