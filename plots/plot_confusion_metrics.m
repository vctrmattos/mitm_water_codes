function plot_confusion_metrics(results_struct, model_errors, detector_name)
    % Plots TP, FP, FN, and TN for different models using a structured input.
    %
    % INPUT:
    %   - results_struct: A struct where each field is a results set for a model.
    %   - detector_name: Name of the detector ('pasad' or 'cusum').

    epsilon = 10e-9;  % Small offset for threshold calculation

    model_names = fieldnames(results_struct);
    num_models = length(model_names);

    % Initialize metric vectors
    TP_all = zeros(1, num_models);
    FP_all = zeros(1, num_models);
    FN_all = zeros(1, num_models);
    TN_all = zeros(1, num_models);

    % Loop through each model in the struct
    for i = 1:num_models
        model = model_names{i};
        results = results_struct.(model);

        % Compute threshold based on the detector
        if strcmpi(detector_name, 'pasad')
            threshold = calc_threshold(results, 'pasad', epsilon);
        elseif strcmpi(detector_name, 'cusum')
            t_pos = calc_threshold(results, 'cusum_pos', epsilon);
            t_neg = calc_threshold(results, 'cusum_neg', epsilon);
            threshold = [t_pos, t_neg];
        else
            error('Detector "%s" not recognized.', detector_name);
        end

        % Compute confusion matrix
        confMatrix = compute_metrics(results, threshold, detector_name);

        TP_all(i) = confMatrix(1,1);
        FP_all(i) = confMatrix(1,2);
        FN_all(i) = confMatrix(2,1);
        TN_all(i) = confMatrix(2,2);
    end

    % Plot metrics
    figure;
    plot(TP_all/num_models * 100, '-o', 'LineWidth', 2); hold on;
%     plot(FP_all, '-s', 'LineWidth', 2);
    plot(FN_all/num_models * 100, '-^', 'LineWidth', 2);
%     plot(TN_all, '-d', 'LineWidth', 2);
    hold off;

    grid on;
    xlabel('Model Error (%)');
    ylabel('Rate (%)');
    title(sprintf('Confusion Metrics - %s Detector', upper(detector_name)));
%     legend('TP', 'FP', 'FN', 'TN', 'Location', 'best');
    legend('True Positive Rate', 'False Negative Rate', 'Location', 'best');
    xticks(1:num_models);
    xticklabels((model_errors - 1)*100);
    xtickangle(45);  % Rotate labels if needed
end
