function result = simulate_and_detect(params, U, utc, nev)
    [time, sensor, y_m] = run_simulation(params);
    sensor_filtered = filter(ones(1, params.window_size_filter) / params.window_size_filter, 1, sensor);

    result.gamma = params.gamma_ref_value;  % <-- adicionado
    result.pasad = detect_pasad(sensor_filtered, params, U, utc, nev);
    [result.cusum_pos, result.cusum_neg] = detect_cusum(sensor_filtered, params);

    result.sensor = sensor_filtered;
    result.sensor_unfiltered = sensor;
    result.time = time;
    result.y_m = y_m;
end
