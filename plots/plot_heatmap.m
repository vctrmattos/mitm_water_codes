function plot_heatmap(results_struct, x_values, detector, x_label, params)
% Plot heatmap of max detector values (PASAD or CUSUM) vs gamma and a variable (e.g., model error or noise)

    field_names = fieldnames(results_struct);
    num_x = length(field_names);

    % Assume gamma_values são consistentes em todos os campos
    sample = results_struct.(field_names{1});
    gamma_values = [sample.gamma];
    num_gamma = length(gamma_values);

    all_max_d = zeros(num_x, num_gamma);

    for i = 1:num_x
        key = field_names{i};
        local_results = results_struct.(key);

        for j = 1:num_gamma
            switch detector
                case "pasad"
                    all_max_d(i, j) = max(local_results(j).pasad);
                case "cusum"
                    all_max_d(i, j) = abs(max(local_results(j).cusum_pos)) + abs(max(local_results(j).cusum_neg));
                otherwise
                    error("Unknown detector type: %s", detector);
            end
        end
    end

    %% === Heatmap ===
    figure;
    
    % Ajuste opcional do eixo X (percentual se model_error, log10 se noise)
    if contains(lower(x_label), 'model')
        x_ticks = (x_values - 1) * 100;
        x_label_str = 'Multiplicative Model Error (%)';
    elseif contains(lower(x_label), 'noise')
        x_ticks = log10(x_values); % ou: x_values para escala real
        x_label_str = 'log_{10}(Noise Power)';
    else
        x_ticks = x_values;
        x_label_str = x_label;
    end

    y_ticks = gamma_values / params.y_ref_value * 100;

    imagesc(x_ticks, y_ticks, all_max_d');
    colormap(turbo);
    colorbar;

    xlabel(x_label_str);
    ylabel('Change of Reference (%)');
    set(gca, 'YDir', 'normal');
    title(sprintf('Heatmap of Max %s Detection', upper(detector)));

end
