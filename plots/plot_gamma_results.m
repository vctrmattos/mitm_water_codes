function plot_gamma_results(results, optimal_thresholds, params, num_plots_per_row)
    % Function to plot sensor data, PASAD, and CUSUM results from the structure 'results'
    % Inputs:
    %   results - Struct array containing results for different gamma values
    %   num_plots_per_row - Number of plots per row
    %   optimal_thresholds - Struct with optimal thresholds (pasad, cusum_pos, cusum_neg)
    N = params.N;
    T = length([results.sensor]);
    atck_rg = (params.gamma_ref_start)/params.Ts:T;

    num_gammas = length([results.gamma]);
    max_per_figure = num_plots_per_row; % Define max plots per row
    num_figures = ceil(num_gammas / max_per_figure);
    
    for fig_idx = 1:num_figures
        figure;
        start_idx = (fig_idx - 1) * max_per_figure + 1;
        end_idx = min(fig_idx * max_per_figure, num_gammas);
        num_subplots = end_idx - start_idx + 1;
        
        tiledlayout(num_subplots, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
        
        for subplot_idx = 1:num_subplots
            idx = start_idx + subplot_idx - 1;
            
            % Extract relevant data
            gamma_ref = results(idx).gamma;
            sensor = results(idx).sensor;
            pasad = results(idx).pasad;
            time = results(idx).time;
            cusum_pos = results(idx).cusum_pos;
            cusum_neg = results(idx).cusum_neg;
            y_m = results(idx).y_m;
            
            % Retrieve optimal thresholds
            optimal_threshold_pasad = optimal_thresholds.pasad;
            optimal_threshold_cusum = optimal_thresholds.cusum_pos;
            optimal_threshold_cusum_neg = optimal_thresholds.cusum_neg;
            
            % First subplot: Sensor measurements
            ax1 = nexttile;
            hold on;
            plot(time, sensor, 'k', 'LineWidth', 1);
            plot(time(1:N), sensor(1:N), 'b', 'LineWidth', 1, 'DisplayName', 'Training');
            plot(time(atck_rg), sensor(atck_rg), 'r', 'DisplayName', 'y_{ma}');
            plot(time, y_m, '-', 'DisplayName', 'y_m');
            ylabel('Sensor Measurements');
            xlabel('Samples');
            title(sprintf('\\gamma = %.2f', gamma_ref));
            legend({'Training', 'y_{ma}', 'y_m'}, 'Location', 'best');

            % Second subplot: PASAD Detector
            ax2 = nexttile;
            hold on;
            plot(time(N + 1:end), pasad, 'b', 'LineWidth', 2);
            xlabel('Samples');
            ylabel('PASAD Detector');
            yline(optimal_threshold_pasad, '--r', 'LineWidth', 1.5);
            text(time(end), optimal_threshold_pasad, ...
                sprintf('%.3e', optimal_threshold_pasad), ...
                'Color', 'r', 'FontSize', 10, 'FontWeight', 'bold', ...
                'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center');

            anomaly_indices_pasad = find(pasad > optimal_threshold_pasad);
            if ~isempty(anomaly_indices_pasad)
                plot(time(N + anomaly_indices_pasad), pasad(anomaly_indices_pasad), ...
                    'ro', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r', 'MarkerSize', 0.5);
            end

            % Third subplot: CUSUM Detector
            ax3 = nexttile;
            hold on;
            plot(time(N + 1:end), cusum_pos, 'b', 'LineWidth', 2);
            plot(time(N + 1:end), cusum_neg, 'b', 'LineWidth', 2);
            xlabel('Samples');
            ylabel('CUSUM Detector');
            title(sprintf('CUSUM \\gamma = %.2f', gamma_ref));

            yline(optimal_threshold_cusum, '--r', 'LineWidth', 1.5);
            yline(optimal_threshold_cusum_neg, '--r', 'LineWidth', 1.5);

            text(time(end), optimal_threshold_cusum, ...
                sprintf('%.3e', optimal_threshold_cusum), ...
                'Color', 'r', 'FontSize', 10, 'FontWeight', 'bold', ...
                'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center');

            text(time(end), -optimal_threshold_cusum_neg, ...
                sprintf('%.3e', optimal_threshold_cusum_neg), ...
                'Color', 'r', 'FontSize', 10, 'FontWeight', 'bold', ...
                'VerticalAlignment', 'top', 'HorizontalAlignment', 'center');

            % Anomalies detected by CUSUM
            anomaly_indices_pos = find(cusum_pos > optimal_threshold_cusum);
            anomaly_indices_neg = find(cusum_neg < optimal_threshold_cusum_neg);

            if ~isempty(anomaly_indices_pos)
                plot(time(N + anomaly_indices_pos), cusum_pos(anomaly_indices_pos), 'ro', 'LineWidth', 0.5);
            end

            if ~isempty(anomaly_indices_neg)
                plot(time(N + anomaly_indices_neg), cusum_neg(anomaly_indices_neg), 'or', 'LineWidth', 0.5);
            end
            
            % Synchronize x-axis of all plots
            linkaxes([ax1, ax2, ax3], 'x');
        end
        
        % General title for the figure
        sgtitle(sprintf('Sensor Measurements, Departure Scores, and CUSUM (Gammas %.2f - %.2f)', ...
                        results(start_idx).gamma, results(end_idx).gamma));
        hold off;
    end
end
