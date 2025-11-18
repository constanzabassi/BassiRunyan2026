function [left_sel, right_sel, nonsel] = categorize_selectivity_context(selectivity, threshold, sig_cells, sig_selective_neurons)
% Categorizes cells into left-selective, right-selective, or non-selective pools
    % based on their selectivity indices and a threshold
    %
    % Inputs:
    %   selectivity - Vector of selectivity indices for all cells
    %   threshold   - Numeric threshold for determining selectivity
    %                 (typically 0.1 or 0.2)
    %   sig_cells   - Indices of significantly modulated cells to consider
    %
    % Outputs:
    %   left_sel  - Indices of cells selective for left sounds
    %   right_sel - Indices of cells selective for right sounds
    %   nonsel    - Indices of non-selective cells

%%%triple check to make sure signs make sense!
    % Find selective cells
    right_sel = sig_cells(selectivity(sig_cells) <= -threshold & ismember(sig_cells, sig_selective_neurons));
    left_sel = sig_cells(selectivity(sig_cells) >= threshold & ismember(sig_cells, sig_selective_neurons));
    nonsel = sig_cells(abs(selectivity(sig_cells)) < threshold); %| ~ismember(sig_cells, sig_selective_neurons));
end