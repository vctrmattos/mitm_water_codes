function optimalThreshold = calc_threshold(results, field_name, epsilon)
    % Computes the optimal threshold for a given detection method.
    % INPUTS:
    %   - results: Struct array containing the detection scores.
    %   - field_name: String specifying the field in results (e.g., 'pasad', 'cusum_pos').
    %   - epsilon: Small offset to ensure separation 
    % OUTPUT:
    %   - optimalThreshold: Optimized threshold.

    % Extract scores based on the provided field name
    scores = arrayfun(@(x) max(x.(field_name)), results);

    % Identify non-attack cases (gamma == 0) and find the max score
    gamma_values = arrayfun(@(x) x.gamma, results);
    optimalThreshold = max(scores(gamma_values == 0)) + epsilon;
end
