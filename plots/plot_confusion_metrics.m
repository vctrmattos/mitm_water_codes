function plot_confusion_metrics(results_struct, param_values, detector_name, param_type)
    % Plots TP and FN for different models or noise levels using a structured input.
    %
    % INPUT:
    %   - results_struct: Struct where each field is a results set for a param level.
    %   - param_values: Vector of model_errors or noise_power.
    %   - detector_name: 'pasad' or 'cusum'.
    %   - param_type: 'model_error' or 'noise_power'.

    field_names = fieldnames(results_struct);
    num_cases = length(field_names);

    % Initialize vectors
    TP_all = zeros(1, num_cases);
    FP_all = zeros(1, num_cases);
    FN_all = zeros(1, num_cases);
    TN_all = zeros(1, num_cases);

    for i = 1:num_cases
        field = field_names{i};
        results = results_struct.(field);

        % Compute optimal threshold for current results
        if strcmpi(detector_name, 'pasad')
            threshold = calc_threshold(results, 'pasad', 1e-9);
        elseif strcmpi(detector_name, 'cusum')
            t_pos = calc_threshold(results, 'cusum_pos', 1e-9);
            t_neg = calc_threshold(results, 'cusum_neg', 1e-9);
            threshold = [t_pos, t_neg];
        else
            error('Unknown detector: %s', detector_name);
        end

        % Compute metrics for this threshold
        confMatrix = compute_metrics(results, threshold, detector_name);

        TP_all(i) = confMatrix(1,1);
        FP_all(i) = confMatrix(1,2);
        FN_all(i) = confMatrix(2,1);
        TN_all(i) = confMatrix(2,2);
    end

    %% Plot
    figure;

    % Ajuste do eixo X e labels
    if strcmp(param_type, 'noise_power')
        xval = param_values;
        xscale = 'log';
        xlabel_text = 'Noise power (ppm²/Hz)';
    else
        xval = (param_values - 1) * 100;
        xscale = 'linear';
        xlabel_text = 'Multiplicative Model Error (%)';
    end
    
    % Plot
    hold on;
    plot(xval, TP_all / length(results) * 100, '-o', 'LineWidth', 2);
    plot(xval, FN_all / length(results) * 100, '-^', 'LineWidth', 2);
    hold off;

    set(gca, 'XScale', xscale);
    grid on;
    xlabel(xlabel_text);
    ylabel('Rate (%)');
    title(sprintf('Confusion Metrics - %s Detector', upper(detector_name)));
    legend('True Positive Rate', 'False Negative Rate', 'Location', 'best');
    xlim([min(xval), max(xval)]);
end
