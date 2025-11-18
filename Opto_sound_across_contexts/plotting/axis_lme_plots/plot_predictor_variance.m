function plot_predictor_variance(lme)
    % Extract full Adjusted R²
    R2_full = lme.Rsquared.Adjusted;
    % Parse formula
    full_formula = char(lme.Formula.FELinearFormula);  % e.g., 'y ~ x1 + x2 + x3'
    response_var = strtrim(extractBefore(full_formula, '~'));
    predictor_str = strtrim(extractAfter(full_formula, '~'));
    % Clean up predictor terms (handle interactions, remove whitespace)
    predictor_terms = strtrim(split(predictor_str, '+'));
    % Clean out empty terms just in case
    predictor_terms(cellfun(@isempty, predictor_terms)) = [];
    % Loop through each predictor and refit model without it
    delta_R2 = zeros(length(predictor_terms), 1);
    for i = 1:length(predictor_terms)
        reduced_terms = predictor_terms;
        reduced_terms(i) = [];
        % Join remaining terms to string
        reduced_rhs = strjoin(reduced_terms, ' + ');
        % Use the same random effect grouping (assumes one grouping var)
        random_effect = sprintf('(1|%s)', string(lme.Formula.GroupingVariableNames{1}));
        % Final formula
        reduced_formula = sprintf('%s ~ %s + %s', response_var, reduced_rhs, random_effect);
        % Refit and get R²
        reduced_lme = fitlme(lme.Variables, reduced_formula);
        R2_reduced = reduced_lme.Rsquared.Adjusted;
        delta_R2(i) = R2_full - R2_reduced;
    end
    % Normalize to percentage
    percent_var = 100 * delta_R2 / sum(delta_R2);
    % Plot
    figure;
    bar(percent_var, 'FaceColor', [0.2 0.6 0.8]);
    set(gca, 'XTick', 1:length(predictor_terms), ...
             'XTickLabel', predictor_terms, ...
             'XTickLabelRotation', 45);
    ylabel('% Adjusted R² Contribution');
    title('Fixed Effect Contributions to Model Fit');
    ylim([0, max(percent_var) * 1.3]);
    % Add value labels
    for i = 1:length(percent_var)
        text(i, percent_var(i) + 1, sprintf('%.1f%%', percent_var(i)), 'HorizontalAlignment', 'center');
    end
end