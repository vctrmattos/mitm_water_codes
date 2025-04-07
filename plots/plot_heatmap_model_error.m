function plot_heatmap_model_error(results_struct, model_errors, detector)
% Plot heatmap and 3D surface of max PASAD detection
% across gamma_ref and multiplicative model error values

    % === Get field names (model error levels) ===
    model_error_fields = fieldnames(results_struct);
    num_errors = length(model_error_fields);

    % === Load gamma values from the first substructure ===
    sample = results_struct.(model_error_fields{1});
    gamma_values = [sample.gamma];
    num_gamma = length(gamma_values);

    % === Preallocate matrix for max PASAD values ===
    all_max_d = zeros(num_errors, num_gamma);

    % === Iterate through results_struct ===
    for i = 1:num_errors
        key = model_error_fields{i};
        local_results = results_struct.(key);
    
        for j = 1:num_gamma
            if detector == "pasad"
                all_max_d(i, j) = max(local_results(j).pasad);
            elseif detector == "cusum"
                all_max_d(i, j) = abs(max(local_results(j).cusum_pos)) + abs(max(local_results(j).cusum_neg));
            end
        end
    end

    %% === 3D Surface Plot ===
    figure;
    [X, Y] = meshgrid(model_errors, gamma_values);
    surf(X, Y, all_max_d', 'EdgeColor', 'none');
    colormap(parula);
    shading interp;
    lighting gouraud;
    caxis([min(all_max_d(:)) max(all_max_d(:))]);
    colorbar;

    xlabel('Multiplicative model error', 'FontSize', 14, 'FontWeight', 'bold');
    ylabel('\gamma_{ref}', 'FontSize', 14, 'FontWeight', 'bold');
    zlabel('Max detection (PASAD)', 'FontSize', 14, 'FontWeight', 'bold');
    title(sprintf('Detection Response in %s', detector), 'FontSize', 16, 'FontWeight', 'bold');

    %% === Heatmap ===
    figure;
    imagesc((model_errors - 1)*100, gamma_values/0.5*100, all_max_d');
    colormap(turbo);
    colorbar;
    xlabel('Multiplicative Model Error (%)');
    ylabel('Change of Reference (%)');
    set(gca, 'YDir', 'normal');
    title(sprintf('Heatmap of Max %s Detection', detector));

end
