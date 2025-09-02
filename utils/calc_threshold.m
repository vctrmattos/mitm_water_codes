function optimalThreshold = calc_threshold(results, field_name, epsilon)
    % Computes the optimal threshold for a given detection method.
    % Uses min or max depending on the field_name (e.g., 'cusum_neg' uses min).
    
    % Extract gamma values
    gamma_values = arrayfun(@(x) x.gamma, results);
    
    % Choose score extraction method based on field name
    if strcmp(field_name, 'cusum_neg')
        scores = arrayfun(@(x) min(x.(field_name)), results);
        optimalThreshold = min(scores(gamma_values == 0)) - epsilon;
    else
        scores = arrayfun(@(x) max(x.(field_name)), results);
        optimalThreshold = max(scores(gamma_values == 0)) + epsilon;
    end
end
