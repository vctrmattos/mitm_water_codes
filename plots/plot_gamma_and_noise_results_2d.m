function plot_gamma_and_noise_results_2d(results, params)
% Plot max PASAD detection values vs gamma for each noise_power level

    gamma_values = params.gamma_values;
    noise_powers = params.noise_power_values;

    num_files = length(results);
    max_per_row = 5;

    % Determine subplot grid size
    rows = ceil(num_files / max_per_row);
    cols = min(max_per_row, num_files);

    figure;
    for i = 1:num_files
        local_results = results{i}; % Access results for current noise level
        max_pasad = arrayfun(@(r) max(r.pasad), local_results); % Max PASAD for each gamma

        subplot(rows, cols, i);
        plot(gamma_values, max_pasad, '-o');
        xlabel('\gamma values');
        ylabel('max d');
        title(sprintf('Noise: %.2e', noise_powers(i)));
        grid on;
    end

    sgtitle('Max PASAD Detection for Each Noise Power');
end

