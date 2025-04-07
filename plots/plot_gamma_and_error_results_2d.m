function plot_gamma_and_error_results_2d(results_struct, params, detector)
% Plot max PASAD detection values vs gamma for each noise_power level

    gamma_values = params.gamma_values;
    model_errors = params.model_error_values;
    field_names = fieldnames(results_struct);
    
    num_files = length(field_names);
    max_per_row = 5;

    % Determine subplot grid size
    rows = ceil(num_files / max_per_row);
    cols = min(max_per_row, num_files);

    figure;
    field_names = fieldnames(results_struct);
    for i = 1:num_files
        field = field_names{i};
        local_results = results_struct.(field); % Access results for current noise level
        if detector = "pasad"
            max_detector = arrayfun(@(r) max(r.pasad), local_results); % Max PASAD for each gamma
        else if detector = "cusum"
        subplot(rows, cols, i);
        plot(gamma_values, max_detector, '-o');
        xlabel('\gamma values');
        ylabel('max d');
        title(sprintf('Model Error: %i%',(1 - model_errors(i)) * 100));
        grid on;
    end

    sgtitle('Max PASAD Detection for Each Model Error');
end

