function legend_entries = generate_legend_entries(prefix, contexts)
    % Function to generate legend entries by combining a prefix with context names
    %
    % Inputs:
    %   - prefix: A string prefix (e.g., 'Stim' or 'Control')
    %   - contexts: A cell array of strings representing different contexts
    %
    % Output:
    %   - legend_entries: A cell array of concatenated legend labels

    legend_entries = strcat(prefix, " ", contexts);
end