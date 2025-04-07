function params = update_attack_model(params)
    s = params.s;
    me = params.model_error;

    params.plant_model_attacker = 0.93 * me / ((1.07 * me * s + 1) * (0.34 * me * s + 1)) * exp(-0.45 * s);
    params.plant_model_no_delay_attacker = (0.62 / 0.64) * me / (s / 0.64 * me + 1);
end
