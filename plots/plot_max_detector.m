function plot_max_detector(results, detector, optimal_threshold, params)
   figure;
   if ~strcmp(detector, 'cusum_neg')
   max_detector = arrayfun(@(x) max(x.(detector)), results);
   else
       max_detector = arrayfun(@(x) min(x.(detector)), results);
    end
   plot(params.gamma_values, max_detector);
   hold on;
   plot(params.gamma_values, max_detector, 'ro');
   
   yline(optimal_threshold, '--r', 'LineWidth', 1.5);
   text(params.gamma_values(end), optimal_threshold, ...
       sprintf('Threshold: %.3e', optimal_threshold), ...
       'Color', 'r', 'FontSize', 10, 'FontWeight', 'bold', ...
       'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
   
   ylabel('Max value of the detector');
   xlabel('$\gamma_{\mathrm{ref}}$', 'Interpreter', 'latex');
   title(sprintf('Max of detector %s', upper(detector)));
   
   grid on;
   hold off;
end
