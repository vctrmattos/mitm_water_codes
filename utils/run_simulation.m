function [time, sensor, y_m] = run_simulation(params)
    %% Load model and set simulation mode
    model_name = 'smith_water_cr';
    load_system(model_name);
    set_param(model_name, 'SimulationMode', 'normal'); 

    %% Run simulation
    simOut = sim(model_name, 'StopTime', num2str(params.sim_time));

    %% Process simulation output
    time = simOut.y_ma.time;
    time_filter = time > params.transient_time;
    time = time(time_filter) - params.transient_time;
    sensor = simOut.y_ma.data(time_filter);
    y_m = simOut.y_m.data(time_filter);
end
