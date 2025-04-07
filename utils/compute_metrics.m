function confMatrix = compute_metrics(results, threshold, detector_name)
    % Computes True Positive, False Positive, False Negative, and True Negative rates.
    % Optionally, it plots the confusion matrix and performance graphs.
    %
    % INPUTS:
    %   - results: Struct array containing detection scores and labels.
    %   - threshold: Optimized threshold for classification.
    %   - detector_name: String name of the detector ('PASAD', 'CUSUM_pos', etc.).
    %
    % OUTPUT:
    %   - metrics: Struct containing TP, FP, FN, TN, and confusion matrix.
    if detector_name == 'pasad'
        % Extract scores
        scores = arrayfun(@(x) max(x.pasad), results);
        
        % Labels (1 if attack, 0 otherwise)
        labels = arrayfun(@(x) x.gamma ~= 0, results);
    
        % Predicted labels based on threshold
        predicted_labels = scores >= threshold;
    
        % Compute Confusion Matrix Components
        TP = sum((predicted_labels == 1) & (labels == 1));
        FP = sum((predicted_labels == 1) & (labels == 0));
        FN = sum((predicted_labels == 0) & (labels == 1));
        TN = sum((predicted_labels == 0) & (labels == 0));
    
        % Store in struct
        confMatrix = [TP, FP; FN, TN];
        
    else if detector_name == 'cusum'
                % Extract scores
        scores_pos = arrayfun(@(x) max(x.cusum_pos), results);
        scores_neg = arrayfun(@(x) max(x.cusum_neg), results);
       
        % Labels (1 if attack, 0 otherwise)
        labels = arrayfun(@(x) x.gamma ~= 0, results);
        
        threshold_pos = threshold(1);
        threshold_neg = threshold(2);

        % Predicted labels based on threshold
        predicted_labels_pos = scores_pos >= threshold_pos;
        predicted_labels_neg = scores_neg >= threshold_neg;
    
        % Compute Confusion Matrix Components
        TP = sum((predicted_labels_pos == 1 | predicted_labels_neg == 1) & (labels == 1));
        FP = sum((predicted_labels_pos == 1 | predicted_labels_neg == 1) & (labels == 0));
        FN = sum((predicted_labels_pos == 0 & predicted_labels_neg == 0) & (labels == 1));
        TN = sum((predicted_labels_pos == 0 & predicted_labels_neg == 0) & (labels == 0));
    
        % Store in struct
        confMatrix = [TP, FP; FN, TN];
    end
end
