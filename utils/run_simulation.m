function [time, sensor, y_m] = run_simulation(params)
    %% Run Simulink Simulation
    simOut = sim('simulink/smith_water_cr', 'StopTime', num2str(params.sim_time));

    %% Process Simulation Output Data
    % Extract simulation time
    time = simOut.y_ma.time;

    % Filter time to remove initial transient period
    time_filter = time > params.transient_time;
    time = time(time_filter) - params.transient_time; % Adjusted time axis

    % Extract sensor measurement data after transient time
    sensor = simOut.y_ma.data(time_filter);
    y_m = simOut.y_ma.data(time_filter); % Same as sensor, but can be used separately if needed
end
